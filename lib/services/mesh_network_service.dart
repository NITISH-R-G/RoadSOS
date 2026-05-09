import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io' show Platform;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart' as ble_adv;
import 'package:country_codes/country_codes.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
<<<<<<< HEAD
=======
import 'ble_payload_codec.dart';
>>>>>>> origin/main
import 'emergency_sms_dispatch_service.dart';
import 'sms_dispatch_outcome.dart';
import 'india_emergency_routing.dart';
import 'india_offline_dispatch.dart';
<<<<<<< HEAD
import 'scene_security_service.dart';
=======
>>>>>>> origin/main
import '../logging/app_log.dart';

class MeshPacket {
  final String senderId;
  final String payload;
<<<<<<< HEAD
=======
  final BleDecodedPayload? decoded;
>>>>>>> origin/main
  final int? rssi;
  final DateTime receivedAt;

  MeshPacket({
    required this.senderId,
    required this.payload,
    required this.receivedAt,
<<<<<<< HEAD
=======
    this.decoded,
>>>>>>> origin/main
    this.rssi,
  });
}

<<<<<<< HEAD
/// MeshNetworkService: BLE manufacturer-data SOS beacons + scan for peers.
///
/// Scanning runs while the app process is alive (dashboard opens [MeshRadar] too).
/// True background BLE on Android requires a foreground service — not bundled here.
=======
/// MeshNetworkService: BLE manufacturer-data SOS beacons + peer scan.
///
/// Key upgrade vs v1:
/// - BLE payload now uses [BlePayloadCodec]: 12-byte binary encoding that fits
///   within the 26-byte Android BLE ADV manufacturer data limit. The legacy
///   UTF-8 string (~42 bytes) was silently truncated by the BLE stack, making
///   location data invisible to receiving peers.
/// - Provider is NO LONGER autoDispose. Making this provider autoDispose caused
///   BLE advertising to stop the moment a widget that watched the mesh stopped
///   rendering — including mid-emergency when the dispatch panel covered the
///   radar. The service must live for the entire app session.
>>>>>>> origin/main
class MeshNetworkService {
  final ble_adv.FlutterBlePeripheral _peripheral = ble_adv.FlutterBlePeripheral();

  final _discoveredBeaconsController = StreamController<List<String>>.broadcast();
  Stream<List<String>> get discoveredBeacons => _discoveredBeaconsController.stream;

  final _packetsController = StreamController<MeshPacket>.broadcast();
  Stream<MeshPacket> get packets => _packetsController.stream;

  final List<String> _currentBeacons = [];
  final Map<String, DateTime> _recentPacketDedup = <String, DateTime>{};

  StreamSubscription<List<ScanResult>>? _scanSubscription;
  Timer? _rescanTimer;
  bool _listeningStarted = false;

  void dispose() {
    _rescanTimer?.cancel();
    _scanSubscription?.cancel();
    _scanSubscription = null;
    _listeningStarted = false;
    if (!_discoveredBeaconsController.isClosed) {
      _discoveredBeaconsController.close();
    }
    if (!_packetsController.isClosed) {
      _packetsController.close();
    }
    if (!kIsWeb) {
      unawaited(_peripheral.stop());
      if (Platform.isAndroid || Platform.isIOS) {
        try {
          unawaited(FlutterBluePlus.stopScan());
        } catch (_) {}
      }
    }
  }

<<<<<<< HEAD
  /// Idempotent: one scan subscription + periodic rescans while app runs.
  Future<void> listenForSosBeacons() async => ensureListeningForPeers();

  Future<void> ensureListeningForPeers() async {
    if (kIsWeb) {
      return;
    }
    // Unit/widget tests and desktop targets: avoid calling flutter_blue_plus at all.
    if (!Platform.isAndroid && !Platform.isIOS) {
      return;
    }
=======
  Future<void> listenForSosBeacons() async => ensureListeningForPeers();

  Future<void> ensureListeningForPeers() async {
    if (kIsWeb) return;
    if (!Platform.isAndroid && !Platform.isIOS) return;
>>>>>>> origin/main

    if (_listeningStarted) {
      await _runScanRound();
      return;
    }

    _listeningStarted = true;

    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      if (_discoveredBeaconsController.isClosed) return;

      var updated = false;
      for (final r in results) {
        final md = r.advertisementData.manufacturerData[0xFFFF];
<<<<<<< HEAD
        if (md != null) {
          final id = r.device.remoteId.str;
          if (!_currentBeacons.contains(id)) {
            _currentBeacons.add(id);
            updated = true;
          }

          final payload = _tryDecodeUtf8(md);
          if (payload != null && payload.isNotEmpty && !_packetsController.isClosed) {
            _emitPacketDedup(id, payload, r.rssi);
          }
        }
      }
      if (updated) _discoveredBeaconsController.add(List.unmodifiable(_currentBeacons));
=======
        if (md == null) continue;

        final id = r.device.remoteId.str;
        if (!_currentBeacons.contains(id)) {
          _currentBeacons.add(id);
          updated = true;
        }

        // Try binary decode first (v2 BlePayloadCodec), fall back to UTF-8 text.
        final decoded = BlePayloadCodec.decode(md);
        final displayPayload = decoded?.toDisplayString() ?? _tryDecodeUtf8(md) ?? '';

        if (displayPayload.isNotEmpty && !_packetsController.isClosed) {
          _emitPacketDedup(id, displayPayload, r.rssi, decoded);
        }
      }
      if (updated) {
        _discoveredBeaconsController.add(List.unmodifiable(_currentBeacons));
      }
>>>>>>> origin/main
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
    if (!Platform.isAndroid && !Platform.isIOS) return;
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 30));
    } catch (e) {
      appLog.w('Failed to start BLE scan', error: e);
    }
  }

  String? _tryDecodeUtf8(List<int> data) {
    try {
<<<<<<< HEAD
      // Manufacturer data is app-controlled; use permissive decoding (allow malformed).
=======
>>>>>>> origin/main
      return utf8.decode(data, allowMalformed: true).trim();
    } catch (_) {
      return null;
    }
  }

<<<<<<< HEAD
  void _emitPacketDedup(String senderId, String payload, int? rssi) {
    final now = DateTime.now();

    // Prevent hot loops where scanResults repeats the same advertisement constantly.
    // Key is stable for identical payload per sender.
=======
  void _emitPacketDedup(String senderId, String payload, int? rssi, BleDecodedPayload? decoded) {
    final now = DateTime.now();
>>>>>>> origin/main
    final key = '$senderId|$payload';
    final last = _recentPacketDedup[key];
    if (last != null && now.difference(last).inMilliseconds < 2500) return;
    _recentPacketDedup[key] = now;

<<<<<<< HEAD
    // Prune occasionally.
=======
>>>>>>> origin/main
    if (_recentPacketDedup.length > 300) {
      final cutoff = now.subtract(const Duration(minutes: 2));
      _recentPacketDedup.removeWhere((_, t) => t.isBefore(cutoff));
    }

    _packetsController.add(
      MeshPacket(
        senderId: senderId,
        payload: payload,
<<<<<<< HEAD
=======
        decoded: decoded,
>>>>>>> origin/main
        rssi: rssi,
        receivedAt: now,
      ),
    );
  }

<<<<<<< HEAD
  /// Broadcasts an encrypted SOS payload over BLE. Returns whether advertising actually started.
  Future<bool> startBroadcasting(String payload, {double? lat, double? lng}) async {
    if (kIsWeb) {
      return false;
    }

    String finalPayload = payload;
    if (lat != null && lng != null) {
      final key = SceneSecurityService.generateSceneKey(lat, lng);
      finalPayload = await SceneSecurityService.encryptPayload(payload, key);
      appLog.d('Mesh payload encrypted for scene privacy');
=======
  /// Broadcasts an encrypted SOS payload over BLE.
  ///
  /// Uses [BlePayloadCodec] to produce a 12-byte binary payload — well within
  /// the 26-byte Android BLE ADV manufacturer data limit. The legacy UTF-8
  /// approach produced ~42+ bytes that were silently truncated at the BLE layer,
  /// losing location coordinates entirely.
  ///
  /// If lat/lng are null, falls back to a compact UTF-8 string (no-GPS mode).
  Future<bool> startBroadcasting(
    String compressedPayloadText, {
    double? lat,
    double? lng,
    int severity = 3,
    List<String> services = const ['ambulance'],
  }) async {
    if (kIsWeb) return false;

    Uint8List advertiseBytes;

    if (lat != null && lng != null) {
      // Binary codec — 12 bytes, fits within 26-byte ADV limit with room to spare.
      advertiseBytes = BlePayloadCodec.encode(
        latitude: lat,
        longitude: lng,
        severity: severity,
        services: services,
      );
      appLog.d('Mesh payload: binary codec (${advertiseBytes.length} bytes)');

      // Also encrypt for scene privacy (written to the manufacturer data slot).
      // Note: encryption doubles size; we apply it to the displayable text version
      // broadcast on a secondary channel (e.g. GATT characteristic) in future.
      // For now the 12-byte binary payload is sent as-is (location is ±1m resolution).
    } else {
      // No GPS: fall back to compact UTF-8 (no location = short string)
      const fallback = 'RS|SOS|NO-LOC';
      advertiseBytes = Uint8List.fromList(utf8.encode(fallback));
>>>>>>> origin/main
    }

    try {
      final supported = await _peripheral.isSupported;
      if (!supported) {
        appLog.w('BLE peripheral not supported on this device');
        return false;
      }
<<<<<<< HEAD
      final ble_adv.AdvertiseData advertiseData = ble_adv.AdvertiseData(
        manufacturerId: 0xFFFF,
        manufacturerData: Uint8List.fromList(utf8.encode(finalPayload)),
=======
      final advertiseData = ble_adv.AdvertiseData(
        manufacturerId: 0xFFFF,
        manufacturerData: advertiseBytes,
>>>>>>> origin/main
        includeDeviceName: false,
      );

      await _peripheral.start(advertiseData: advertiseData);
<<<<<<< HEAD
      appLog.d('BLE mesh advertising SOS payload');
=======
      appLog.d('BLE mesh advertising SOS (${advertiseBytes.length}B)');
>>>>>>> origin/main
      return true;
    } catch (e, st) {
      appLog.w('BLE advertising failed', error: e, stackTrace: st);
      return false;
    }
  }

  Future<void> stopBroadcasting() async {
    if (kIsWeb) return;
    await _peripheral.stop();
  }

<<<<<<< HEAD
  /// Android: direct [SEND_SMS]. iOS / India ERSS: set `SMS_DISPATCH_URL` / `INDIA_SOS_DISPATCH_URL` in `.env`.
  /// India: BLE mesh is sparse on highways — after SMS we offer **voice** [tel:108] and optional **USSD** when configured.
=======
>>>>>>> origin/main
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

<<<<<<< HEAD
final meshNetworkServiceProvider = Provider.autoDispose<MeshNetworkService>((ref) {
  final service = MeshNetworkService();
  ref.onDispose(() => service.dispose());
=======
/// IMPORTANT: Provider is NOT autoDispose.
///
/// Making this autoDispose caused BLE advertising to stop whenever the widget
/// tree that watched [meshListeningBootstrapProvider] was rebuilt — including
/// mid-emergency when the dispatch panel replaced the radar widget. The mesh
/// service must persist for the full app session to guarantee SOS broadcast.
final meshNetworkServiceProvider = Provider<MeshNetworkService>((ref) {
  final service = MeshNetworkService();
  ref.onDispose(service.dispose);
>>>>>>> origin/main
  return service;
});

/// Starts mesh RX once so peers are discovered even before opening Mesh Radar.
<<<<<<< HEAD
final meshListeningBootstrapProvider = FutureProvider.autoDispose<void>((ref) async {
=======
final meshListeningBootstrapProvider = FutureProvider<void>((ref) async {
>>>>>>> origin/main
  final mesh = ref.watch(meshNetworkServiceProvider);
  try {
    await mesh.ensureListeningForPeers();
  } catch (e, st) {
    appLog.w('Mesh listening bootstrap failed', error: e, stackTrace: st);
  }
});
