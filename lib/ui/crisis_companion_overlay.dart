import 'package:flutter/material.dart';
import 'package:roadsos/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/emergency_orchestrator.dart';
import '../services/app_locale_controller.dart';
import '../services/roadsos_assistant_service.dart';

class CrisisCompanionOverlay extends ConsumerWidget {
  const CrisisCompanionOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sosState = ref.watch(emergencyOrchestratorProvider);
    final assistant = ref.watch(roadsosAssistantProvider);
    final l10n = AppLocalizations.of(context)!;
    final lang = ref.watch(appLocaleProvider).languageCode;

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
            color: Colors.black.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _buildAssistantAvatar(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (assistant.isThinking)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation(Colors.blue),
                  ),
                ),
              const SizedBox(height: 16),
              _buildControlBar(ref, l10n, lang),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssistantAvatar() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const SweepGradient(colors: [Colors.blue, Colors.cyan, Colors.blue]),
        boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.5), blurRadius: 10)],
      ),
      child: const Center(child: Icon(Icons.psychology, color: Colors.white, size: 28)),
    );
  }

  Widget _buildControlBar(WidgetRef ref, AppLocalizations l10n, String lang) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l10n.helpEtaPlaceholder,
          style: TextStyle(
            color: Colors.green.withValues(alpha: 0.7),
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.mic_none, color: Colors.white54),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                ref.read(roadsosAssistantProvider.notifier).getNextWitnessQuestion(
                      'I am feeling dizzy',
                      languageCode: lang,
                    );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white10,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text(l10n.talkButton,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
  }
}
