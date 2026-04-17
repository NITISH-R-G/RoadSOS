import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSOSActive = ref.watch(isSOSActiveProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('RoadSOS'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSOSActive)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'SOS MODE ACTIVE\nBroadcasting via BLE...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            GestureDetector(
              onTap: () {
                ref.read(isSOSActiveProvider.notifier).state = !isSOSActive;
              },
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSOSActive ? Colors.red.shade900 : Colors.red,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.5),
                      blurRadius: isSOSActive ? 50 : 20,
                      spreadRadius: isSOSActive ? 20 : 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    isSOSActive ? 'CANCEL SOS' : 'SOS',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
            const Text(
              'Gemma is a trademark of Google LLC',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            )
          ],
        ),
      ),
    );
  }
}
