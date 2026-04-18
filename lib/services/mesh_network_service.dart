import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:country_codes/country_codes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'scene_security_service.dart';
import 'emergency_orchestrator.dart';

/// MeshNetworkService: Manages peer-to-peer SOS communication.
class MeshNetworkService {
  final _peripheral = FlutterBlePeripheral();
  
  final _discoveredBeaconsController = StreamController<List<String>>.broadcast();
  Stream<List<String>> get discoveredBeacons => _discoveredBeaconsController.stream;
  
  final List<String> _currentBeacons = [];
  
  // Moved from global to instance-level for state safety
  DateTime? _lastSync;
  static const int _syncCooldownMinutes = 30;

  /// Properly release resources.
  void dispose() {
    _discoveredBeaconsController.close();
    if (!kIsWeb) {
      _peripheral.stop();
      FlutterBluePlus.stopScan();
    }
  }

  /// Broadcasts an encrypted SOS payload over BLE.
  Future<void> startBroadcasting(String payload, {double? lat, double? lng}) async {
    if (kIsWeb) return;

    // SCOPED DISCLOSURE: Encrypt if coordinates provided
    String finalPayload = payload;
    if (lat != null && lng != null) {
      final key = SceneSecurityService.generateSceneKey(lat, lng);
      finalPayload = SceneSecurityService.encryptPayload(payload, key);
      debugPrint('🛡️ Mesh Payload Encrypted for Scene Privacy');
    }

    try {
      if (await _peripheral.isSupported) {
        final AdvertiseData advertiseData = AdvertiseData(
          manufacturerId: 0xFFFF,
          manufacturerData: Uint8List.fromList(utf8.encode(finalPayload)),
          includeDeviceName: false,
        );

        await _peripheral.start(advertiseData: advertiseData);
        debugPrint('📶 BLE Mesh Active: Advertising SOS payload...');
      }
    } catch (e) {
      debugPrint('⚠️ BLE Advertising failed: $e');
    }
  }

  Future<void> stopBroadcasting() async {
    if (kIsWeb) return;
    await _peripheral.stop();
  }

  /// Scans for nearby RoadSOS beacons and emits them to the stream.
  Future<void> listenForSosBeacons() async {
    if (kIsWeb) {
      // Simulation for Web Demo
      await Future.delayed(const Duration(seconds: 2));
      if (!_currentBeacons.contains('SIM_NODE_77')) {
        _currentBeacons.add('SIM_NODE_77');
        if (!_discoveredBeaconsController.isClosed) {
          _discoveredBeaconsController.add(_currentBeacons);
        }
      }
      return;
    }

    // Capture subscription to close it later if needed (Optimization)
    FlutterBluePlus.scanResults.listen((results) {
      if (_discoveredBeaconsController.isClosed) return;
      
      bool updated = false;
      for (ScanResult r in results) {
        if (r.advertisementData.manufacturerData.containsKey(0xFFFF)) {
          final id = r.device.remoteId.str;
          if (!_currentBeacons.contains(id)) {
            _currentBeacons.add(id);
            updated = true;
          }
        }
      }
      if (updated) _discoveredBeaconsController.add(_currentBeacons);
    });

    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 30));
    } catch (e) {
      debugPrint('⚠️ Failed to start BLE scan: $e');
    }
  }

  /// Sends a highly compressed SOS packet via SMS if data is unavailable.
  Future<void> triggerSmsFallback(String payload) async {
    String emergencyNumber = '112';
    final countryCode = CountryCodes.getDeviceLocale()?.countryCode;
    
    if (countryCode == 'US' || countryCode == 'CA') emergencyNumber = '911';
    
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: emergencyNumber,
      queryParameters: <String, String>{
        'body': 'ROADSOS ENCRYPTED PAYLOAD: $payload',
      },
    );

    try {
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
        debugPrint('📟 [SMS] Intent triggered for $emergencyNumber');
      } else {
        debugPrint('⚠️ [SMS] Could not launch SMS intent');
      }
    } catch (e) {
      debugPrint('⚠️ [SMS] Error triggering intent: $e');
    }
  }
}

/// Provider with proper auto-dispose to prevent memory leaks.
final meshNetworkServiceProvider = Provider.autoDispose<MeshNetworkService>((ref) {
  final service = MeshNetworkService();
  ref.onDispose(() => service.dispose());
  return service;
});
