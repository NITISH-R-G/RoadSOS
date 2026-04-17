import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';

final hardwareTriggerServiceProvider = Provider<HardwareTriggerService>((ref) {
  return HardwareTriggerService(ref);
});

class HardwareTriggerService {
  static const MethodChannel _channel = MethodChannel('com.codestreak.roadsos/hardware_buttons');
  final ProviderRef _ref;

  HardwareTriggerService(this._ref) {
    _initChannel();
  }

  void _initChannel() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'triggerSOS') {
        print('HARDWARE SOS TRIGGER DETECTED!');
        _ref.read(isSOSActiveProvider.notifier).state = true;
      }
    });
  }
}
