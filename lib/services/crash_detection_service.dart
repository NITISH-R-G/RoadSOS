import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../logging/app_log.dart';
import 'emergency_orchestrator.dart';
import 'crash_tuning.dart';

class _SpeedSample {
  final DateTime t;
  final double kmh;

  _SpeedSample(this.t, this.kmh);
}

/// Multi-stage crash detection inspired by consumer phone crash pipelines:
/// 1) Strong user-accelerometer spike (device frame, gravity removed).
/// 2) Pre-impact vehicle speed was at or above [minApproachSpeedKmh] (GPS).
/// 3) Within [postImpactWindow], speed collapses toward a stop (sudden deceleration).
/// 4) Sustained low motion variance on the user accelerometer (stillness — not a phone bouncing in a cabin or on a vibration road).
///
/// Values are **m/s²** on the accelerometer channel; they are **not** “G” despite common speech.
///
/// If GPS speed is unavailable, this service **does not** trigger SOS on accelerometry alone (avoids
/// pothole / drop-phone false positives on Indian roads).
class CrashDetectionService {
  CrashDetectionService(this._ref);

  final Ref _ref;

  StreamSubscription<UserAccelerometerEvent>? _accelSub;
  StreamSubscription<Position>? _positionSub;

  final List<_SpeedSample> _speedHistory = [];

  bool _gpsSpeedUsable = false;
  bool _evaluationInFlight = false;
  DateTime? _lastConfirmedSos;
  DateTime? _lastSpikeHandled;

  // All thresholds are env-configurable via [CrashTuning].

  void startMonitoring() {
    stopMonitoring();
    _startGpsSpeed();
    _accelSub =
        SensorsPlatform.instance.userAccelerometerEventStream().listen(_onAccelerometer);
  }

  Future<void> _startGpsSpeed() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _gpsSpeedUsable = false;
        appLog.d(
          'GPS permission denied — crash auto-SOS disabled (accel-only never used)',
        );
        return;
      }

      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        _gpsSpeedUsable = false;
        return;
      }

      _gpsSpeedUsable = true;

      final settings = const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
      );

      _positionSub = Geolocator.getPositionStream(
        locationSettings: settings,
      ).listen(
        _onPosition,
        onError: (_) => _gpsSpeedUsable = false,
      );
    } catch (_) {
      _gpsSpeedUsable = false;
    }
  }

  void _onPosition(Position p) {
    final ms = p.speed;
    if (ms.isNaN || ms < 0) return;
    final kmh = (ms * 3.6).clamp(0.0, 320.0);
    final now = DateTime.now();
    _speedHistory.add(_SpeedSample(now, kmh));
    final cutoff = now.subtract(
      Duration(milliseconds: CrashTuning.speedHistoryHorizonMs),
    );
    _speedHistory.removeWhere((s) => s.t.isBefore(cutoff));
  }

  void _onAccelerometer(UserAccelerometerEvent event) {
    final mag = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
    if (mag <= CrashTuning.impactThresholdMs2) return;

    final now = DateTime.now();
    if (_lastSpikeHandled != null &&
        now.difference(_lastSpikeHandled!).inMilliseconds <
            CrashTuning.interSpikeDebounceMs) {
      return;
    }
    _lastSpikeHandled = now;

    appLog.d('Impact spike ${mag.toStringAsFixed(1)} m/s² — evaluating');

    unawaited(_evaluateCrash(now, mag));
  }

  Future<void> _evaluateCrash(DateTime impactTime, double peakMs2) async {
    if (_evaluationInFlight) return;
    _evaluationInFlight = true;

    try {
      await Future.delayed(
        Duration(milliseconds: CrashTuning.postImpactWindowMs + 150),
      );

      if (!_gpsSpeedUsable || _speedHistory.length < 2) {
        appLog.d('Dismissed: insufficient GPS speed context');
        return;
      }

      final beforeStart = impactTime.subtract(
        Duration(milliseconds: CrashTuning.preImpactLookbackMs),
      );
      final beforeEnd = impactTime;
      final afterStart = impactTime;
      final afterEnd = impactTime.add(
        Duration(milliseconds: CrashTuning.postImpactWindowMs),
      );

      var maxBefore = 0.0;
      for (final s in _speedHistory) {
        if (!s.t.isBefore(beforeStart) && !s.t.isAfter(beforeEnd)) {
          if (s.kmh > maxBefore) maxBefore = s.kmh;
        }
      }

      var minAfter = double.infinity;
      for (final s in _speedHistory) {
        if (!s.t.isBefore(afterStart) && !s.t.isAfter(afterEnd)) {
          if (s.kmh < minAfter) minAfter = s.kmh;
        }
      }
      if (minAfter.isInfinite) {
        minAfter = _speedHistory.last.kmh;
      }

      final approach = maxBefore >= CrashTuning.minApproachSpeedKmh;
      final halted = minAfter <= CrashTuning.stoppedSpeedKmh;
      final sharpDrop =
          (maxBefore - minAfter) >= CrashTuning.suddenDecelDeltaKmh;

      if (!approach || !(halted || sharpDrop)) {
        appLog.d(
          'Dismissed: speed maxBefore=${maxBefore.toStringAsFixed(1)} '
          'minAfter=${minAfter.toStringAsFixed(1)} km/h (peak $peakMs2 m/s²)',
        );
        return;
      }

      final still = await _measureStillness();
      if (!still) {
        appLog.d(
          'Dismissed: motion continues after spike (not a wrecked-phone profile)',
        );
        return;
      }

      final now = DateTime.now();
      if (_lastConfirmedSos != null &&
          now.difference(_lastConfirmedSos!).inMilliseconds <
              CrashTuning.sosCooldownMs) {
        return;
      }
      _lastConfirmedSos = now;

      _ref.read(emergencyOrchestratorProvider.notifier).triggerSOS();
    } finally {
      _evaluationInFlight = false;
    }
  }

  /// Sample user acceleration for [stillnessSampleWindowMs]; low std-dev ⇒ device at rest.
  Future<bool> _measureStillness() async {
    final magnitudes = <double>[];
    final sub = SensorsPlatform.instance.userAccelerometerEventStream().listen((e) {
      magnitudes.add(sqrt(e.x * e.x + e.y * e.y + e.z * e.z));
    });

    await Future<void>.delayed(
      Duration(milliseconds: CrashTuning.stillnessSampleWindowMs),
    );
    await sub.cancel();

    if (magnitudes.length < 6) return false;

    final mean = magnitudes.reduce((a, b) => a + b) / magnitudes.length;
    var varSum = 0.0;
    for (final m in magnitudes) {
      final d = m - mean;
      varSum += d * d;
    }
    final std = sqrt(varSum / magnitudes.length);

    appLog.d(
      'Stillness σ=${std.toStringAsFixed(2)} m/s² (${magnitudes.length} samples)',
    );

    return std <= CrashTuning.stillnessStdDevMaxMs2;
  }

  void stopMonitoring() {
    _accelSub?.cancel();
    _accelSub = null;
    _positionSub?.cancel();
    _positionSub = null;
  }
}

final crashDetectionServiceProvider = Provider<CrashDetectionService>((ref) {
  return CrashDetectionService(ref);
});
