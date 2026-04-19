import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:cryptography/cryptography.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:country_codes/country_codes.dart';
import 'dart:convert';
import 'dart:typed_data';

class MeshNetworkService {
  final _peripheral = FlutterBlePeripheral();
  final _algorithm = AesGcm.with256bits();
  
  // In production, this key would be rotated and synced via cloud or DKG
  final _secretKey = SecretKey([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32]);

  Future<void> broadcastSosPayload(String compressedPayload) async {
    if (kIsWeb) {
      print('BLE Mesh is not supported on Web. Bypassing broadcast.');
      return;
    }

    if (await _peripheral.isSupported) {
      // 1. Encrypt payload for Privacy
      final cleartext = utf8.encode(compressedPayload);
      final nonce = _algorithm.newNonce();
      final secretBox = await _algorithm.encrypt(
        cleartext,
        secretKey: _secretKey,
        nonce: nonce,
      );
      
      // Combine Nonce + Ciphertext (GCM tag included in secretBox.concatenation)
      final encryptedPayload = Uint8List.fromList(secretBox.concatenation(nonce: true));

      final AdvertiseData advertiseData = AdvertiseData(
        serviceUuid: '0000FEAA-0000-1000-8000-00805F9B34FB',
        manufacturerId: 0xFFFF,
        manufacturerData: encryptedPayload,
        includeDeviceName: false, // Privacy: don't include device name
      );

      await _peripheral.start(advertiseData: advertiseData);
      print('📶 BLE Mesh Active: Advertising ENCRYPTED SOS payload...');
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
<<<<<<< Updated upstream
        if (r.advertisementData.manufacturerData.containsKey(0xFFFF)) {
          final data = r.advertisementData.manufacturerData[0xFFFF]!;
          final message = utf8.decode(data);
          print('🚨 Found RoadSOS Beacon: $message');
          // Forward to cloud if internet available...
=======
        // Check manufacturer data for RoadSOS signature (Example ID 0xFFFF)
        if (r.advertisementData.manufacturerData.containsKey(0xFFFF)) {
          final rawData = r.advertisementData.manufacturerData[0xFFFF]!;
          final payload = utf8.decode(rawData);
          
          print('🚨 Found RoadSOS SOS Beacon from mesh! Payload: $payload');
          
          // Relay logic: Try to sync to cloud
          _relaySosToCloud(payload, r.device.remoteId.str);
>>>>>>> Stashed changes
        }
      }
    });

    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    } catch (e) {
      print('⚠️ Failed to start BLE scan: $e');
    }
  }

  Future<void> _relaySosToCloud(String payload, String deviceId) async {
    print('📡 Relaying mesh payload from $deviceId to cloud...');
    // In a real implementation, we'd parse the payload and insert into Supabase
    // For now, we simulate the network request
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));
      print('✅ Mesh relay successful for incident from $deviceId');
    } catch (e) {
      print('❌ Mesh relay failed: $e');
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
