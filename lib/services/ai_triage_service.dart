import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../logging/app_log.dart';
import 'first_aid_store.dart';
import 'offline_triage_classifier.dart';
import 'tier2_local_triage_model.dart';

/// How triage was produced.
enum TriageSource { geminiEdge, localTier2, offlineClassifier, webDemo }

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
  static const _classifier = OfflineTriageClassifier();
  static const _tier2 = Tier2LocalTriageModel();

  ModelState _state = ModelState.unloaded;
  String? _lastError;

  ModelState get state => _state;
  String? get lastError => _lastError;

  /// Resolves API key. No multi-GB model assets on disk.
  Future<void> initializeModel() async {
    _state = ModelState.unloaded;
    if (kIsWeb) {
      _state = ModelState.degraded;
      _lastError = 'Web: triage uses offline tiers only.';
      return;
    }
    // Cloud triage is server-side via Supabase Edge Function. Client never holds GEMINI keys.
    _state = ModelState.ready;
    _lastError = null;
    appLog.d('[AiTriageService] Triage ready. Cloud: Edge Function. Offline: tier2 + classifier.');
  }

  Future<TriageResult> triageEmergency({
    required String audioTranscript,
    required String locationString,
    required int accelerometerSeverityHint,
    String languageCode = 'en',
  }) async {
    // Tier 3 (always available): simple keyword classifier.
    final tier3 = await _buildClassifierTriage(
      transcript: audioTranscript,
      location: locationString,
      severityHint: accelerometerSeverityHint,
      languageCode: languageCode,
    );

    if (kIsWeb) {
      return tier3;
    }

    // Tier 2 (always available): slightly richer local model.
    final tier2 = await _buildTier2Triage(
      transcript: audioTranscript,
      location: locationString,
      severityHint: accelerometerSeverityHint,
      languageCode: languageCode,
    );

    try {
      // Tier 1: server-side Gemini via Supabase Edge Function (strict timeout).
      final cloud = await _callGeminiViaEdge(
        transcript: audioTranscript,
        location: locationString,
        severityHint: accelerometerSeverityHint,
        languageCode: languageCode,
      ).timeout(const Duration(seconds: 3));
      return cloud;
    } catch (e, st) {
      appLog.d(
        '[AiTriageService] Cloud triage unavailable; falling back to local tiers',
        error: e,
        stackTrace: st,
      );
      _lastError = 'Cloud triage unavailable: $e';
      // Prefer tier2 over tier3.
      return tier2;
    }
  }

  Future<TriageResult> performTriage({
    required dynamic location,
    required bool isBystander,
    String transcript = '',
    String languageCode = 'en',
    int severityHint = 3,
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
      accelerometerSeverityHint: severityHint.clamp(1, 5),
      languageCode: languageCode,
    );
  }

  Future<TriageResult> _callGeminiViaEdge({
    required String transcript,
    required String location,
    required int severityHint,
    required String languageCode,
  }) async {
    // Cloud triage is done server-side. Requires Supabase SDK init + anon session.
    try {
      final client = Supabase.instance.client;
      final res = await client.functions.invoke(
        'triage-gemini',
        body: <String, dynamic>{
          'schema': 'roadsos.triage.v1',
          'transcript': transcript,
          'location': location,
          'severity_hint': severityHint,
          'language_code': languageCode,
        },
      );

      // Supabase functions invoke returns dynamic JSON in [data].
      final data = res.data;
      if (data is! Map) {
        throw Exception('Edge triage returned non-object');
      }
      final payload = Map<String, dynamic>.from(data);

      final severity =
          (payload['severity_level'] as num?)?.toInt().clamp(1, 5) ?? 4;
      final rawServices = payload['required_services'];
      final services = <String>{'ambulance'};
      if (rawServices is List) {
        for (final e in rawServices) {
          if (e is String && e.isNotEmpty) {
            final normalized = e.toLowerCase().replaceAll(' ', '_');
            if (_allowedServices.contains(normalized)) {
              services.add(normalized);
            }
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
        source: TriageSource.geminiEdge,
      );
    } catch (e, st) {
      appLog.w('Edge triage failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  // Note: direct Gemini HTTP parsing remains in [gemini_http.dart] for non-triage flows.

  static const Set<String> _allowedServices = {
    'ambulance',
    'police',
    'fire_department',
    'rescue',
    'towing',
    'puncture_shop',
    'showroom',
  };

  // JSON extraction is handled server-side for triage; client receives clean JSON payload.

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

  Future<TriageResult> _buildTier2Triage({
    required String transcript,
    required String location,
    required int severityHint,
    required String languageCode,
  }) async {
    final c = _tier2.classify(
      transcript: transcript,
      severityHint: severityHint,
    );
    final verified = await FirstAidStore.getVerifiedAdvice(c.firstAidQuery);
    return TriageResult(
      functionCall: 'trigger_sos',
      location: location,
      severityLevel: c.severityLevel.clamp(1, 5),
      requiredServices: c.requiredServices,
      firstAidQuery: verified,
      compressedPayload: _buildCompressedPayload(location, c.severityLevel, c.requiredServices),
      thinkingTrace: languageCode == 'hi'
          ? 'स्थानीय मॉडल — नेटवर्क उपलब्ध नहीं।'
          : 'Local tier-2 triage model (offline).',
      isDegradedMode: true,
      source: TriageSource.localTier2,
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
