import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/mesh_network_service.dart';

class MeshRadar extends ConsumerStatefulWidget {
  const MeshRadar({super.key});

  @override
  ConsumerState<MeshRadar> createState() => _MeshRadarState();
}

<<<<<<< HEAD
class _MeshRadarState extends ConsumerState<MeshRadar> with SingleTickerProviderStateMixin {
=======
class _MeshRadarState extends ConsumerState<MeshRadar>
    with SingleTickerProviderStateMixin {
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
<<<<<<< HEAD
    
=======

>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
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
<<<<<<< HEAD
            color: Colors.black.withOpacity(0.4),
=======
            color: Colors.black.withValues(alpha: 0.4),
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Radar circles
<<<<<<< HEAD
              ...List.generate(3, (i) => _buildCircle(i)),
              
              // Scanning sweep
              AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationController.value * 2 * pi,
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
                  );
                },
=======
              ...List.generate(5, (i) => _buildCircle(i)),

              // Orbiting dot with pulsing glow
              // ⚡ Bolt Optimization: Use RotationTransition for the static radar beam
              // to prevent expensive custom painting on every frame, while keeping the
              // dynamically pulsing dot in the AnimatedBuilder.
              Stack(
                alignment: Alignment.center,
                children: [
                  RotationTransition(
                    turns: _rotationController,
                    child: const CustomPaint(
                      painter: _StaticRadarBeamPainter(75.0),
                      size: Size(180, 180),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _rotationController,
                    builder: (context, child) {
                      final currentAngle = _rotationController.value * 2 * pi;
                      final orbitRadius = 75.0;
                      final currentX = cos(currentAngle) * orbitRadius;
                      final currentY = sin(currentAngle) * orbitRadius;

                      // Pulsing effect using sine wave
                      final pulseValue =
                          (sin(currentAngle * 3) + 1) /
                          2; // Range 0 to 1, pulses every ~1.3 seconds

                      return Transform.translate(
                        offset: Offset(currentX, currentY),
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(
                              0xFF00FFFF,
                            ).withValues(alpha: 0.3 + (pulseValue * 0.7)),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00FFFF),
                                blurRadius: 5 + (pulseValue * 15),
                                spreadRadius: 1 + (pulseValue * 3),
                              ),
                              BoxShadow(
                                color: const Color(
                                  0xFF00FFFF,
                                ).withValues(alpha: 0.2 + (pulseValue * 0.3)),
                                blurRadius: 10 + (pulseValue * 20),
                                spreadRadius: 2 + (pulseValue * 4),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
              ),

              // Discovered Nodes
              ...nodes.asMap().entries.map((entry) {
                final idx = entry.key;
<<<<<<< HEAD
                final angle = (idx * 137.5) * pi / 180; // Golden angle for distribution
=======
                final angle =
                    (idx * 137.5) * pi / 180; // Golden angle for distribution
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
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
<<<<<<< HEAD
                      color: Colors.blue.withOpacity(0.6),
=======
                      color: Colors.blue.withValues(alpha: 0.6),
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
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
<<<<<<< HEAD
=======
                  const SizedBox(height: 4),
                  Text(
                    'Foreground only',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                  ),
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
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
<<<<<<< HEAD
        border: Border.all(color: Colors.white.withOpacity(0.05)),
=======
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
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
<<<<<<< HEAD
          boxShadow: [
            BoxShadow(color: Colors.red, blurRadius: 8),
          ],
=======
          boxShadow: [BoxShadow(color: Colors.red, blurRadius: 8)],
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
        ),
      ),
    );
  }
}
<<<<<<< HEAD
=======

class _StaticRadarBeamPainter extends CustomPainter {
  final double orbitRadius;

  const _StaticRadarBeamPainter(this.orbitRadius);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Draw sweeping radar beam from center to orbiting dot (fixed at angle 0)
    final dotX = orbitRadius;
    final dotY = 0.0;

    final beamPaint = Paint()
      ..color = const Color(0xFF00FFFF).withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    // Draw a triangular beam shape from center to dot
    final beamWidth = 0.3; // Width of the beam in radians

    final path = Path();
    path.moveTo(center.dx, center.dy); // Start at center

    // First edge of beam
    final angle1 = -beamWidth / 2;
    path.lineTo(
      center.dx + cos(angle1) * orbitRadius,
      center.dy + sin(angle1) * orbitRadius,
    );

    // Arc to dot
    path.lineTo(center.dx + dotX, center.dy + dotY);

    // Second edge of beam
    final angle2 = beamWidth / 2;
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
