import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../logging/app_log.dart';
import 'first_aid_store.dart';
import 'offline_triage_classifier.dart';

/// How triage was produced.
enum TriageSource { geminiCloud, offlineClassifier, webDemo }

/// Model / pipeline state for UI.
enum ModelState { unloaded, ready, error, degraded }

/// Triage result from cloud LLM or lightweight offline classifier.
class TriageResult {
  final String functionCall;
  final String location;
  final int severityLevel;
  final List<String> requiredServices;
  final String firstAidQuery;
  final String compressedPayload;
  final String? thinkingTrace;
  final bool isDegradedMode;
  final TriageSource source;

  const TriageResult({
    required this.functionCall,
    required this.location,
    required this.severityLevel,
    required this.requiredServices,
    required this.firstAidQuery,
    required this.compressedPayload,
    this.thinkingTrace,
    this.isDegradedMode = false,
    this.source = TriageSource.offlineClassifier,
  });

  Map<String, dynamic> toJson() => {
        'function_call': functionCall,
        'arguments': {
          'location': location,
          'severity_level': severityLevel,
          'required_services': requiredServices,
          'first_aid_rag_query': firstAidQuery,
          'compressed_payload': compressedPayload,
        },
        'thinking_trace': thinkingTrace,
        'degraded_mode': isDegradedMode,
        'source': source.name,
      };
}

/// AI Triage: **cloud-first** (Gemini Flash) with **tiny offline classifier** fallback.
/// Full on-device LLM / GGUF is intentionally not used (OOM on low-RAM devices).
class AiTriageService {
  static const _geminiModel = 'gemini-2.0-flash';
  static const _generateContentPath =
      'v1beta/models/$_geminiModel:generateContent';

  static const _classifier = OfflineTriageClassifier();

  ModelState _state = ModelState.unloaded;
  String? _lastError;
  String? _apiKey;

  ModelState get state => _state;
  String? get lastError => _lastError;

  String? _envKey() {
    try {
      return dotenv.env['GEMINI_API_KEY']?.trim();
    } catch (_) {
      return null;
    }
  }

  /// Resolves API key. No multi-GB model assets on disk.
  Future<void> initializeModel() async {
    _state = ModelState.unloaded;
    _apiKey = _envKey();
    if (kIsWeb) {
      _state = ModelState.degraded;
      _lastError =
          'Web: triage uses offline classifier only (no API key in client).';
      return;
    }
    if (_apiKey == null || _apiKey!.isEmpty) {
      _state = ModelState.degraded;
      _lastError =
          'GEMINI_API_KEY missing in .env — using offline classifier only.';
      appLog.d('[AiTriageService] $_lastError');
      return;
    }
    _state = ModelState.ready;
    _lastError = null;
    appLog.d(
      '[AiTriageService] Cloud triage (Gemini Flash). Offline: keyword classifier.',
    );
  }

  Future<TriageResult> triageEmergency({
    required String audioTranscript,
    required String locationString,
    required int accelerometerSeverityHint,
    String languageCode = 'en',
  }) async {
    final heuristic = await _buildClassifierTriage(
      transcript: audioTranscript,
      location: locationString,
      severityHint: accelerometerSeverityHint,
      languageCode: languageCode,
    );

    if (kIsWeb) {
      return heuristic;
    }

    final key = _apiKey ?? _envKey();
    if (key == null || key.isEmpty) {
      return heuristic;
    }

    try {
      final cloud = await _callGeminiFlash(
        apiKey: key,
        transcript: audioTranscript,
        location: locationString,
        severityHint: accelerometerSeverityHint,
        languageCode: languageCode,
      );
      return cloud;
    } catch (e, st) {
      appLog.d('[AiTriageService] Gemini failed; using classifier', e, st);
      _lastError = 'Cloud triage failed: $e';
      return heuristic;
    }
  }

  Future<TriageResult> performTriage({
    required dynamic location,
    required bool isBystander,
    String transcript = '',
    String languageCode = 'en',
  }) async {
    final locationString = '${location.latitude},${location.longitude}';
    final ctx = transcript.trim().isEmpty
        ? (isBystander
            ? 'Bystander reporting roadside emergency'
            : 'Emergency SOS triggered')
        : transcript;

    return triageEmergency(
      audioTranscript: ctx,
      locationString: locationString,
      accelerometerSeverityHint: 4,
      languageCode: languageCode,
    );
  }

  Future<TriageResult> _callGeminiFlash({
    required String apiKey,
    required String transcript,
    required String location,
    required int severityHint,
    required String languageCode,
  }) async {
    final langHint = languageCode == 'en'
        ? 'User may write in English or Indian languages (Hindi, Tamil, etc.).'
        : 'Prefer reasoning and JSON field values appropriate for language code: $languageCode. User text may be mixed English and regional languages.';

    final prompt =
        '''You are an emergency triage assistant for RoadSOS (road crashes).
Respond with ONLY valid JSON (no markdown), one object:
{
  "severity_level": <int 1-5>,
  "required_services": <array of strings from: ambulance, police, fire_department, rescue, towing, puncture_shop, showroom>,
  "first_aid_focus": <short string for first-aid lookup>,
  "thinking_summary": <one sentence reasoning>
}
Rules: If unsure, bias toward higher severity. GPS: $location. Accelerometer hint (1-5): $severityHint.
$langHint
User situation text: "$transcript"
''';

    final uri = Uri.https(
      'generativelanguage.googleapis.com',
      _generateContentPath,
      {'key': apiKey},
    );

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt},
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.2,
        'maxOutputTokens': 512,
      },
    });

    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: body,
        )
        .timeout(const Duration(seconds: 25));

    if (response.statusCode != 200) {
      throw Exception(
        'Gemini HTTP ${response.statusCode}: ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final text = _extractGeminiText(decoded);
    final jsonStart = text.indexOf('{');
    final jsonEnd = text.lastIndexOf('}');
    if (jsonStart < 0 || jsonEnd <= jsonStart) {
      throw FormatException('No JSON in Gemini reply: $text');
    }

    final payload =
        jsonDecode(text.substring(jsonStart, jsonEnd + 1)) as Map<String, dynamic>;

    final severity =
        (payload['severity_level'] as num?)?.toInt().clamp(1, 5) ?? 4;
    final rawServices = payload['required_services'];
    final services = <String>{'ambulance'};
    if (rawServices is List) {
      for (final e in rawServices) {
        if (e is String && e.isNotEmpty) {
          services.add(e.toLowerCase().replaceAll(' ', '_'));
        }
      }
    }
    final fromCloud = (payload['first_aid_focus'] as String?)?.trim();
    final fallbackQuery = _classifier
        .classify(transcript: transcript, severityHint: severityHint)
        .firstAidQuery;
    final aidQuery =
        (fromCloud != null && fromCloud.isNotEmpty) ? fromCloud : fallbackQuery;
    final thinking = payload['thinking_summary'] as String?;

    final verifiedAdvice = await FirstAidStore.getVerifiedAdvice(aidQuery);

    return TriageResult(
      functionCall: 'trigger_sos',
      location: location,
      severityLevel: severity,
      requiredServices: services.toList(),
      firstAidQuery: verifiedAdvice,
      compressedPayload:
          _buildCompressedPayload(location, severity, services.toList()),
      thinkingTrace: thinking,
      isDegradedMode: false,
      source: TriageSource.geminiCloud,
    );
  }

  String _extractGeminiText(Map<String, dynamic> decoded) {
    final candidates = decoded['candidates'];
    if (candidates is! List || candidates.isEmpty) return '';
    final first = candidates.first;
    if (first is! Map) return '';
    final content = first['content'];
    if (content is! Map) return '';
    final parts = content['parts'];
    if (parts is! List) return '';
    final buf = StringBuffer();
    for (final p in parts) {
      if (p is Map && p['text'] is String) buf.write(p['text'] as String);
    }
    return buf.toString();
  }

  Future<TriageResult> _buildClassifierTriage({
    required String transcript,
    required String location,
    required int severityHint,
    required String languageCode,
  }) async {
    final c = _classifier.classify(
      transcript: transcript,
      severityHint: severityHint,
    );
    final severity = c.severityLevel;
    final services = c.requiredServices;
    final verified = await FirstAidStore.getVerifiedAdvice(c.firstAidQuery);

    return TriageResult(
      functionCall: 'trigger_sos',
      location: location,
      severityLevel: severity,
      requiredServices: services,
      firstAidQuery: verified,
      compressedPayload: _buildCompressedPayload(location, severity, services),
      thinkingTrace: languageCode == 'hi'
          ? 'ऑफ़लाइन वर्गीकरण — क्लाउड उपलब्ध नहीं।'
          : 'Offline keyword classifier (no cloud LLM on device).',
      isDegradedMode: true,
      source: TriageSource.offlineClassifier,
    );
  }

  String _buildCompressedPayload(
    String location,
    int severity,
    List<String> services,
  ) {
    final svcCodes = services.map((s) {
      switch (s) {
        case 'ambulance':
          return 'AMB';
        case 'police':
          return 'POL';
        case 'fire_department':
          return 'FIR';
        case 'rescue':
          return 'RES';
        case 'towing':
          return 'TOW';
        case 'puncture_shop':
          return 'PUN';
        case 'showroom':
          return 'SHR';
        default:
          return 'UNK';
      }
    }).join(',');

    final loc = location.replaceAll(' ', '_');
    final clipped = loc.length <= 30 ? loc : loc.substring(0, 30);
    return 'LOC:$clipped|SEV:$severity|SVC:$svcCodes';
  }
}

final aiTriageServiceProvider = Provider<AiTriageService>((ref) {
  return AiTriageService();
});
