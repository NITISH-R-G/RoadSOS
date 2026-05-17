import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../logging/app_log.dart';
import 'emergency_orchestrator.dart' show voiceAssistantServiceProvider;
import 'first_aid_repository.dart';
import 'gemma_local_service.dart';

/// State of the Bystander Coach session.
enum BystanderCoachPhase { idle, listening, thinking, speaking, error }

class BystanderCoachTurn {
  BystanderCoachTurn({required this.role, required this.text, DateTime? at})
    : at = at ?? DateTime.now();

  /// 'bystander' for the helper at the scene, 'coach' for the AI agent.
  final String role;
  final String text;
  final DateTime at;
}

class BystanderCoachState {
  const BystanderCoachState({
    this.phase = BystanderCoachPhase.idle,
    this.turns = const <BystanderCoachTurn>[],
    this.partial = '',
    this.errorMessage,
    this.languageCode = 'en',
  });

  final BystanderCoachPhase phase;
  final List<BystanderCoachTurn> turns;
  final String partial;
  final String? errorMessage;
  final String languageCode;

  BystanderCoachState copyWith({
    BystanderCoachPhase? phase,
    List<BystanderCoachTurn>? turns,
    String? partial,
    Object? errorMessage = _sentinel,
    String? languageCode,
  }) {
    return BystanderCoachState(
      phase: phase ?? this.phase,
      turns: turns ?? this.turns,
      partial: partial ?? this.partial,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      languageCode: languageCode ?? this.languageCode,
    );
  }

  static const _sentinel = Object();
}

/// On-device Gemma 4 E4B "Bystander Coach" — talks a helper through CPR,
/// bleeding control, recovery position, etc. while EMS is en route.
///
/// Flow:
///   1. UI taps "Start listening" → STT captures bystander's situation.
///   2. We RAG over [FirstAidRepository] (top-K by token-score) to ground.
///   3. Gemma 4 E4B streams a short, calm, step-by-step reply in the user's
///      locale (Hindi/Eng/Tamil/etc).
///   4. TTS speaks the reply; UI shows transcript.
///   5. Loop — bystander can interrupt and ask follow-up.
///
/// Fail-open behaviour: when Gemma is not downloaded yet, we serve a
/// deterministic templated reply that quotes the matched corpus row directly.
/// The bystander always gets actionable guidance — model-missing is never fatal.
class BystanderCoachService extends StateNotifier<BystanderCoachState> {
  BystanderCoachService(this._ref) : super(const BystanderCoachState());

  final Ref _ref;
  final SpeechToText _stt = SpeechToText();
  bool _sttReady = false;

  static const String _systemPromptEn = '''
You are RoadSOS Bystander Coach, an AI helper guiding a non-medical person at a road accident scene in India until paramedics arrive.

Hard rules:
- ONE numbered step at a time, under 25 words.
- Plain words. No jargon.
- Always end with: "Tell me what you see now."
- If life-threatening (no breathing, severe bleeding): step 1 = call 108 immediately.
- Never give medication doses.
- Never tell them to drive the victim themselves unless explicitly asked.
- If unsure, say so and tell them to wait for 108/112.

Use the GROUNDING TEXT to stay accurate. Do not invent steps that are not supported.
''';

  Future<void> startSession({String languageCode = 'en'}) async {
    state = const BystanderCoachState().copyWith(
      phase: BystanderCoachPhase.idle,
      languageCode: languageCode,
      turns: <BystanderCoachTurn>[],
      partial: '',
      errorMessage: null,
    );
    final greeting = _greetingFor(languageCode);
    _appendTurn('coach', greeting);
    await _ref.read(voiceAssistantServiceProvider).speak(greeting);
  }

  Future<void> endSession() async {
    await _stopListeningSafely();
    await _ref.read(voiceAssistantServiceProvider).stopSpeaking();
    state = const BystanderCoachState();
  }

  /// Start a single STT capture turn.
  Future<void> startListening() async {
    if (state.phase == BystanderCoachPhase.listening) return;
    if (!_sttReady) {
      try {
        _sttReady = await _stt.initialize(
          onError: (e) => appLog.w('[BystanderCoach] STT error: ${e.errorMsg}'),
        );
      } catch (e, st) {
        appLog.w('[BystanderCoach] STT init failed', error: e, stackTrace: st);
        _sttReady = false;
      }
    }
    if (!_sttReady) {
      state = state.copyWith(
        phase: BystanderCoachPhase.error,
        errorMessage:
            'Microphone unavailable — tap the typed input instead and describe the scene.',
      );
      return;
    }

    state = state.copyWith(
      phase: BystanderCoachPhase.listening,
      partial: '',
      errorMessage: null,
    );

    var heard = '';
    await _stt.listen(
      listenFor: const Duration(seconds: 12),
      pauseFor: const Duration(seconds: 3),
      onResult: (r) {
        heard = r.recognizedWords;
        if (mounted) {
          state = state.copyWith(partial: heard);
        }
      },
    );

    await Future<void>.delayed(const Duration(seconds: 12));
    await _stopListeningSafely();

    final transcript = heard.trim();
    state = state.copyWith(partial: '');
    if (transcript.isEmpty) {
      state = state.copyWith(
        phase: BystanderCoachPhase.idle,
        errorMessage: 'Did not catch that — try again or type the description.',
      );
      return;
    }
    await submitTurn(transcript);
  }

  Future<void> _stopListeningSafely() async {
    try {
      if (_stt.isListening) await _stt.stop();
    } catch (_) {}
  }

  /// Accept typed input as a turn. Used as a fallback when STT is unavailable.
  Future<void> submitTurn(String transcript) async {
    _appendTurn('bystander', transcript);
    state = state.copyWith(phase: BystanderCoachPhase.thinking);

    final grounding = await _retrieveGrounding(transcript);

    final reply = await _generateReply(
      transcript: transcript,
      grounding: grounding,
      languageCode: state.languageCode,
    );

    _appendTurn('coach', reply);
    state = state.copyWith(phase: BystanderCoachPhase.speaking);

    try {
      await _ref.read(voiceAssistantServiceProvider).speak(reply);
    } catch (e, st) {
      appLog.d('[BystanderCoach] TTS speak failed', stackTrace: st);
    }
    state = state.copyWith(phase: BystanderCoachPhase.idle);
  }

  Future<String> _retrieveGrounding(String query) async {
    try {
      final text = await FirstAidRepository.instance.lookup(query);
      // Trim grounding to keep token budget reasonable for E4B.
      if (text.length <= 1400) return text;
      return text.substring(0, 1400);
    } catch (e, st) {
      appLog.d('[BystanderCoach] grounding lookup failed', stackTrace: st);
      return 'No grounding found — answer cautiously and recommend 108.';
    }
  }

  Future<String> _generateReply({
    required String transcript,
    required String grounding,
    required String languageCode,
  }) async {
    final localisedDirective = _localeDirective(languageCode);

    final prompt =
        '$_systemPromptEn\n$localisedDirective\n\nGROUNDING TEXT (verbatim from RoadSOS first-aid corpus):\n"""\n$grounding\n"""\n\nBYSTANDER MESSAGE:\n"""\n$transcript\n"""\n\nRespond with ONE numbered step, plain words, ≤25 words. End with: "Tell me what you see now."';

    String? out;
    try {
      final gemma = _ref.read(gemmaLocalServiceProvider);
      if (gemma.isAvailable) {
        out = await gemma.generate(prompt).timeout(const Duration(seconds: 12));
      }
    } catch (e, st) {
      appLog.d('[BystanderCoach] gemma generate failed', stackTrace: st);
    }

    out = out?.trim();
    if (out == null || out.isEmpty) {
      return _deterministicReply(transcript, grounding, languageCode);
    }
    return _postProcess(out);
  }

  String _deterministicReply(String transcript, String grounding, String lang) {
    final firstLine = grounding
        .split('\n')
        .firstWhere((l) => l.trim().startsWith('1)'), orElse: () => '');
    final step = firstLine.isEmpty
        ? 'Call 108 now and stay with the person. Keep them still.'
        : firstLine.replaceFirst('1)', '').trim();

    final tail = switch (lang) {
      'hi' => 'अभी क्या दिख रहा है मुझे बताइए।',
      'ta' => 'இப்போது என்ன தெரிகிறது என்று சொல்லுங்கள்.',
      'te' => 'ఇప్పుడు ఏమి కనిపిస్తుందో చెప్పండి.',
      _ => 'Tell me what you see now.',
    };
    return '1) $step $tail';
  }

  String _postProcess(String raw) {
    // Strip code fences / leading "Coach:" labels Gemma sometimes emits.
    var t = raw.replaceAll(RegExp(r'^```[a-z]*'), '').replaceAll('```', '');
    t = t.replaceAll(
      RegExp(r'^\s*(coach|assistant|response)\s*:\s*', caseSensitive: false),
      '',
    );
    // Hard cap to keep TTS short and readable on small screens.
    if (t.length > 360) t = '${t.substring(0, 360)}…';
    return t.trim();
  }

  String _greetingFor(String lang) {
    switch (lang) {
      case 'hi':
        return 'मैं RoadSOS कोच हूँ। एक काम एक बार में करेंगे। पहले बताइए — व्यक्ति होश में है क्या?';
      case 'ta':
        return 'நான் RoadSOS கோச். ஒரே நேரத்தில் ஒரு படி. முதலில் சொல்லுங்கள் — நபர் நினைவில் இருக்கிறாரா?';
      case 'te':
        return 'నేను RoadSOS కోచ్. ఒక్క మెట్టు ఒక్క సారి. మొదట చెప్పండి — వ్యక్తి స్పృహలో ఉన్నారా?';
      case 'bn':
        return 'আমি RoadSOS কোচ। এক বার এক পদক্ষেপ। প্রথমে বলুন — ব্যক্তি জ্ঞান আছে কি?';
      case 'mr':
        return 'मी RoadSOS कोच. एक वेळी एक पाऊल. आधी सांगा — व्यक्ती शुद्धीत आहे का?';
      default:
        return 'I am RoadSOS Coach. One step at a time. First — is the person responding?';
    }
  }

  String _localeDirective(String lang) {
    switch (lang) {
      case 'hi':
        return 'Respond in Hindi (Devanagari). Keep numbers in Arabic numerals.';
      case 'ta':
        return 'Respond in Tamil. Keep numbers in Arabic numerals.';
      case 'te':
        return 'Respond in Telugu. Keep numbers in Arabic numerals.';
      case 'bn':
        return 'Respond in Bengali. Keep numbers in Arabic numerals.';
      case 'mr':
        return 'Respond in Marathi (Devanagari). Keep numbers in Arabic numerals.';
      default:
        return 'Respond in plain English.';
    }
  }

  void _appendTurn(String role, String text) {
    final turns = List<BystanderCoachTurn>.from(state.turns)
      ..add(BystanderCoachTurn(role: role, text: text));
    state = state.copyWith(turns: turns);
  }

  @visibleForTesting
  bool get sttReady => _sttReady;
}

final bystanderCoachServiceProvider =
    StateNotifierProvider<BystanderCoachService, BystanderCoachState>((ref) {
      return BystanderCoachService(ref);
    });
