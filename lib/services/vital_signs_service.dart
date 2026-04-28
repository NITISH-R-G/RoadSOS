import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VitalSigns {
  final int bpm;
  final int respiratoryRate;
  final double bloodOxygen;
  final String aiInterpretation;

  VitalSigns({
    required this.bpm,
    required this.respiratoryRate,
    required this.bloodOxygen,
    required this.aiInterpretation,
  });
}

class VitalSignsService extends StateNotifier<VitalSigns?> {
  Timer? _scanTimer;

  VitalSignsService() : super(null);

  void startScan() {
    _scanTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final bpm = 70 + (timer.tick % 40); // Simulate fluctuating heart rate
      final rr = 12 + (timer.tick % 8);
      
      String interpretation = "STABLE";
      if (bpm > 100) {
        interpretation = 'TACHYCARDIA DETECTED — monitor for shock.';
      }
      if (rr > 20) {
        interpretation = 'RAPID BREATHING — assist ventilation if trained.';
      }

      state = VitalSigns(
        bpm: bpm,
        respiratoryRate: rr,
        bloodOxygen: 98.0 - (timer.tick % 3),
        aiInterpretation: interpretation,
      );
    });
  }

  void stopScan() {
    _scanTimer?.cancel();
    state = null;
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    super.dispose();
  }
}

final vitalSignsProvider = StateNotifierProvider.autoDispose<VitalSignsService, VitalSigns?>((ref) {
  return VitalSignsService();
});
