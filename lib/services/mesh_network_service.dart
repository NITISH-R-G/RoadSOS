import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:country_codes/country_codes.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'emergency_sms_dispatch_service.dart';
import 'sms_dispatch_outcome.dart';
import 'india_emergency_routing.dart';
import 'india_offline_dispatch.dart';
import 'scene_security_service.dart';
import '../logging/app_log.dart';

/// MeshNetworkService: BLE manufacturer-data SOS beacons + scan for peers.
///
/// Scanning runs while the app process is alive (dashboard opens [MeshRadar] too).
/// True background BLE on Android requires a foreground service — not bundled here.
class MeshNetworkService {
  final FlutterBlePeripheral _peripheral = FlutterBlePeripheral();

  final _discoveredBeaconsController = StreamController<List<String>>.broadcast();
  Stream<List<String>> get discoveredBeacons => _discoveredBeaconsController.stream;

  final List<String> _currentBeacons = [];

  StreamSubscription<List<ScanResult>>? _scanSubscription;
  Timer? _rescanTimer;
  bool _listeningStarted = false;

  DateTime? _lastSync;
  static const int _syncCooldownMinutes = 30;

  void dispose() {
    _rescanTimer?.cancel();
    _scanSubscription?.cancel();
    _scanSubscription = null;
    _listeningStarted = false;
    if (!_discoveredBeaconsController.isClosed) {
      _discoveredBeaconsController.close();
    }
    if (!kIsWeb) {
      _peripheral.stop();
      FlutterBluePlus.stopScan();
    }
  }

  /// Idempotent: one scan subscription + periodic rescans while app runs.
  Future<void> listenForSosBeacons() async => ensureListeningForPeers();

  Future<void> ensureListeningForPeers() async {
    if (kIsWeb) {
      return;
    }

    if (_listeningStarted) {
      await _runScanRound();
      return;
    }

    _listeningStarted = true;

    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      if (_discoveredBeaconsController.isClosed) return;

      var updated = false;
      for (final r in results) {
        if (r.advertisementData.manufacturerData.containsKey(0xFFFF)) {
          final id = r.device.remoteId.str;
          if (!_currentBeacons.contains(id)) {
            _currentBeacons.add(id);
            updated = true;
          }
        }
      }
      if (updated) _discoveredBeaconsController.add(List.unmodifiable(_currentBeacons));
    });

    await _runScanRound();

    _rescanTimer?.cancel();
    _rescanTimer = Timer.periodic(const Duration(seconds: 35), (_) async {
      if (_discoveredBeaconsController.isClosed) return;
      await _runScanRound();
    });
  }

  Future<void> _runScanRound() async {
    if (kIsWeb || _discoveredBeaconsController.isClosed) return;
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 30));
    } catch (e) {
      appLog.w('Failed to start BLE scan', e);
    }
  }

  /// Broadcasts an encrypted SOS payload over BLE. Returns whether advertising actually started.
  Future<bool> startBroadcasting(String payload, {double? lat, double? lng}) async {
    if (kIsWeb) {
      return false;
    }

    String finalPayload = payload;
    if (lat != null && lng != null) {
      final key = SceneSecurityService.generateSceneKey(lat, lng);
      finalPayload = SceneSecurityService.encryptPayload(payload, key);
      appLog.d('Mesh payload encrypted for scene privacy');
    }

    try {
      final supported = await _peripheral.isSupported;
      if (!supported) {
        appLog.w('BLE peripheral not supported on this device');
        return false;
      }
      final AdvertiseData advertiseData = AdvertiseData(
        manufacturerId: 0xFFFF,
        manufacturerData: Uint8List.fromList(utf8.encode(finalPayload)),
        includeDeviceName: false,
      );

      await _peripheral.start(advertiseData: advertiseData);
      appLog.d('BLE mesh advertising SOS payload');
      return true;
    } catch (e, st) {
      appLog.w('BLE advertising failed', e, st);
      return false;
    }
  }

  Future<void> stopBroadcasting() async {
    if (kIsWeb) return;
    await _peripheral.stop();
  }

  /// Android: direct [SEND_SMS]. iOS / India ERSS: set `SMS_DISPATCH_URL` / `INDIA_SOS_DISPATCH_URL` in `.env`.
  /// India: BLE mesh is sparse on highways — after SMS we offer **voice** [tel:108] and optional **USSD** when configured.
  Future<SmsDispatchOutcome> triggerSmsFallback(
    String payload, {
    double? lat,
    double? lng,
  }) async {
    final smsOutcome = await EmergencySmsDispatchService.dispatch(
      payload: payload,
      lat: lat,
      lng: lng,
    );

    if (kIsWeb) return smsOutcome;
    if (lat == null || lng == null) return smsOutcome;

    final inIndia = CountryCodes.getDeviceLocale()?.countryCode == 'IN' ||
        coordinatesRoughlyInIndia(lat, lng);
    if (!inIndia) return smsOutcome;

    await IndiaOfflineDispatch.launchConfiguredUssd(lat, lng);

    final rawAmbulance = dotenv.env['INDIA_AUTO_DIAL_AMBULANCE']?.trim();
    final dialAmbulance =
        rawAmbulance == null || rawAmbulance == 'true' || rawAmbulance == '1';
    if (dialAmbulance) {
      await IndiaOfflineDispatch.launchAmbulanceDeepLink(lat, lng);
    }

    return smsOutcome;
  }
}

final meshNetworkServiceProvider = Provider.autoDispose<MeshNetworkService>((ref) {
  final service = MeshNetworkService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Starts mesh RX once so peers are discovered even before opening Mesh Radar.
final meshListeningBootstrapProvider = FutureProvider<void>((ref) async {
  final mesh = ref.watch(meshNetworkServiceProvider);
  try {
    await mesh.ensureListeningForPeers();
  } catch (e, st) {
    appLog.w('Mesh listening bootstrap failed', e, st);
  }
});
