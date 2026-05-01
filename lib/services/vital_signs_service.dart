import 'package:flutter_riverpod/flutter_riverpod.dart';

class VitalSigns {
  final int bpm;
  final int respiratoryRate;
  final double bloodOxygen;
  final String interpretation;
  final DateTime recordedAtUtc;
  final String source; // 'manual'

  VitalSigns({
    required this.bpm,
    required this.respiratoryRate,
    required this.bloodOxygen,
    required this.interpretation,
    required this.recordedAtUtc,
    this.source = 'manual',
  });
}

class VitalSignsService extends StateNotifier<VitalSigns?> {
  VitalSignsService() : super(null);

  void setManual({
    required int bpm,
    required int respiratoryRate,
    required double bloodOxygen,
  }) {
    final interpretation = _interpret(
      bpm: bpm,
      respiratoryRate: respiratoryRate,
      bloodOxygen: bloodOxygen,
    );
    state = VitalSigns(
      bpm: bpm,
      respiratoryRate: respiratoryRate,
      bloodOxygen: bloodOxygen,
      interpretation: interpretation,
      recordedAtUtc: DateTime.now().toUtc(),
      source: 'manual',
    );
  }

  void clear() => state = null;

  String _interpret({
    required int bpm,
    required int respiratoryRate,
    required double bloodOxygen,
  }) {
    final flags = <String>[];
    if (bpm >= 120) flags.add('very fast pulse');
    if (bpm <= 45) flags.add('very slow pulse');
    if (respiratoryRate >= 24) flags.add('rapid breathing');
    if (respiratoryRate <= 8) flags.add('slow breathing');
    if (bloodOxygen < 90) flags.add('low oxygen');
    if (bloodOxygen >= 90 && bloodOxygen < 94) flags.add('borderline oxygen');

    if (flags.isEmpty) return 'No immediate red flags detected from entered vitals.';
    return 'Flagged: ${flags.join(', ')}. If unconscious, breathing abnormal, or bleeding heavily: treat as high severity and call EMS.';
  }

  // No custom dispose behavior.
}

final vitalSignsProvider = StateNotifierProvider.autoDispose<VitalSignsService, VitalSigns?>((ref) {
  return VitalSignsService();
});
