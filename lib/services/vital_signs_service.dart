import 'package:flutter_riverpod/flutter_riverpod.dart';

<<<<<<< HEAD
=======
/// Manually-entered vital signs for bystander triage assistance.
///
/// SOURCE IS ALWAYS 'manual' — these are numbers a bystander reads/estimates
/// and enters. This is NOT camera-based rPPG or wearable data.
/// It exists to help bystanders communicate vitals to phone dispatchers.
>>>>>>> origin/main
class VitalSigns {
  final int bpm;
  final int respiratoryRate;
  final double bloodOxygen;
  final String interpretation;
  final DateTime recordedAtUtc;
<<<<<<< HEAD
  final String source; // 'manual'
=======

  /// Always 'manual' — values entered by a bystander, not from a sensor.
  final String source;
>>>>>>> origin/main

  VitalSigns({
    required this.bpm,
    required this.respiratoryRate,
    required this.bloodOxygen,
    required this.interpretation,
    required this.recordedAtUtc,
    this.source = 'manual',
  });
}

<<<<<<< HEAD
class VitalSignsService extends StateNotifier<VitalSigns?> {
  VitalSignsService() : super(null);

  void setManual({
=======
/// Bystander vital signs logger.
/// Stores manually-entered pulse, respiration, and SpO2 readings.
///
/// IMPORTANT: These values are manually entered by a bystander — NOT
/// measured by the phone camera or sensors. The app displays these values
/// to help relay information to emergency dispatchers (108/112).
class VitalSignsLogger extends StateNotifier<VitalSigns?> {
  VitalSignsLogger() : super(null);

  /// Records manually-entered vital sign observations.
  /// All three parameters must be provided by the bystander directly.
  void recordManual({
>>>>>>> origin/main
    required int bpm,
    required int respiratoryRate,
    required double bloodOxygen,
  }) {
<<<<<<< HEAD
    final interpretation = _interpret(
=======
    final interpretation = _interpretForDispatch(
>>>>>>> origin/main
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

<<<<<<< HEAD
  void clear() => state = null;

  String _interpret({
=======
  /// Produces a dispatcher-ready summary for relay to 108/112 operators.
  String? get dispatcherSummary {
    if (state == null) return null;
    final v = state!;
    return 'Vitals (bystander-observed): '
        'HR=${v.bpm}bpm RR=${v.respiratoryRate}/min SpO2=${v.bloodOxygen.toStringAsFixed(0)}% '
        '— ${v.interpretation}';
  }

  /// Alias used by VitalScanScreen.
  void setManual({
    required int bpm,
    required int respiratoryRate,
    required double bloodOxygen,
  }) =>
      recordManual(bpm: bpm, respiratoryRate: respiratoryRate, bloodOxygen: bloodOxygen);

  void clear() => state = null;

  String _interpretForDispatch({
>>>>>>> origin/main
    required int bpm,
    required int respiratoryRate,
    required double bloodOxygen,
  }) {
    final flags = <String>[];
<<<<<<< HEAD
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
=======
    if (bpm >= 120) flags.add('tachycardia (very fast pulse)');
    if (bpm <= 45) flags.add('bradycardia (very slow pulse)');
    if (respiratoryRate >= 24) flags.add('tachypnoea (rapid breathing)');
    if (respiratoryRate <= 8) flags.add('bradypnoea (slow breathing)');
    if (bloodOxygen < 90) flags.add('hypoxia (SpO2 <90% — CRITICAL)');
    if (bloodOxygen >= 90 && bloodOxygen < 94) flags.add('borderline oxygen (SpO2 90-93%)');

    if (flags.isEmpty) {
      return 'No immediately critical vital signs from bystander observation.';
    }
    return 'CRITICAL FLAGS: ${flags.join(', ')}. '
        'Treat as high severity. Call 108/112 now if not done.';
  }
}

// Keep backward-compatible alias used by existing UI code.
typedef VitalSignsService = VitalSignsLogger;

final vitalSignsProvider =
    StateNotifierProvider.autoDispose<VitalSignsLogger, VitalSigns?>((ref) {
  return VitalSignsLogger();
>>>>>>> origin/main
});
