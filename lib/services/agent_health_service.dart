import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../logging/app_log.dart';
import 'connectivity_service.dart';
import 'gemma_local_service.dart';

/// Phase 4 — Agent health check service.
///
/// Performs a non-blocking readiness probe of the five dispatch agents
/// and reports their status as [AgentHealthSnapshot]. Used by the status
/// indicator to show users whether the system is ready before a crash
/// happens, not after.
///
/// Health levels:
///   [AgentReadiness.ready]       — fully operational
///   [AgentReadiness.degraded]    — functional with reduced capability
///   [AgentReadiness.unavailable] — offline or permission denied
///
/// Probes are designed to be cheap (< 20ms each) and safe to call frequently.
enum AgentReadiness { ready, degraded, unavailable }

class AgentHealthSnapshot {
  final AgentReadiness gemmaCloud;
  final AgentReadiness gemmaOnDevice;
  final AgentReadiness gps;
  final AgentReadiness sms;
  final AgentReadiness ble;
  final DateTime checkedAt;

  const AgentHealthSnapshot({
    required this.gemmaCloud,
    required this.gemmaOnDevice,
    required this.gps,
    required this.sms,
    required this.ble,
    required this.checkedAt,
  });

  /// True if GPS is reachable — minimum requirement for location-based SOS.
  bool get canDispatch => gps != AgentReadiness.unavailable;

  /// True if at least one AI inference tier is ready.
  bool get hasAiCapability =>
      gemmaCloud != AgentReadiness.unavailable ||
      gemmaOnDevice != AgentReadiness.unavailable;

  /// Overall system readiness for a one-line UI label.
  String get summaryLabel {
    if (canDispatch && hasAiCapability) return 'All systems ready';
    if (canDispatch) return 'Ready — AI offline (heuristic fallback)';
    return 'GPS unavailable — check location permission';
  }

  AgentHealthSnapshot copyWith({
    AgentReadiness? gemmaCloud,
    AgentReadiness? gemmaOnDevice,
    AgentReadiness? gps,
    AgentReadiness? sms,
    AgentReadiness? ble,
  }) => AgentHealthSnapshot(
    gemmaCloud: gemmaCloud ?? this.gemmaCloud,
    gemmaOnDevice: gemmaOnDevice ?? this.gemmaOnDevice,
    gps: gps ?? this.gps,
    sms: sms ?? this.sms,
    ble: ble ?? this.ble,
    checkedAt: DateTime.now(),
  );
}

class AgentHealthService {
  final Ref _ref;
  Timer? _pollTimer;
  AgentHealthSnapshot _last = AgentHealthSnapshot(
    gemmaCloud: AgentReadiness.degraded,
    gemmaOnDevice: AgentReadiness.unavailable,
    gps: AgentReadiness.degraded,
    sms: AgentReadiness.degraded,
    ble: AgentReadiness.degraded,
    checkedAt: DateTime(2000),
  );

  final _controller = StreamController<AgentHealthSnapshot>.broadcast();

  AgentHealthService(this._ref);

  AgentHealthSnapshot get current => _last;
  Stream<AgentHealthSnapshot> get stream => _controller.stream;

  void startPolling({Duration interval = const Duration(seconds: 30)}) {
    _pollTimer?.cancel();
    unawaited(check());
    _pollTimer = Timer.periodic(interval, (_) => unawaited(check()));
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<AgentHealthSnapshot> check() async {
    final results = await Future.wait<AgentReadiness>([
      _checkGemmaCloud(),
      _checkGemmaOnDevice(),
      _checkGps(),
      _checkSms(),
      _checkBle(),
    ]);

    _last = AgentHealthSnapshot(
      gemmaCloud: results[0],
      gemmaOnDevice: results[1],
      gps: results[2],
      sms: results[3],
      ble: results[4],
      checkedAt: DateTime.now(),
    );

    appLog.d(
      '[HealthCheck] cloud=${_last.gemmaCloud.name} '
      'onDevice=${_last.gemmaOnDevice.name} '
      'gps=${_last.gps.name} '
      'sms=${_last.sms.name} '
      'ble=${_last.ble.name}',
    );

    if (!_controller.isClosed) _controller.add(_last);
    return _last;
  }

  Future<AgentReadiness> _checkGemmaCloud() async {
    final connectivity = _ref.read(connectivityServiceProvider);
    return switch (connectivity.currentQuality) {
      NetworkQuality.wifi => AgentReadiness.ready,
      NetworkQuality.cellular => AgentReadiness.ready,
      NetworkQuality.none => AgentReadiness.unavailable,
    };
  }

  Future<AgentReadiness> _checkGemmaOnDevice() async {
    final gemma = _ref.read(gemmaLocalServiceProvider);
    if (gemma.isAvailable) return AgentReadiness.ready;
    if (gemma.isInitialized) return AgentReadiness.unavailable;
    return AgentReadiness.degraded; // still loading
  }

  Future<AgentReadiness> _checkGps() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return AgentReadiness.unavailable;
      final perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return AgentReadiness.unavailable;
      }
      return AgentReadiness.ready;
    } catch (_) {
      return AgentReadiness.degraded;
    }
  }

  Future<AgentReadiness> _checkSms() async {
    try {
      // Primary: server relay (Twilio / Edge) — no Android SEND_SMS required.
      final relayUrl = dotenv.env['SMS_DISPATCH_URL']?.trim() ?? '';
      final relayKey = dotenv.env['SMS_DISPATCH_ANON_KEY']?.trim() ?? '';
      if (relayUrl.isNotEmpty && relayKey.isNotEmpty) {
        return AgentReadiness.ready;
      }

      // Fallback: open SMS app intent (no permission). If relay isn't configured,
      // we mark this as degraded (still usable, but requires user interaction).
      return AgentReadiness.degraded;
    } catch (_) {
      return AgentReadiness.degraded;
    }
  }

  Future<AgentReadiness> _checkBle() async {
    try {
      final status = await Permission.bluetooth.status;
      return status.isGranted ? AgentReadiness.ready : AgentReadiness.degraded;
    } catch (_) {
      return AgentReadiness.degraded;
    }
  }

  void dispose() {
    stopPolling();
    if (!_controller.isClosed) _controller.close();
  }
}

final agentHealthServiceProvider = Provider<AgentHealthService>((ref) {
  final svc = AgentHealthService(ref);
  ref.onDispose(svc.dispose);
  return svc;
});
