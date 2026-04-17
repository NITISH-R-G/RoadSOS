import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'emergency_orchestrator.dart';

/// Listens for native hardware button SOS trigger via MethodChannel.
///
/// Android: 3x Volume Up + 3x Volume Down within 2 seconds
/// iOS: 6x volume button presses within 2 seconds
///
/// When triggered, invokes the full Emergency Orchestrator pipeline
/// instead of just toggling a boolean.
final hardwareTriggerServiceProvider = Provider<HardwareTriggerService>((ref) {
  return HardwareTriggerService(ref);
});

class HardwareTriggerService {
  static const MethodChannel _channel =
      MethodChannel('com.codestreak.roadsos/hardware_buttons');
  final ProviderRef _ref;

  HardwareTriggerService(this._ref) {
    _initChannel();
  }

  void _initChannel() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'triggerSOS') {
        print('[HardwareTriggerService] 🚨 HARDWARE SOS TRIGGER DETECTED!');
        // Invoke the full emergency pipeline
        _ref.read(emergencyOrchestratorProvider.notifier).triggerSOS();
      }
    });
  }
}
