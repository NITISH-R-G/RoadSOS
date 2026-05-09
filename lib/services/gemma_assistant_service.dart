import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State of the Gemma Assistant Interaction
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

/// GemmaAssistantService: The intelligence layer for RoadSOS V4.0.
///
/// Handles complex reasoning tasks like telemetry synthesis and
/// conversational witness reporting.
class GemmaAssistantService extends StateNotifier<AssistantState> {
  GemmaAssistantService() : super(AssistantState());

  /// Synthesizes raw telemetry into a human-readable brief for responders.
  Future<String> synthesizeTelemetry({
    required double maxG,
    required double speedDelta,
    required String impactVector,
  }) async {
    state = state.copyWith(isThinking: true);

    // In production, this calls the local Gemma 4 model or cloud fallback.
    await Future.delayed(const Duration(seconds: 1));
    final String result =
        'Brief: High-G $impactVector impact with severe deceleration. '
        'Possible internal trauma.';

    state = state.copyWith(isThinking: false, lastResponse: result);
    return result;
  }

  /// Guides a witness through a multi-step situational report.
  Future<String> getNextWitnessQuestion(String previousAnswer) async {
    state = state.copyWith(isThinking: true);

    // In production, this calls the local Gemma 4 model or cloud fallback.
    await Future.delayed(const Duration(milliseconds: 800));
    const String nextQuestion =
        'Are there any leaked fluids or smoke visible near the vehicles?';

    state = state.copyWith(
      isThinking: false,
      lastResponse: nextQuestion,
      history: [...state.history, previousAnswer, nextQuestion],
    );
    return nextQuestion;
  }
}

final gemmaAssistantProvider =
    StateNotifierProvider<GemmaAssistantService, AssistantState>((ref) {
  return GemmaAssistantService();
});