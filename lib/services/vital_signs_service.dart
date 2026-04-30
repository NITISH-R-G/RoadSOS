import 'package:flutter_riverpod/flutter_riverpod.dart';

class VitalSigns {
  final int bpm;
  final int respiratoryRate;
  final double bloodOxygen;
  final String interpretation;
  final List<String> measures;
  final DateTime recordedAtUtc;
  final String source; // 'manual'

  VitalSigns({
    required this.bpm,
    required this.respiratoryRate,
    required this.bloodOxygen,
    required this.interpretation,
    required this.measures,
    required this.recordedAtUtc,
    this.source = 'manual',
  });
}

class _InterpretationResult {
  final String interpretation;
  final List<String> measures;

  _InterpretationResult({
    required this.interpretation,
    required this.measures,
  });
}

class VitalSignsService extends StateNotifier<VitalSigns?> {
  VitalSignsService() : super(null);

  void setManual({
    required int bpm,
    required int respiratoryRate,
    required double bloodOxygen,
  }) {
    final result = _interpret(
      bpm: bpm,
      respiratoryRate: respiratoryRate,
      bloodOxygen: bloodOxygen,
    );
    state = VitalSigns(
      bpm: bpm,
      respiratoryRate: respiratoryRate,
      bloodOxygen: bloodOxygen,
      interpretation: result.interpretation,
      measures: result.measures,
      recordedAtUtc: DateTime.now().toUtc(),
      source: 'manual',
    );
  }

  void clear() => state = null;

  _InterpretationResult _interpret({
    required int bpm,
    required int respiratoryRate,
    required double bloodOxygen,
  }) {
    final flags = <String>[];
    final measures = <String>[];
    
    if (bpm >= 120) {
      flags.add('very fast pulse');
      measures.add('Rest and monitor. If accompanied by chest pain or shortness of breath, seek emergency care immediately.');
    } else if (bpm <= 45) {
      flags.add('very slow pulse');
      measures.add('If feeling dizzy, weak, or fainting, call EMS immediately. Keep the person seated or lying down.');
    }
    
    if (respiratoryRate >= 24) {
      flags.add('rapid breathing');
      measures.add('Help the person sit upright. Encourage slow, deep breaths. If struggling for air, call EMS.');
    } else if (respiratoryRate <= 8) {
      flags.add('slow breathing');
      measures.add('Ensure the airway is clear. If breathing stops or becomes extremely shallow, begin CPR and call EMS.');
    }
    
    if (bloodOxygen < 90) {
      flags.add('low oxygen');
      measures.add('Provide supplemental oxygen if available. Seek immediate emergency medical attention.');
    } else if (bloodOxygen >= 90 && bloodOxygen < 94) {
      flags.add('borderline oxygen');
      measures.add('Monitor closely. If symptoms worsen or oxygen drops further, consult a doctor.');
    }

    String interpretation;
    if (flags.isEmpty) {
      interpretation = 'No immediate red flags detected from entered vitals.';
    } else {
      interpretation = 'Flagged: ${flags.join(', ')}. If unconscious, breathing abnormal, or bleeding heavily: treat as high severity and call EMS.';
    }

    return _InterpretationResult(
      interpretation: interpretation,
      measures: measures,
    );
  }

  // No custom dispose behavior.
}

final vitalSignsProvider = StateNotifierProvider.autoDispose<VitalSignsService, VitalSigns?>((ref) {
  return VitalSignsService();
});
