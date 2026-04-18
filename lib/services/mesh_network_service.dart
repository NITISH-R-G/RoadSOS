import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

class MeshNetworkService {
  Future<void> broadcastSosPayload(String compressedPayload) async {
    if (kIsWeb) {
      print('BLE Mesh is not supported on Web. Bypassing broadcast.');
      return;
    }

    // 1. Check Bluetooth availability
    if (await FlutterBluePlus.adapterState.first == BluetoothAdapterState.on) {
      // 2. In a real implementation, we'd use a specific BLE advertising package
      // or platform channels since flutter_blue_plus is primarily for central (scanning).
      // For the hackathon, we simulate advertising the manufacturer data.
      
      final payloadBytes = utf8.encode(compressedPayload);
      print('Broadcasting BLE Beacon with payload: $compressedPayload');
      
      // Simulate BLE broadcast
      await Future.delayed(const Duration(seconds: 1));
      print('Beacon active. Waiting for relays...');
    } else {
      print('Bluetooth is disabled. Cannot broadcast mesh payload.');
    }
  }

  Future<void> listenForSosBeacons() async {
    if (kIsWeb) {
      print('BLE Mesh scanning is not supported on Web.');
      return;
    }

    // 3. Scan for other devices broadcasting RoadSOS payloads
    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        // Check manufacturer data for RoadSOS signature
        if (r.advertisementData.manufacturerData.containsKey(0xFFFF)) { // Example ID
          print('Found RoadSOS SOS Beacon! Relaying to cloud...');
          // Relay logic here
        }
      }
    });

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
  }

  Future<void> triggerSmsFallback(String payload) async {
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: '112', // Local emergency number
      queryParameters: <String, String>{
        'body': 'URGENT ROAD SOS: \$payload',
      },
    );

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      print('Could not launch SMS dialer');
    }
  }
}
