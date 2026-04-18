import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:country_codes/country_codes.dart';
import 'dart:convert';
import 'dart:typed_data';

class MeshNetworkService {
  final _peripheral = FlutterBlePeripheral();

  Future<void> broadcastSosPayload(String compressedPayload) async {
    if (kIsWeb) {
      print('BLE Mesh is not supported on Web. Bypassing broadcast.');
      return;
    }

    if (await _peripheral.isSupported) {
      final AdvertiseData advertiseData = AdvertiseData(
        serviceUuid: '0000FEAA-0000-1000-8000-00805F9B34FB', // Example Service UUID
        manufacturerId: 0xFFFF,
        manufacturerData: Uint8List.fromList(utf8.encode(compressedPayload)),
        includeDeviceName: true,
      );

      await _peripheral.start(advertiseData: advertiseData);
      print('📶 BLE Mesh Active: Advertising SOS payload...');
    } else {
      print('⚠️ BLE Peripheral mode not supported on this device.');
    }
  }

  Future<void> stopBroadcasting() async {
    await _peripheral.stop();
  }

  Future<void> listenForSosBeacons() async {
    if (kIsWeb) return;

    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (r.advertisementData.manufacturerData.containsKey(0xFFFF)) {
          final data = r.advertisementData.manufacturerData[0xFFFF]!;
          final message = utf8.decode(data);
          print('🚨 Found RoadSOS Beacon: $message');
          // TODO: Forward to cloud if internet available
        }
      }
    });

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
  }

  Future<void> triggerSmsFallback(String payload) async {
    String emergencyNumber = '112'; // Global default

    try {
      final countryCode = CountryCodes.getDeviceLocale()?.countryCode;
      if (countryCode == 'US' || countryCode == 'CA') {
        emergencyNumber = '911';
      } else if (countryCode == 'GB') {
        emergencyNumber = '999';
      }
    } catch (_) {
      // Fallback to 112
    }

    final Uri smsUri = Uri(
      scheme: 'sms',
      path: emergencyNumber,
      queryParameters: <String, String>{
        'body': 'URGENT ROAD SOS: $payload',
      },
    );

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      print('Could not launch SMS dialer');
    }
  }
}
