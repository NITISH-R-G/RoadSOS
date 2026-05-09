import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/emergency_orchestrator.dart';
<<<<<<< HEAD
import '../services/voice_assistant_service.dart';
=======
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41

/// SOSSideEffectObserver: Handles platform side-effects (TTS, Haptics) 
/// based on SOS state changes. Decouples UI logic from services.
class SOSSideEffectObserver extends ConsumerWidget {
  const SOSSideEffectObserver({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(emergencyOrchestratorProvider, (previous, next) {
      if (previous?.phase != next.phase) {
        _handlePhaseChange(ref, next.phase);
      }
    });

    return const SizedBox.shrink();
  }

  void _handlePhaseChange(WidgetRef ref, SOSPhase phase) {
    switch (phase) {
      case SOSPhase.active:
        HapticFeedback.heavyImpact();
        ref.read(voiceAssistantServiceProvider).speak(
          'SOS is live. Help is on the way. Your location and medical profile are being broadcasted.'
        );
        break;
      case SOSPhase.triaging:
        HapticFeedback.mediumImpact();
        break;
      case SOSPhase.countdown:
        HapticFeedback.lightImpact();
        break;
      default:
        break;
    }
  }
}
