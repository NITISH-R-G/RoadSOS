import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/mesh_network_service.dart';

class MeshRadar extends ConsumerStatefulWidget {
  const MeshRadar({super.key});

  @override
  ConsumerState<MeshRadar> createState() => _MeshRadarState();
}

class _MeshRadarState extends ConsumerState<MeshRadar> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    
    // Start scanning
    ref.read(meshNetworkServiceProvider).listenForSosBeacons();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final beacons = ref.watch(meshNetworkServiceProvider).discoveredBeacons;

    return StreamBuilder<List<String>>(
      stream: beacons,
      initialData: const [],
      builder: (context, snapshot) {
        final nodes = snapshot.data ?? [];

        return Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Radar circles
              ...List.generate(3, (i) => _buildCircle(i)),
              
              // Scanning sweep
              AnimatedBuilder(
                animation: _rotationController,
                // ⚡ Bolt: Pass static subtree to child parameter to avoid rebuilding expensive
                // SweepGradient and Container every frame during rotation animation
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    gradient: SweepGradient(
                      colors: [
                        Colors.blue.withOpacity(0.0),
                        Colors.blue.withOpacity(0.3),
                        Colors.blue.withOpacity(0.0),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationController.value * 2 * pi,
                    child: child,
                  );
                },
              ),

              // Discovered Nodes
              ...nodes.asMap().entries.map((entry) {
                final idx = entry.key;
                final angle = (idx * 137.5) * pi / 180; // Golden angle for distribution
                final dist = 40.0 + (idx * 15);
                return _buildNode(angle, dist);
              }),

              // Center text
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'MESH RADAR',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: Colors.blue.withOpacity(0.6),
                    ),
                  ),
                  Text(
                    '${nodes.length} NEARBY',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCircle(int index) {
    final radius = (index + 1) * 30.0;
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
    );
  }

  Widget _buildNode(double angle, double dist) {
    return Transform.translate(
      offset: Offset(cos(angle) * dist, sin(angle) * dist),
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.red, blurRadius: 8),
          ],
        ),
      ),
    );
  }
}
