import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'emergency_orchestrator.dart';

class ProactiveMonitorState {
  final bool isMonitoring;
  final String? destination;
  final DateTime? eta;
  final bool alertTriggered;

  ProactiveMonitorState({
    this.isMonitoring = false,
    this.destination,
    this.eta,
    this.alertTriggered = false,
  });

  ProactiveMonitorState copyWith({
    bool? isMonitoring,
    String? destination,
    DateTime? eta,
    bool? alertTriggered,
  }) {
    return ProactiveMonitorState(
      isMonitoring: isMonitoring ?? this.isMonitoring,
      destination: destination ?? this.destination,
      eta: eta ?? this.eta,
      alertTriggered: alertTriggered ?? this.alertTriggered,
    );
  }
}

class ProactiveMonitorService extends StateNotifier<ProactiveMonitorState> {
  ProactiveMonitorService(this._ref) : super(ProactiveMonitorState());

  final Ref _ref;
  Timer? _monitorTimer;
  Timer? _escalationTimer;

  @override
  void dispose() {
    _monitorTimer?.cancel();
    _escalationTimer?.cancel();
    super.dispose();
  }

  void startSafeWalk(String dest, Duration duration) {
    _monitorTimer?.cancel(); // Clear existing
    _escalationTimer?.cancel();
    
    state = state.copyWith(
      isMonitoring: true,
      destination: dest,
      eta: DateTime.now().add(duration),
      alertTriggered: false,
    );

    _monitorTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkSafety();
    });
  }

  void _checkSafety() {
    if (state.eta != null && DateTime.now().isAfter(state.eta!)) {
      _triggerCheckIn();
    }
  }

  void _triggerCheckIn() {
    state = state.copyWith(alertTriggered: true);

    // Give a grace window to confirm safety; then escalate to SOS.
    _escalationTimer?.cancel();
    _escalationTimer = Timer(const Duration(seconds: 60), () {
      // Only escalate if still in the alert state.
      if (!state.isMonitoring || !state.alertTriggered) return;
      _ref.read(emergencyOrchestratorProvider.notifier).triggerSOS();
    });
  }

  void endSafeWalk() {
    _monitorTimer?.cancel();
    _escalationTimer?.cancel();
    state = ProactiveMonitorState();
  }
}

final proactiveMonitorProvider = StateNotifierProvider.autoDispose<ProactiveMonitorService, ProactiveMonitorState>((ref) {
  return ProactiveMonitorService(ref);
});
