import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'emergency_orchestrator.dart';
import 'safe_walk_notification_service.dart';

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
<<<<<<< HEAD
    _monitorTimer?.cancel(); // Clear existing
    _escalationTimer?.cancel();
    
=======
    _monitorTimer?.cancel();
    _escalationTimer?.cancel();

>>>>>>> origin/main
    state = state.copyWith(
      isMonitoring: true,
      destination: dest,
      eta: DateTime.now().add(duration),
      alertTriggered: false,
    );

<<<<<<< HEAD
    _monitorTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
=======
    _monitorTimer = Timer.periodic(const Duration(seconds: 10), (_) {
>>>>>>> origin/main
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

    final dest = state.destination ?? 'your destination';
    final orchestrator = _ref.read(emergencyOrchestratorProvider.notifier);
    SafeWalkNotificationService.instance.ensureInitialized(
      orchestrator: orchestrator,
      monitor: this,
    );
    SafeWalkNotificationService.instance.showCheckInNow(destination: dest);
    SafeWalkNotificationService.instance.showForegroundDialogIfPossible(
      destination: dest,
      monitor: this,
    );

<<<<<<< HEAD
    // Give a grace window to confirm safety; then escalate to SOS.
    _escalationTimer?.cancel();
    _escalationTimer = Timer(const Duration(seconds: 60), () {
      // Only escalate if still in the alert state.
=======
    _escalationTimer?.cancel();
    _escalationTimer = Timer(const Duration(seconds: 60), () {
>>>>>>> origin/main
      if (!state.isMonitoring || !state.alertTriggered) return;
      _ref.read(emergencyOrchestratorProvider.notifier).triggerSOS();
    });
  }

<<<<<<< HEAD
  /// User explicitly confirmed they're safe.
=======
>>>>>>> origin/main
  void confirmImSafe() {
    if (!state.isMonitoring) return;
    _escalationTimer?.cancel();
    state = state.copyWith(alertTriggered: false);
    SafeWalkNotificationService.instance.cancelCheckInNotification();
  }

<<<<<<< HEAD
  /// User explicitly wants SOS now from the check-in prompt.
=======
>>>>>>> origin/main
  void escalateToSosNow() {
    if (!state.isMonitoring) return;
    SafeWalkNotificationService.instance.cancelCheckInNotification();
    _ref.read(emergencyOrchestratorProvider.notifier).triggerSOS();
  }

  void endSafeWalk() {
    _monitorTimer?.cancel();
    _escalationTimer?.cancel();
    SafeWalkNotificationService.instance.cancelCheckInNotification();
    state = ProactiveMonitorState();
  }
}

<<<<<<< HEAD
final proactiveMonitorProvider = StateNotifierProvider.autoDispose<ProactiveMonitorService, ProactiveMonitorState>((ref) {
=======
/// IMPORTANT: NOT autoDispose.
///
/// The previous autoDispose caused the safe-walk escalation timer to be killed
/// whenever any widget watching this provider was rebuilt or removed from the
/// widget tree — e.g., when the user navigated from Dashboard to Settings.
/// The escalation must survive widget lifecycle changes to guarantee the 60s
/// SOS escalation fires even when the app is in the background.
final proactiveMonitorProvider =
    StateNotifierProvider<ProactiveMonitorService, ProactiveMonitorState>((ref) {
>>>>>>> origin/main
  return ProactiveMonitorService(ref);
});
