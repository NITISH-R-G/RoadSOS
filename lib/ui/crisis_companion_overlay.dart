import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/emergency_orchestrator.dart';
import '../services/gemma_assistant_service.dart';
=======
import 'package:roadsos/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/emergency_orchestrator.dart';
import '../services/app_locale_controller.dart';
import '../services/roadsos_assistant_service.dart';
import '../models/dispatch_channel_status.dart';
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41

class CrisisCompanionOverlay extends ConsumerWidget {
  const CrisisCompanionOverlay({super.key});

<<<<<<< HEAD
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sosState = ref.watch(emergencyOrchestratorProvider);
    final assistant = ref.watch(gemmaAssistantProvider);
=======
  String _honestStatusLine(SOSState state) {
    if (state.phase == SOSPhase.triaging) return 'TRIAGING…';
    if (state.dispatchChannels.isEmpty) return 'DISPATCH IN PROGRESS…';
    final anyOk = state.dispatchChannels.any((c) => c.lifecycle == DispatchChannelLifecycle.success);
    if (anyOk) return 'DISPATCH CONFIRMED (CHECK CHANNELS)';
    final anyInProgress =
        state.dispatchChannels.any((c) => c.lifecycle == DispatchChannelLifecycle.inProgress);
    return anyInProgress ? 'DISPATCH IN PROGRESS…' : 'NO DISPATCH CONFIRMATION';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sosState = ref.watch(emergencyOrchestratorProvider);
    final assistant = ref.watch(roadsosAssistantProvider);
    final l10n = AppLocalizations.of(context)!;
    final lang = ref.watch(appLocaleProvider).languageCode;
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41

    if (sosState.phase != SOSPhase.active && sosState.phase != SOSPhase.triaging) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 24,
      left: 24,
      right: 24,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
<<<<<<< HEAD
            color: Colors.black.withOpacity(0.9),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(color: Colors.blue.withOpacity(0.2), blurRadius: 20, spreadRadius: 5),
=======
            color: Colors.black.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
<<<<<<< HEAD
                  _buildGemmaAvatar(),
=======
                  _buildAssistantAvatar(),
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
<<<<<<< HEAD
                        const Text(
                          'GEMMA: CRISIS COMPANION',
                          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          assistant.lastResponse.isEmpty 
                            ? 'Breathe with me. I am monitoring your vital indicators.' 
                            : assistant.lastResponse,
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
=======
                        Text(
                          l10n.crisisCompanionTitle,
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w900,
                            fontSize: 10,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          assistant.lastResponse.isEmpty
                              ? l10n.crisisCompanionBreathing
                              : assistant.lastResponse,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (assistant.isThinking)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
<<<<<<< HEAD
                  child: LinearProgressIndicator(backgroundColor: Colors.white10, valueColor: AlwaysStoppedAnimation(Colors.blue)),
                ),
              const SizedBox(height: 16),
              _buildControlBar(ref),
=======
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation(Colors.blue),
                  ),
                ),
              const SizedBox(height: 16),
              _buildControlBar(ref, l10n, lang),
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
            ],
          ),
        ),
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildGemmaAvatar() {
=======
  Widget _buildAssistantAvatar() {
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const SweepGradient(colors: [Colors.blue, Colors.cyan, Colors.blue]),
<<<<<<< HEAD
        boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.5), blurRadius: 10)],
=======
        boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.5), blurRadius: 10)],
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
      ),
      child: const Center(child: Icon(Icons.psychology, color: Colors.white, size: 28)),
    );
  }

<<<<<<< HEAD
  Widget _buildControlBar(WidgetRef ref) {
=======
  Widget _buildControlBar(WidgetRef ref, AppLocalizations l10n, String lang) {
    final sosState = ref.watch(emergencyOrchestratorProvider);
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
<<<<<<< HEAD
          'HELP IS 4 MIN AWAY',
          style: TextStyle(color: Colors.green.withOpacity(0.7), fontWeight: FontWeight.bold, fontSize: 10),
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {}, // Mute
              icon: const Icon(Icons.mic_none, color: Colors.white54),
=======
          _honestStatusLine(sosState),
          style: TextStyle(
            color: Colors.green.withValues(alpha: 0.7),
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
        Row(
          children: [
            Tooltip(
              message: 'Voice capture is not available in this build.',
              child: IconButton(
                onPressed: null,
                icon: const Icon(Icons.mic_none, color: Colors.white54),
              ),
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
<<<<<<< HEAD
                ref.read(gemmaAssistantProvider.notifier).getNextWitnessQuestion('I am feeling dizzy');
=======
                ref.read(roadsosAssistantProvider.notifier).getNextWitnessQuestion(
                      'I am feeling dizzy',
                      languageCode: lang,
                    );
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white10,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
<<<<<<< HEAD
              child: const Text('TALK', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
=======
              child: Text(l10n.talkButton,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
            ),
          ],
        ),
      ],
    );
  }
}
