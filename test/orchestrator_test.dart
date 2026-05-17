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

    test('copyWith preserves demo mode unless changed', () {
      const state = SOSState(isDemoMode: true);
      final newState = state.copyWith(phase: SOSPhase.dispatching);
      expect(newState.isDemoMode, true);
      expect(newState.copyWith(isDemoMode: false).isDemoMode, false);
    });
  });
}
