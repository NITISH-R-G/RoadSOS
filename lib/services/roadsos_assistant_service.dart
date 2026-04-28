import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'gemini_http.dart';

import '../logging/app_log.dart';

/// Cloud-first assistant (Gemini Flash). **No on-device LLM** — safe for low-RAM phones.
class AssistantState {
  final String lastResponse;
  final bool isThinking;
  final List<String> history;

  AssistantState({
    this.lastResponse = '',
    this.isThinking = false,
    this.history = const [],
  });

  AssistantState copyWith({
    String? lastResponse,
    bool? isThinking,
    List<String>? history,
  }) {
    return AssistantState(
      lastResponse: lastResponse ?? this.lastResponse,
      isThinking: isThinking ?? this.isThinking,
      history: history ?? this.history,
    );
  }
}

class RoadSosAssistantService extends StateNotifier<AssistantState> {
  RoadSosAssistantService() : super(AssistantState());

  String? _apiKey() {
    try {
      return dotenv.env['GEMINI_API_KEY']?.trim();
    } catch (_) {
      return null;
    }
  }

  Future<String> synthesizeTelemetry({
    required double maxG,
    required double speedDelta,
    required String impactVector,
    String languageCode = 'en',
  }) async {
    state = state.copyWith(isThinking: true);

    final fallback =
        _offlineTelemetryBrief(maxG, speedDelta, impactVector, languageCode);

    final key = _apiKey();
    if (kIsWeb || key == null || key.isEmpty) {
      state = state.copyWith(isThinking: false, lastResponse: fallback);
      return fallback;
    }

    try {
      final text = await generateGeminiFlashText(
        apiKey: key,
        prompt:
            '''Emergency telemetry brief for paramedics (max 20 words). Language: $languageCode (match if not English).
Max G=$maxG, Delta speed=$speedDelta km/h, Impact=$impactVector.
Output one line starting with "Brief:"''',
      );
      final result = text.trim().isEmpty ? fallback : text.trim();
      state = state.copyWith(isThinking: false, lastResponse: result);
      return result;
    } catch (e, st) {
      appLog.d('RoadSosAssistant synthesizeTelemetry fallback', e, st);
      state = state.copyWith(isThinking: false, lastResponse: fallback);
      return fallback;
    }
  }

  Future<String> getNextWitnessQuestion(
    String previousAnswer, {
    String languageCode = 'en',
  }) async {
    state = state.copyWith(isThinking: true);

    final fallback = _offlineWitnessQuestion(previousAnswer, languageCode);

    final key = _apiKey();
    if (kIsWeb || key == null || key.isEmpty) {
      state = state.copyWith(
        isThinking: false,
        lastResponse: fallback,
        history: [...state.history, previousAnswer, fallback],
      );
      return fallback;
    }

    try {
      final text = await generateGeminiFlashText(
        apiKey: key,
        prompt:
            '''Witness said (may be Hindi/regional mixed with English): "$previousAnswer"
Ask ONE short safety-critical follow-up question for a road crash. Language: $languageCode.
Max 25 words. No preamble.''',
      );
      final next = text.trim().isEmpty ? fallback : text.trim();
      state = state.copyWith(
        isThinking: false,
        lastResponse: next,
        history: [...state.history, previousAnswer, next],
      );
      return next;
    } catch (e, st) {
      appLog.d('RoadSosAssistant witness question fallback', e, st);
      state = state.copyWith(
        isThinking: false,
        lastResponse: fallback,
        history: [...state.history, previousAnswer, fallback],
      );
      return fallback;
    }
  }

  String _offlineTelemetryBrief(
    double maxG,
    double speedDelta,
    String impactVector,
    String languageCode,
  ) {
    if (languageCode == 'hi') {
      return 'संक्षेप: ${impactVector} प्रभाव, तेज मंदी — आंतरिक चोट संभव।';
    }
    return 'Brief: High-G $impactVector impact with severe deceleration. Possible internal trauma.';
  }

  String _offlineWitnessQuestion(String previous, String languageCode) {
    if (languageCode == 'hi') {
      return 'क्या वाहनों के पास तरल रिसाव या धुआँ दिखाई दे रहा है?';
    }
    return 'Are there any leaked fluids or smoke visible near the vehicles?';
  }
}

final roadsosAssistantProvider =
    StateNotifierProvider<RoadSosAssistantService, AssistantState>((ref) {
  return RoadSosAssistantService();
});
