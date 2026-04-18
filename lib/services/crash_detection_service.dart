import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'emergency_orchestrator.dart';

/// Real-time Crash Detection Service.
/// 
/// Monitors accelerometer data for high-G impact events characteristic of vehicle crashes.
class CrashDetectionService {
  final Ref _ref;
  StreamSubscription<UserAccelerometerEvent>? _subscription;
  
  // Thresholds (can be tuned)
  static const double crashThresholdG = 25.0; // Typical air-bag trigger is ~15-20G
  static const int cooldownMs = 5000;
  
  DateTime? _lastDetection;

  CrashDetectionService(this._ref);

  void startMonitoring() {
    _subscription?.cancel();
    _subscription = userAccelerometerEventStream().listen((UserAccelerometerEvent event) {
      final double totalG = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      
      if (totalG > crashThresholdG) {
        // NOTE: In a real app, this simple threshold triggers false positives (e.g. dropping phone).
        // You need to combine accelerometer with gyroscope (spin) and GPS (sudden deceleration).
        _handlePotentialCrash(totalG);
      }
    });
  }

  void stopMonitoring() {
    _subscription?.cancel();
  }

  void _handlePotentialCrash(double magnitude) {
    final now = DateTime.now();
    if (_lastDetection != null && now.difference(_lastDetection!).inMilliseconds < cooldownMs) {
      return;
    }

    _lastDetection = now;
    print('[CrashDetection] 🚨 HIGH-G IMPACT DETECTED: ${magnitude.toStringAsFixed(1)}m/s²');
    
    // Trigger the Emergency Orchestrator
    _ref.read(emergencyOrchestratorProvider.notifier).triggerSOS();
  }
}

final crashDetectionServiceProvider = Provider<CrashDetectionService>((ref) {
  return CrashDetectionService(ref);
});
