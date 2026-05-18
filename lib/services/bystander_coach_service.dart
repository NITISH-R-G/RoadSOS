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
///   2. Situation keywords are accumulated across turns to build a targeted
///      grounding query for the [FirstAidRepository] RAG corpus.
///   3. Full conversation history (up to [_maxHistoryTurns]) is injected into
///      the Gemma 4 E4B prompt so the model understands what has already been
///      said and gives the NEXT step — not the first step again.
///   4. Gemma 4 E4B streams a short, calm, step-by-step reply in the user's
///      locale (Hindi/Eng/Tamil/etc).
///   5. TTS speaks the reply; UI shows transcript.
///   6. Loop — bystander can interrupt and ask follow-up.
///
/// Fail-open behaviour: when Gemma is not downloaded yet, we serve a
/// deterministic templated reply that quotes the matched corpus row directly,
/// taking the current transcript into account. Model-missing is never fatal.
class BystanderCoachService extends StateNotifier<BystanderCoachState> {
  BystanderCoachService(this._ref) : super(const BystanderCoachState());

  final Ref _ref;
  final SpeechToText _stt = SpeechToText();
  bool _sttReady = false;

  /// Accumulated situation keywords from all user turns in this session.
  /// Used to enrich the grounding query so the RAG retrieval stays on-topic.
  final Set<String> _situationKeywords = {};

  /// Maximum number of prior turns to include in each Gemma prompt.
  /// Keeps the prompt within the E4B token budget (~2 048 tokens).
  static const int _maxHistoryTurns = 6;

  // ─── System prompt ────────────────────────────────────────────────────────

  static const String _systemPrompt = '''
You are RoadSOS Bystander Coach — an AI helper guiding a non-medical person at a road accident scene in India until paramedics arrive.

Hard rules:
- Give ONE numbered step per response (the immediate NEXT action), under 30 words.
- You MUST read the full conversation below and give the NEXT step — never repeat a step already given.
- Plain words. No medical jargon.
- Always end with: "Tell me what you see now."
- If life-threatening (no breathing, severe bleeding, unconscious): step 1 = "Call 108 immediately."
- Never give medication doses.
- Never tell them to drive the victim unless explicitly asked.
- If unsure, say: "Wait with the person and follow 108 dispatcher instructions."
- Ground every step in the GROUNDING TEXT. Do not invent steps not supported there.
''';

  // ─── Session lifecycle ────────────────────────────────────────────────────

  Future<void> startSession({String languageCode = 'en'}) async {
    _situationKeywords.clear();
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
    _situationKeywords.clear();
    state = const BystanderCoachState();
  }

  // ─── STT capture ──────────────────────────────────────────────────────────

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

  // ─── Core response loop ───────────────────────────────────────────────────

  /// Accept typed or STT input as a turn.
  Future<void> submitTurn(String transcript) async {
    // Extract keywords from this turn and accumulate across session.
    _extractKeywords(transcript);

    _appendTurn('bystander', transcript);
    state = state.copyWith(phase: BystanderCoachPhase.thinking);

    // Build an enriched grounding query from accumulated situation context.
    final groundingQuery = _buildGroundingQuery(transcript);
    final grounding = await _retrieveGrounding(groundingQuery);

    final reply = await _generateReply(
      latestTranscript: transcript,
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

  // ─── Keyword accumulation ─────────────────────────────────────────────────

  /// Extract situation-relevant keywords from a bystander message and
  /// accumulate them in [_situationKeywords] for better RAG retrieval.
  void _extractKeywords(String text) {
    final lower = text.toLowerCase();
    const medicalKeywords = <String>[
      'bleeding', 'blood', 'unconscious', 'breathing', 'pulse', 'cpr',
      'fracture', 'broken', 'burn', 'head injury', 'spine', 'neck',
      'chest', 'heart', 'choking', 'trapped', 'fire', 'smoke',
      'not moving', 'not breathing', 'not responding', 'pain',
      'swelling', 'wound', 'cut', 'scratch', 'bruise', 'dislocation',
      'sprain', 'seizure', 'stroke', 'diabetic', 'allergic', 'shock',
      'child', 'pregnant', 'elderly', 'motorbike', 'truck', 'car',
      'pedestrian', 'cyclist', 'road', 'highway', 'truck', 'collision',
    ];
    for (final kw in medicalKeywords) {
      if (lower.contains(kw)) {
        _situationKeywords.add(kw);
      }
    }
  }

  /// Build a rich grounding query combining the current transcript with
  /// accumulated session keywords so RAG retrieval stays on-topic.
  String _buildGroundingQuery(String latestTranscript) {
    final buf = StringBuffer(latestTranscript.trim());
    if (_situationKeywords.isNotEmpty) {
      buf.write(' ');
      buf.write(_situationKeywords.take(8).join(' '));
    }
    return buf.toString();
  }

  // ─── RAG grounding ────────────────────────────────────────────────────────

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

  // ─── Prompt construction ──────────────────────────────────────────────────

  /// Build a Gemma 4–compatible prompt that includes:
  ///   • System instructions
  ///   • Grounding text from the first-aid corpus
  ///   • Full conversation history (last [_maxHistoryTurns] turns)
  ///   • The latest bystander message as the current query
  String _buildPrompt({
    required String latestTranscript,
    required String grounding,
    required String languageCode,
  }) {
    final localisedDirective = _localeDirective(languageCode);
    final history = state.turns;

    // Collect only turns that are *before* the latest (already appended) bystander turn.
    // The last turn in state.turns is the bystander's latest message.
    // We include up to [_maxHistoryTurns] prior turns for context.
    final priorTurns = history.length > 1
        ? history.sublist(0, history.length - 1)
        : <BystanderCoachTurn>[];
    final historySlice = priorTurns.length > _maxHistoryTurns
        ? priorTurns.sublist(priorTurns.length - _maxHistoryTurns)
        : priorTurns;

    final buf = StringBuffer();
    buf.writeln(_systemPrompt);
    buf.writeln(localisedDirective);
    buf.writeln();
    buf.writeln('GROUNDING TEXT (from RoadSOS first-aid corpus — use this):');
    buf.writeln('"""');
    buf.writeln(grounding.trim());
    buf.writeln('"""');
    buf.writeln();

    if (historySlice.isNotEmpty) {
      buf.writeln('CONVERSATION SO FAR (most recent last):');
      for (final turn in historySlice) {
        final label = turn.role == 'coach' ? 'COACH' : 'BYSTANDER';
        buf.writeln('$label: ${turn.text.trim()}');
      }
      buf.writeln();
    }

    buf.writeln('BYSTANDER (current message):');
    buf.writeln(latestTranscript.trim());
    buf.writeln();
    buf.writeln(
      'COACH (give the NEXT step, one numbered item, ≤30 words, end with "Tell me what you see now."):',
    );

    return buf.toString();
  }

  // ─── Generation ───────────────────────────────────────────────────────────

  Future<String> _generateReply({
    required String latestTranscript,
    required String grounding,
    required String languageCode,
  }) async {
    final prompt = _buildPrompt(
      latestTranscript: latestTranscript,
      grounding: grounding,
      languageCode: languageCode,
    );

    String? out;
    try {
      final gemma = _ref.read(gemmaLocalServiceProvider);
      if (gemma.isAvailable) {
        out = await gemma
            .generate(prompt)
            .timeout(const Duration(seconds: 20));
      }
    } catch (e, st) {
      appLog.d('[BystanderCoach] gemma generate failed', stackTrace: st);
    }

    out = out?.trim();
    if (out == null || out.isEmpty) {
      return _deterministicReply(latestTranscript, grounding, languageCode);
    }
    return _postProcess(out);
  }

  // ─── Deterministic fallback ───────────────────────────────────────────────

  /// Smarter offline fallback: uses accumulated situation keywords to pick a
  /// relevant step from the grounding text, rather than always returning step 1.
  String _deterministicReply(String transcript, String grounding, String lang) {
    // Determine which step we should be on based on conversation depth.
    final bystanderTurnCount =
        state.turns.where((t) => t.role == 'bystander').length;

    // Try to find a numbered step matching the current situation.
    final lines = grounding.split('\n');
    String step = '';

    // Look for the most relevant numbered step in the grounding.
    if (bystanderTurnCount <= 1) {
      // First turn — life-threatening check or first grounding step.
      final lower = transcript.toLowerCase();
      final isLifeThreatening = lower.contains('not breathing') ||
          lower.contains('unconscious') ||
          lower.contains('not responding') ||
          lower.contains('bleeding heavily') ||
          lower.contains('no pulse');
      if (isLifeThreatening) {
        step = 'Call 108 immediately. Tell them the location and that the person is not responding.';
      } else {
        step = _extractStepN(lines, 1);
      }
    } else {
      // Subsequent turns — advance to the next logical step.
      final nextStep = (bystanderTurnCount).clamp(1, 6);
      step = _extractStepN(lines, nextStep);
      if (step.isEmpty) {
        step = _extractStepN(lines, 1);
      }
    }

    if (step.isEmpty) {
      step = 'Call 108 now and stay with the person. Keep them still and reassure them.';
    }

    final tail = switch (lang) {
      'hi' => 'अभी क्या दिख रहा है मुझे बताइए।',
      'ta' => 'இப்போது என்ன தெரிகிறது என்று சொல்லுங்கள்.',
      'te' => 'ఇప్పుడు ఏమి కనిపిస్తుందో చెప్పండి.',
      'bn' => 'এখন কী দেখছেন বলুন।',
      'mr' => 'आत्ता काय दिसतेय ते सांगा.',
      _ => 'Tell me what you see now.',
    };
    return '$step $tail';
  }

  /// Extract the Nth numbered step from grounding lines. Returns '' if not found.
  String _extractStepN(List<String> lines, int n) {
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('$n)') || trimmed.startsWith('$n.')) {
        final content = trimmed.replaceFirst(RegExp('^$n[).]\\s*'), '').trim();
        if (content.isNotEmpty) return content;
      }
    }
    return '';
  }

  // ─── Post-processing ──────────────────────────────────────────────────────

  String _postProcess(String raw) {
    // Strip code fences / leading "Coach:" labels Gemma sometimes emits.
    var t = raw.replaceAll(RegExp(r'^```[a-z]*'), '').replaceAll('```', '');
    t = t.replaceAll(
      RegExp(r'^\s*(coach|assistant|response)\s*:\s*', caseSensitive: false),
      '',
    );
    // Strip any "COACH:" prefix the model may prepend.
    t = t.replaceAll(RegExp(r'^COACH:\s*', caseSensitive: false), '');
    // Hard cap to keep TTS short and readable on small screens.
    if (t.length > 400) t = '${t.substring(0, 400)}…';
    return t.trim();
  }

  // ─── Locale helpers ───────────────────────────────────────────────────────

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
        return 'IMPORTANT: Respond entirely in Hindi (Devanagari script). Use Arabic numerals for step numbers.';
      case 'ta':
        return 'IMPORTANT: Respond entirely in Tamil. Use Arabic numerals for step numbers.';
      case 'te':
        return 'IMPORTANT: Respond entirely in Telugu. Use Arabic numerals for step numbers.';
      case 'bn':
        return 'IMPORTANT: Respond entirely in Bengali. Use Arabic numerals for step numbers.';
      case 'mr':
        return 'IMPORTANT: Respond entirely in Marathi (Devanagari script). Use Arabic numerals for step numbers.';
      default:
        return 'IMPORTANT: Respond in plain English only.';
    }
  }

  // ─── State helpers ────────────────────────────────────────────────────────

  void _appendTurn(String role, String text) {
    final turns = List<BystanderCoachTurn>.from(state.turns)
      ..add(BystanderCoachTurn(role: role, text: text));
    state = state.copyWith(turns: turns);
  }

  @visibleForTesting
  bool get sttReady => _sttReady;

  @visibleForTesting
  Set<String> get situationKeywords => Set.unmodifiable(_situationKeywords);
}

final bystanderCoachServiceProvider =
    StateNotifierProvider<BystanderCoachService, BystanderCoachState>((ref) {
      return BystanderCoachService(ref);
    });
