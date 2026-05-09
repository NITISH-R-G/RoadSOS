import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logging/app_log.dart';
import 'gemma_model_manager.dart';

/// On-device Gemma 4 E4B inference via flutter_gemma / MediaPipe LiteRT.
///
/// This is Tier 2 in the 4-tier inference stack — fires when cloud Gemma 4 27B
/// is unreachable (no internet, server timeout, or offline crash scenario).
///
/// Model:    gemma-4-e4b-it-Q4_K_M.gguf  (~2.4 GB)
/// Runtime:  MediaPipe LiteRT via flutter_gemma 0.3.x
/// Download: GemmaModelManager — prompted once during onboarding
///
/// If the model has not been downloaded, all inference methods return null and
/// the orchestrator falls through to Tier 3 (heuristic). This is expected.
///
/// Special prize alignment:
/// - Cactus: "local-first mobile routing between models" → Tier 1→2→3→4 routing
/// - LiteRT:  "best on-device inference with MediaPipe LiteRT"
class GemmaLocalService {
  GemmaLocalService._();

  bool _initialized = false;
  bool _available = false;
  String? _lastError;
  FlutterGemmaPlugin? _plugin;

  bool get isAvailable => _available && _plugin != null;
  bool get isInitialized => _initialized;
  String? get lastError => _lastError;

  /// Initializes Gemma 4 E4B on-device.
  /// Non-blocking — safe to fire-and-forget from AiTriageService.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    if (kIsWeb) {
      _lastError = 'On-device Gemma unavailable on web.';
      return;
    }
    if (!Platform.isAndroid && !Platform.isIOS) {
      _lastError = 'On-device Gemma available on Android / iOS only.';
      return;
    }

    try {
      _plugin = await _initFlutterGemma();
      _available = _plugin != null;
      if (_available) {
        appLog.i('[GemmaLocal] ✓ Gemma 4 E4B on-device ready');
      } else {
        appLog.i(
          '[GemmaLocal] Gemma 4 E4B not ready — cloud or heuristic tiers will handle triage.\n'
          '  Model not downloaded yet? Run model download during onboarding.',
        );
      }
    } catch (e, st) {
      _lastError = 'Init error: $e';
      _available = false;
      appLog.w('[GemmaLocal] Init failed', error: e, stackTrace: st);
    }
  }

  // ── Real flutter_gemma initialization ─────────────────────────────────────

  Future<FlutterGemmaPlugin?> _initFlutterGemma() async {
    // Step 1: Verify model file exists and passes basic size check.
    // The model is downloaded by GemmaModelManager during onboarding.
    // Source: https://huggingface.co/google/gemma-4-e4b-it-GGUF
    final modelPath = await GemmaModelManager.localModelPath();
    final modelFile = File(modelPath);

    if (!modelFile.existsSync()) {
      appLog.i(
        '[GemmaLocal] Model not found at: $modelPath\n'
        '  → Download from HuggingFace during onboarding (GemmaModelDownloadScreen)',
      );
      return null;
    }

    final fileSizeBytes = modelFile.lengthSync();
    if (fileSizeBytes < GemmaModelManager.expectedMinBytes) {
      appLog.w(
        '[GemmaLocal] Model file truncated '
        '(${(fileSizeBytes / 1024 / 1024).round()} MB < min '
        '${(GemmaModelManager.expectedMinBytes / 1024 / 1024).round()} MB). '
        'Re-download needed.',
      );
      return null;
    }

    appLog.i(
      '[GemmaLocal] Model: ${(fileSizeBytes / 1024 / 1024).round()} MB. '
      'Initialising flutter_gemma...',
    );

    // Step 2: Load model into MediaPipe LiteRT runtime.
    // flutter_gemma 0.3.x exposes loadModel({required String modelPath}).
    // We try this first; fall back to passing modelPath in init() if unavailable.
    final plugin = FlutterGemmaPlugin.instance;
    bool loadedViaLoadModel = false;

    try {
      // ignore: avoid_dynamic_calls
      await (plugin as dynamic).loadModel(modelPath: modelPath);
      loadedViaLoadModel = true;
      appLog.d('[GemmaLocal] loadModel() succeeded');
    } on NoSuchMethodError {
      appLog.d('[GemmaLocal] loadModel() not in this build — will pass via init()');
    } catch (e) {
      appLog.w('[GemmaLocal] loadModel() threw: $e — trying init() fallback');
    }

    // Step 3: Configure inference parameters.
    // temperature 0.3 → low randomness (triage needs consistent output)
    // topK 40 → sufficient for multilingual token diversity
    // maxTokens 512 → enough for structured JSON response
    try {
      if (loadedViaLoadModel) {
        await plugin.init(
          maxTokens: 512,
          temperature: 0.3,
          topK: 40,
          randomSeed: 42,
        );
      } else {
        // Some 0.3.x builds accept modelPath in init() directly.
        try {
          // ignore: avoid_dynamic_calls
          await (plugin as dynamic).init(
            modelPath: modelPath,
            maxTokens: 512,
            temperature: 0.3,
            topK: 40,
            randomSeed: 42,
          );
        } on NoSuchMethodError {
          await plugin.init(
            maxTokens: 512,
            temperature: 0.3,
            topK: 40,
            randomSeed: 42,
          );
        }
      }
    } catch (e, st) {
      appLog.w('[GemmaLocal] flutter_gemma init() failed', error: e, stackTrace: st);
      return null;
    }

    appLog.i('[GemmaLocal] FlutterGemmaPlugin.init() ✓');
    return plugin;
  }

  // ── Public inference API ───────────────────────────────────────────────────

  /// Run on-device emergency triage using Gemma 4 E4B.
  /// Returns structured JSON map or null if model unavailable / inference fails.
  Future<Map<String, dynamic>?> triageOffline({
    required String transcript,
    required String location,
    required int severityHint,
    String languageCode = 'en',
  }) async {
    if (!_available || _plugin == null) return null;

    final prompt = _buildTriagePrompt(
      transcript: transcript,
      location: location,
      severityHint: severityHint,
      languageCode: languageCode,
    );

    try {
      final raw = await _plugin!.getResponse(prompt: prompt);
      if (raw == null || raw.isEmpty) return null;
      final parsed = _parseJSON(raw);
      if (parsed != null) {
        appLog.d('[GemmaLocal] On-device triage: severity=${parsed['severity_level']}');
      }
      return parsed;
    } catch (e, st) {
      appLog.w('[GemmaLocal] Inference failed — marking tier unavailable', error: e, stackTrace: st);
      _available = false; // Fall through to Tier 3 on next call
      _lastError = 'Inference error: $e';
      return null;
    }
  }

  /// Free-form on-device generation — for voice assistant and first-aid Q&A.
  Future<String?> generate(String prompt) async {
    if (!_available || _plugin == null) return null;
    try {
      final result = await _plugin!.getResponse(prompt: prompt);
      return result;
    } catch (e, st) {
      appLog.w('[GemmaLocal] generate() failed', error: e, stackTrace: st);
      _available = false;
      return null;
    }
  }

  /// Stream tokens from on-device Gemma 4 E4B for real-time UI display.
  Stream<String> generateStream(String prompt) async* {
    if (!_available || _plugin == null) return;
    try {
      await for (final token in _plugin!.getResponseAsync(prompt: prompt)) {
        if (token != null) yield token;
      }
    } catch (e, st) {
      appLog.w('[GemmaLocal] generateStream() failed', error: e, stackTrace: st);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static String _buildTriagePrompt({
    required String transcript,
    required String location,
    required int severityHint,
    required String languageCode,
  }) {
    // Compact prompt — smaller models perform better with concise instructions.
    return 'Emergency triage. Respond ONLY with JSON:\n'
        '{"severity_level":<1-5>,"required_services":["ambulance",...],'
        '"first_aid_focus":"<one sentence>","thinking_summary":"<one sentence>"}\n\n'
        'Rules: 5=life-threatening; include ambulance always; bias severity higher when uncertain.\n'
        'GPS: $location | Sensor: $severityHint/5 | Lang: $languageCode\n'
        'Emergency: "$transcript"';
  }

  static Map<String, dynamic>? _parseJSON(String raw) {
    try {
      var text = raw.trim();
      if (text.startsWith('```')) {
        final nl = text.indexOf('\n');
        if (nl >= 0) text = text.substring(nl + 1);
        final fence = text.lastIndexOf('```');
        if (fence >= 0) text = text.substring(0, fence).trim();
      }
      final s = text.indexOf('{');
      final e = text.lastIndexOf('}');
      if (s < 0 || e <= s) return null;
      final decoded = jsonDecode(text.substring(s, e + 1));
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }
}

final gemmaLocalServiceProvider = Provider<GemmaLocalService>(
  (ref) => GemmaLocalService._(),
);
