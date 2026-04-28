import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/emergency_orchestrator.dart';
import 'map_widget.dart';

class ResponderDashboard extends ConsumerWidget {
  const ResponderDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sosState = ref.watch(emergencyOrchestratorProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('RESPONDER VIEW', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Expanded(
            child: RoadSosMap(state: sosState, autoCenter: false),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NEARBY ACTIVE ALERTS',
                  style: TextStyle(color: Colors.white38, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5),
                ),
                const SizedBox(height: 16),
                _buildAlertItem('SOS_MESH_NODE_77', '2.4 KM AWAY', 'HIGH SEVERITY'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.favorite, color: Colors.red, size: 20),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('VICTIM PULSE: 112 BPM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          Text('STATUS: TACHYCARDIA / SHOCK RISK', style: TextStyle(color: Colors.white54, fontSize: 10)),
                        ],
                      ),
                      const Spacer(),
                      Text('MESH-SYNC', style: TextStyle(color: Colors.red.withValues(alpha: 0.5), fontWeight: FontWeight.bold, fontSize: 8)),
                    ],
                  ),
                ),
                const Divider(color: Colors.white10, height: 32),
                _buildAlertItem('HOSPITAL: CITY GENERAL', '1.1 KM AWAY', 'OPERATIONAL'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(String title, String distance, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text(distance, style: const TextStyle(color: Colors.white38, fontSize: 12)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: status.contains('HIGH') ? Colors.red.withValues(alpha: 0.2) : Colors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: status.contains('HIGH') ? Colors.red : Colors.green,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
