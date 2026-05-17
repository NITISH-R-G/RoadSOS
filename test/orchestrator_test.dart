import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:roadsos/services/emergency_orchestrator.dart';

void main() {
  group('SOSState Tests', () {
    test('Initial state should be idle', () {
      const state = SOSState();
      expect(state.phase, SOSPhase.idle);
      expect(state.isBystander, false);
    });

    test('copyWith should update phase correctly', () {
      const state = SOSState();
      final newState = state.copyWith(phase: SOSPhase.active);
      expect(newState.phase, SOSPhase.active);
    });

    test('incidentId should be persistent after copyWith', () {
      const state = SOSState(incidentId: 'test-123');
      final newState = state.copyWith(phase: SOSPhase.active);
      expect(newState.incidentId, 'test-123');
    });

    test('demo flag is explicit and persistent after copyWith', () {
      const state = SOSState(isDemo: true, incidentId: 'demo-123');
      final newState = state.copyWith(phase: SOSPhase.dispatching);
      expect(newState.isDemo, true);
      expect(newState.incidentId, 'demo-123');
    });
  });

  group('life-safety source guards', () {
    test('nearby services channel is not implemented as fake delayed success', () {
      final source = File('lib/services/emergency_orchestrator.dart').readAsStringSync();

      expect(source, isNot(contains("Future.delayed(const Duration(seconds: 3), () => true)")));
      expect(source, isNot(contains('Emergency alert broadcasted to nearby facilities and responders')));
      expect(source, isNot(contains('Demo: using simulated crash location and Gemma 4 triage output.')));
    });

    test('dashboard demo mode cannot invoke the live SOS pipeline directly', () {
      final source = File('lib/ui/dashboard.dart').readAsStringSync();
      final demoSection = source.substring(source.indexOf('Future<void> _runDemoMode'));

      expect(demoSection, contains('startDemoSos()'));
      expect(demoSection, isNot(contains('startSos(isBystander: true)')));
    });
  });
}
