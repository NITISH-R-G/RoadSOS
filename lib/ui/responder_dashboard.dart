import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/emergency_orchestrator.dart';
<<<<<<< HEAD
=======
import '../services/mesh_network_service.dart';
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
import 'map_widget.dart';

class ResponderDashboard extends ConsumerWidget {
  const ResponderDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sosState = ref.watch(emergencyOrchestratorProvider);
<<<<<<< HEAD
=======
    final mesh = ref.watch(meshNetworkServiceProvider);
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41

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
<<<<<<< HEAD
              color: Colors.white.withOpacity(0.05),
=======
              color: Colors.white.withValues(alpha: 0.05),
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
<<<<<<< HEAD
                  'NEARBY ACTIVE ALERTS',
                  style: TextStyle(color: Colors.white38, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5),
                ),
                const SizedBox(height: 16),
                _buildAlertItem('SOS_MESH_NODE_77', '2.4 KM AWAY', 'HIGH SEVERITY'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
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
                      Text('MESH-SYNC', style: TextStyle(color: Colors.red.withOpacity(0.5), fontWeight: FontWeight.bold, fontSize: 8)),
                    ],
                  ),
                ),
                const Divider(color: Colors.white10, height: 32),
                _buildAlertItem('HOSPITAL: CITY GENERAL', '1.1 KM AWAY', 'OPERATIONAL'),
=======
                  'ACTIVE SIGNALS (REAL-TIME)',
                  style: TextStyle(color: Colors.white38, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5),
                ),
                const SizedBox(height: 16),
                _buildSosCard(sosState),
                const SizedBox(height: 14),
                const Divider(color: Colors.white10, height: 24),
                const Text(
                  'RECENT MESH PACKETS',
                  style: TextStyle(color: Colors.white38, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5),
                ),
                const SizedBox(height: 10),
                StreamBuilder<MeshPacket>(
                  stream: mesh.packets,
                  builder: (context, snap) {
                    // This is intentionally simple: show the latest packet only.
                    // A future responder build can persist + list packets with dedup.
                    final pkt = snap.data;
                    if (pkt == null) {
                      return const Text(
                        'No mesh packets yet.',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      );
                    }
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'From ${pkt.senderId}${pkt.rssi != null ? ' (RSSI ${pkt.rssi})' : ''}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            pkt.payload,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.35),
                          ),
                        ],
                      ),
                    );
                  },
                ),
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
              ],
            ),
          ),
        ],
      ),
    );
  }

<<<<<<< HEAD
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
              color: status.contains('HIGH') ? Colors.red.withOpacity(0.2) : Colors.green.withOpacity(0.2),
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
=======
  Widget _buildSosCard(SOSState state) {
    final active = state.phase == SOSPhase.active || state.phase == SOSPhase.dispatching;
    final title = active ? 'SOS ACTIVE' : 'NO ACTIVE SOS';
    final detail = state.incidentId == null ? '—' : state.incidentId!;
    final sev = state.triageResult?.severityLevel;
    final sevLabel = sev == null ? '—' : 'Severity $sev/5';
    final loc = state.location;
    final locLine = loc == null
        ? 'Location: —'
        : 'Location: ${loc.latitude.toStringAsFixed(3)},${loc.longitude.toStringAsFixed(3)} (±${loc.accuracy.round()}m)';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: active ? Colors.red.withValues(alpha: 0.10) : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: active ? Colors.red.withValues(alpha: 0.30) : Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: active ? Colors.red : Colors.white70,
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Incident: $detail',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            '$sevLabel\n$locLine',
            style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.35),
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
          ),
        ],
      ),
    );
  }
}
