import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:torch_light/torch_light.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logging/app_log.dart';

/// Professional Hardware SOS Beacon.
///
/// When active, the Gemma 4 agent takes over:
/// 1. Flashlight: Pulses international Morse Code SOS (... --- ...)
/// 2. Siren: Plays a piercing high-frequency locator tone at max volume.
class EmergencyBeaconService {
  EmergencyBeaconService._();
  static final EmergencyBeaconService instance = EmergencyBeaconService._();

  bool _isActive = false;
  Timer? _flashTimer;
  final AudioPlayer _player = AudioPlayer();

  bool get isActive => _isActive;

  /// Starts the hardware SOS beacon.
  /// This should be called by the EmergencyOrchestrator when SOSPhase becomes active.
  Future<void> start() async {
    if (_isActive) return;
    _isActive = true;
    appLog.i(
      '🚨 [BEACON] Hardware takeover initiated: SOS strobe + Siren active.',
    );

    _startFlashlightStrobe();
    _startSiren();
  }

  /// Stops all hardware SOS signals.
  Future<void> stop() async {
    if (!_isActive) return;
    _isActive = false;
    _flashTimer?.cancel();
    _flashTimer = null;

    try {
      await TorchLight.disableTorch();
    } catch (_) {}

    try {
      await _player.stop();
    } catch (_) {}

    appLog.i('✅ [BEACON] Hardware SOS signals disabled.');
  }

  // ── Flashlight Morse Code Logic ──────────────────────────────────────────

  void _startFlashlightStrobe() {
    _flashTimer?.cancel();

    // SOS Morse Pattern: ... --- ...
    // Dot = 200ms, Dash = 600ms, Gap = 200ms
    final pattern = [
      200, 200, 200, 200, 200, 400, // S (...)
      600, 200, 600, 200, 600, 400, // O (---)
      200, 200, 200, 200, 200, 2000, // S (...) + 2s rest
    ];

    int index = 0;

    void nextStep() {
      if (!_isActive) return;

      final duration = pattern[index];
      final isLightOn = index % 2 == 0;

      if (isLightOn) {
        _enableTorch();
      } else {
        _disableTorch();
      }

      index = (index + 1) % pattern.length;
      _flashTimer = Timer(Duration(milliseconds: duration), nextStep);
    }

    nextStep();
  }

  Future<void> _enableTorch() async {
    if (kIsWeb) return;
    try {
      await TorchLight.enableTorch();
    } catch (e) {
      appLog.w('[BEACON] Failed to enable torch', error: e);
    }
  }

  Future<void> _disableTorch() async {
    if (kIsWeb) return;
    try {
      await TorchLight.disableTorch();
    } catch (e) {
      appLog.w('[BEACON] Failed to disable torch', error: e);
    }
  }

  // ── Siren Locator Logic ──────────────────────────────────────────────────

  Future<void> _startSiren() async {
    try {
      // Note: User must add emergency_siren.mp3 to assets/audio/
      // and define it in pubspec.yaml for this to play.
      // If asset missing, it fails silently with a log.
      await _player.setAsset('assets/audio/emergency_siren.mp3');
      await _player.setLoopMode(LoopMode.one);
      await _player.setVolume(1.0); // 100% volume
      await _player.play();
    } catch (e) {
      appLog.d('[BEACON] Siren asset not found or failed to play: $e');
    }
  }

  void dispose() {
    stop();
    _player.dispose();
  }
}

final emergencyBeaconServiceProvider = Provider(
  (ref) => EmergencyBeaconService.instance,
);
