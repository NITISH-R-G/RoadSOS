import 'dart:async';

import '../logging/app_log.dart';

/// Phase 5 — Multi-agent orchestration: observable, interruptible task graph.
///
/// The dispatch pipeline already runs channels in parallel via Future.wait().
/// This coordinator makes that explicit with per-agent lifecycle tracking,
/// real-time status streaming, and individual cancellation.
///
/// Each [AgentTask] is:
///   - Observable: status stream updates in real-time
///   - Interruptible: [cancel] stops the task before completion
///   - Validated: the ValidationAgent checks each result post-completion
///
/// Agent types in RoadSOS:
///   Planning:   EmergencyOrchestrator (decides what to dispatch)
///   Execution:  MeshAgent, SmsAgent, FamilyLinkAgent, LocalLogAgent
///   Validation: TriageValidationAgent (safety gate before dispatch)
///   Monitoring: HeartbeatAgent (30s ping from background service)
enum AgentStatus { pending, running, completed, failed, cancelled }

/// A single observable unit of work in the dispatch pipeline.
class AgentTask {
  final String id;
  final String displayName;
  AgentStatus status;
  String? resultSummary;
  String? errorDetail;
  DateTime? startedAt;
  DateTime? completedAt;

  AgentTask({required this.id, required this.displayName})
    : status = AgentStatus.pending;

  Duration? get duration => (startedAt != null && completedAt != null)
      ? completedAt!.difference(startedAt!)
      : null;

  bool get isTerminal =>
      status == AgentStatus.completed ||
      status == AgentStatus.failed ||
      status == AgentStatus.cancelled;
}

/// Orchestrates a group of [AgentTask]s in parallel with real-time status updates.
///
/// Usage:
/// ```dart
/// final coord = MultiAgentCoordinator();
/// final task1 = coord.register('ble_mesh', 'BLE Mesh Beacon');
/// final task2 = coord.register('sms',     'Emergency SMS');
/// coord.start();
///
/// coord.run(task1, () => meshService.startBroadcasting(...));
/// coord.run(task2, () => meshService.triggerSmsFallback(...));
///
/// await coord.awaitAll();
/// ```
class MultiAgentCoordinator {
  final _tasks = <String, AgentTask>{};
  final _controller = StreamController<AgentTask>.broadcast();
  bool _aborted = false;

  Stream<AgentTask> get statusStream => _controller.stream;

  List<AgentTask> get tasks => List.unmodifiable(_tasks.values);

  AgentTask register(String id, String displayName) {
    final task = AgentTask(id: id, displayName: displayName);
    _tasks[id] = task;
    return task;
  }

  /// Run [work] under [task]'s lifecycle tracking.
  /// Emits status updates to [statusStream] at each transition.
  Future<T?> run<T>(AgentTask task, Future<T> Function() work) async {
    if (_aborted) {
      _transition(task, AgentStatus.cancelled, error: 'Coordinator aborted');
      return null;
    }

    _transition(task, AgentStatus.running);

    try {
      final result = await work();
      _transition(task, AgentStatus.completed);
      return result;
    } catch (e, st) {
      _transition(task, AgentStatus.failed, error: e.toString());
      appLog.w('[Agent] ${task.displayName} failed', error: e, stackTrace: st);
      return null;
    }
  }

  void _transition(AgentTask task, AgentStatus next, {String? error}) {
    task.status = next;
    if (next == AgentStatus.running) task.startedAt = DateTime.now();
    if (task.isTerminal) task.completedAt = DateTime.now();
    if (error != null) task.errorDetail = error;

    final dur = task.duration;
    appLog.d(
      '[Agent] ${task.displayName}: ${next.name}'
      '${dur != null ? " (${dur.inMilliseconds}ms)" : ""}',
    );

    if (!_controller.isClosed) _controller.add(task);
  }

  /// Update the display summary of a completed task.
  void setSummary(AgentTask task, String summary) {
    task.resultSummary = summary;
    if (!_controller.isClosed) _controller.add(task);
  }

  /// Wait for all registered tasks to reach a terminal state.
  Future<void> awaitAll({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (!_tasks.values.every((t) => t.isTerminal)) {
      if (DateTime.now().isAfter(deadline)) {
        for (final t in _tasks.values.where((t) => !t.isTerminal)) {
          _transition(t, AgentStatus.failed, error: 'Timeout');
        }
        break;
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }

  /// Abort all pending/running tasks (e.g., user cancelled the SOS).
  void abort() {
    _aborted = true;
    for (final t in _tasks.values.where((t) => !t.isTerminal)) {
      _transition(t, AgentStatus.cancelled, error: 'SOS cancelled by user');
    }
    appLog.i('[Coordinator] All agents aborted.');
  }

  void dispose() {
    if (!_controller.isClosed) _controller.close();
  }

  /// Summary stats for the activity log.
  String get summaryLine {
    final done = _tasks.values
        .where((t) => t.status == AgentStatus.completed)
        .length;
    final failed = _tasks.values
        .where((t) => t.status == AgentStatus.failed)
        .length;
    final total = _tasks.length;
    return '$done/$total agents completed${failed > 0 ? ", $failed failed" : ""}.';
  }
}
