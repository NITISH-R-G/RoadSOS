import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart' as ble_adv;
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

class MeshPacket {
  final String senderId;
  final String payload;
  final int? rssi;
  final DateTime receivedAt;

  MeshPacket({
    required this.senderId,
    required this.payload,
    required this.receivedAt,
    this.rssi,
  });
}

/// MeshNetworkService: BLE manufacturer-data SOS beacons + scan for peers.
///
/// Scanning runs while the app process is alive (dashboard opens [MeshRadar] too).
/// True background BLE on Android requires a foreground service — not bundled here.
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
    if (!_packetsController.isClosed) {
      _packetsController.close();
    }
    if (!kIsWeb) {
      unawaited(_peripheral.stop());
      unawaited(FlutterBluePlus.stopScan());
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
        final md = r.advertisementData.manufacturerData[0xFFFF];
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
      appLog.w('Failed to start BLE scan', error: e);
    }
  }

  String? _tryDecodeUtf8(List<int> data) {
    try {
      // Manufacturer data is app-controlled; use permissive decoding (allow malformed).
      return utf8.decode(data, allowMalformed: true).trim();
    } catch (_) {
      return null;
    }
  }

  void _emitPacketDedup(String senderId, String payload, int? rssi) {
    final now = DateTime.now();

    // Prevent hot loops where scanResults repeats the same advertisement constantly.
    // Key is stable for identical payload per sender.
    final key = '$senderId|$payload';
    final last = _recentPacketDedup[key];
    if (last != null && now.difference(last).inMilliseconds < 2500) return;
    _recentPacketDedup[key] = now;

    // Prune occasionally.
    if (_recentPacketDedup.length > 300) {
      final cutoff = now.subtract(const Duration(minutes: 2));
      _recentPacketDedup.removeWhere((_, t) => t.isBefore(cutoff));
    }

    _packetsController.add(
      MeshPacket(
        senderId: senderId,
        payload: payload,
        rssi: rssi,
        receivedAt: now,
      ),
    );
  }

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
    }

    try {
      final supported = await _peripheral.isSupported;
      if (!supported) {
        appLog.w('BLE peripheral not supported on this device');
        return false;
      }
      final ble_adv.AdvertiseData advertiseData = ble_adv.AdvertiseData(
        manufacturerId: 0xFFFF,
        manufacturerData: Uint8List.fromList(utf8.encode(finalPayload)),
        includeDeviceName: false,
      );

      await _peripheral.start(advertiseData: advertiseData);
      appLog.d('BLE mesh advertising SOS payload');
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
final meshListeningBootstrapProvider = FutureProvider.autoDispose<void>((ref) async {
  final mesh = ref.watch(meshNetworkServiceProvider);
  try {
    await mesh.ensureListeningForPeers();
  } catch (e, st) {
    appLog.w('Mesh listening bootstrap failed', error: e, stackTrace: st);
  }
});
