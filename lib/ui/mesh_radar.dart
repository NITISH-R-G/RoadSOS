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
            color: Colors.black.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Radar circles
              ...List.generate(5, (i) => _buildCircle(i)),
              
              // Orbiting dot with pulsing glow
              AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  final currentAngle = _rotationController.value * 2 * pi;
                  final orbitRadius = 75.0;
                  final currentX = cos(currentAngle) * orbitRadius;
                  final currentY = sin(currentAngle) * orbitRadius;
                  
                  // Pulsing effect using sine wave
                  final pulseValue = (sin(currentAngle * 3) + 1) / 2; // Range 0 to 1, pulses every ~1.3 seconds
                  
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Radar beam (light blue sweep from center to dot)
                      CustomPaint(
                        painter: _RadarBeamPainter(currentAngle, orbitRadius),
                        size: const Size(180, 180),
                      ),
                      
                      // Main orbiting dot with pulsing glow
                      Transform.translate(
                        offset: Offset(currentX, currentY),
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF00FFFF).withValues(alpha: 0.3 + (pulseValue * 0.7)),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00FFFF),
                                blurRadius: 5 + (pulseValue * 15),
                                spreadRadius: 1 + (pulseValue * 3),
                              ),
                              BoxShadow(
                                color: const Color(0xFF00FFFF).withValues(alpha: 0.2 + (pulseValue * 0.3)),
                                blurRadius: 10 + (pulseValue * 20),
                                spreadRadius: 2 + (pulseValue * 4),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
                      color: Colors.blue.withValues(alpha: 0.6),
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
                  const SizedBox(height: 4),
                  Text(
                    'Foreground only',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.35),
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
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
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

class _RadarBeamPainter extends CustomPainter {
  final double currentAngle;
  final double orbitRadius;

  _RadarBeamPainter(this.currentAngle, this.orbitRadius);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw sweeping radar beam from center to orbiting dot
    final dotX = cos(currentAngle) * orbitRadius;
    final dotY = sin(currentAngle) * orbitRadius;
    
    // Create a sweep gradient effect from center to dot
    final beamPaint = Paint()
      ..color = const Color(0xFF00FFFF).withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    
    // Draw a triangular beam shape from center to dot
    final beamWidth = 0.3; // Width of the beam in radians
    
    final path = Path();
    path.moveTo(center.dx, center.dy); // Start at center
    
    // First edge of beam
    final angle1 = currentAngle - beamWidth / 2;
    path.lineTo(
      center.dx + cos(angle1) * orbitRadius,
      center.dy + sin(angle1) * orbitRadius,
    );
    
    // Arc to dot
    path.lineTo(
      center.dx + dotX,
      center.dy + dotY,
    );
    
    // Second edge of beam
    final angle2 = currentAngle + beamWidth / 2;
    path.lineTo(
      center.dx + cos(angle2) * orbitRadius,
      center.dy + sin(angle2) * orbitRadius,
    );
    
    path.close();
    canvas.drawPath(path, beamPaint);
    
    // Add a glow effect with lighter color
    final glowPaint = Paint()
      ..color = const Color(0xFF00FFFF).withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    
    canvas.drawPath(path, glowPaint);
  }

  @override
  bool shouldRepaint(_RadarBeamPainter oldDelegate) => true;
}

