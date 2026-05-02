import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/proactive_monitor_service.dart';

class SafeWalkOverlay extends ConsumerWidget {
  const SafeWalkOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monitor = ref.watch(proactiveMonitorProvider);

    if (!monitor.isMonitoring) return const SizedBox.shrink();

    return Positioned(
      top: 100,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: monitor.alertTriggered ? Colors.red.withOpacity(0.9) : Colors.blue.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: Row(
            children: [
              Icon(
                monitor.alertTriggered ? Icons.warning : Icons.directions_walk, 
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      monitor.alertTriggered ? 'CHECK-IN REQUIRED' : 'SAFE-WALK ACTIVE',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10),
                    ),
                    Text(
                      monitor.alertTriggered 
                        ? 'Confirm your safety now or SOS will trigger.' 
                        : 'Heading to ${monitor.destination}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
              TextButton(
                // "I'm safe" should acknowledge the check-in without stopping Safe Walk monitoring.
                onPressed: () => ref.read(proactiveMonitorProvider.notifier).confirmImSafe(),
                child: const Text('I AM SAFE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
