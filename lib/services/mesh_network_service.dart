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

    // NOTE: In a real-world scenario, continuous background scanning
    // requires careful permission handling and foreground services.
    // This is currently a simulated hook that should be expanded
    // with proper Android/iOS background workers.
    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (r.advertisementData.manufacturerData.containsKey(0xFFFF)) {
          final data = r.advertisementData.manufacturerData[0xFFFF]!;
          final message = utf8.decode(data);
          print('🚨 Found RoadSOS Beacon: $message');
          // Forward to cloud if internet available...
        }
      }
    });

    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    } catch (e) {
      print('⚠️ Failed to start BLE scan: $e');
    }
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

    // NOTE: This opens the SMS app but requires the user to press 'Send'.
    // In a fully-automated SOS app, you need SEND_SMS permission (Android)
    // or a backend API (Twilio) to send silently.
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
      print('📱 SMS dialer opened. User must press send manually.');
    } else {
      print('⚠️ Could not launch SMS dialer. Make sure the device supports SMS.');
    }
  }
}
