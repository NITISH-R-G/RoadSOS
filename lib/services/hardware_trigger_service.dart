<<<<<<< HEAD
=======
import '../logging/app_log.dart';
import 'dart:io' show Platform;

>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'emergency_orchestrator.dart';

/// Listens for native hardware button SOS trigger via MethodChannel.
///
<<<<<<< HEAD
/// Android: 3x Volume Up + 3x Volume Down within 2 seconds
/// iOS: 6x volume button presses within 2 seconds
=======
/// Android (in-app): 3× Volume Up + 3× Volume Down within 2 seconds — foreground only.
/// Android (global): enable RoadSOS under Settings → Accessibility (see `openAndroidAccessibilitySettings`).
/// iOS: volume observation only works while the app can control audio session; there is no public API
/// equivalent to Apple's system Crash Detection for third-party apps.
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
///
/// When triggered, invokes the full Emergency Orchestrator pipeline
/// instead of just toggling a boolean.
final hardwareTriggerServiceProvider = Provider<HardwareTriggerService>((ref) {
  return HardwareTriggerService(ref);
});

class HardwareTriggerService {
  static const MethodChannel _channel =
      MethodChannel('com.codestreak.roadsos/hardware_buttons');
  final Ref _ref;

  HardwareTriggerService(this._ref) {
    _initChannel();
  }

  void _initChannel() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'triggerSOS') {
<<<<<<< HEAD
        print('[HardwareTriggerService] 🚨 HARDWARE SOS TRIGGER DETECTED!');
=======
        appLog.w('Hardware SOS trigger detected');
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
        // Invoke the full emergency pipeline
        _ref.read(emergencyOrchestratorProvider.notifier).triggerSOS();
      }
    });
  }
<<<<<<< HEAD
=======

  /// Opens Android Accessibility settings so the user can enable [SosAccessibilityService].
  Future<void> openAndroidAccessibilitySettings() async {
    if (!Platform.isAndroid) return;
    await _channel.invokeMethod<void>('openAccessibilitySettings');
  }
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
}
