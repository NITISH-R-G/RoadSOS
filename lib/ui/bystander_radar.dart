import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/mesh_network_service.dart';

class BystanderRadar extends ConsumerStatefulWidget {
  const BystanderRadar({super.key});

  @override
  ConsumerState<BystanderRadar> createState() => _BystanderRadarState();
}

class _BystanderRadarState extends ConsumerState<BystanderRadar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final beaconsStream = ref.watch(meshNetworkServiceProvider).discoveredBeacons;
=======
    final beaconsStream = ref
        .watch(meshNetworkServiceProvider)
        .discoveredBeacons;
>>>>>>> origin/main

    return StreamBuilder<List<String>>(
      stream: beaconsStream,
      initialData: const [],
      builder: (context, snapshot) {
        final beacons = snapshot.data ?? const <String>[];
        return Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Radar Background Rings
                CustomPaint(
                  size: const Size(200, 200),
                  painter: _RadarPainter(_controller),
                ),
                // Radar Pulse
<<<<<<< HEAD
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size(200, 200),
                      painter: _SweepPainter(_controller.value),
                    );
                  },
=======
                // ⚡ Bolt Optimization: Use RotationTransition with a static child to prevent
                // the expensive SweepGradient shader from being rebuilt on every frame.
                RotationTransition(
                  turns: _controller,
                  child: const CustomPaint(
                    size: Size(200, 200),
                    painter: _SweepPainter(),
                  ),
>>>>>>> origin/main
                ),
                ..._buildBeaconDots(beacons),
                const Icon(Icons.my_location, color: Colors.blue, size: 24),
              ],
            ),
            const SizedBox(height: 16),
            Text(
<<<<<<< HEAD
              beacons.isEmpty ? 'SCANNING (NO PEERS)' : 'PEERS DETECTED: ${beacons.length}',
=======
              beacons.isEmpty
                  ? 'SCANNING (NO PEERS)'
                  : 'PEERS DETECTED: ${beacons.length}',
>>>>>>> origin/main
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildBeaconDots(List<String> ids) {
    final out = <Widget>[];
    const center = 100.0;
    const maxR = 78.0;
    for (final id in ids) {
      final h = id.hashCode;
      final angle = ((h % 360) * math.pi) / 180.0;
<<<<<<< HEAD
      final r =
          (math.sqrt(((h >> 8).abs() % 1000) / 1000.0) * maxR).clamp(18.0, maxR);
      final x = center + math.cos(angle) * r;
      final y = center + math.sin(angle) * r;
      out.add(
        Positioned(
          left: x,
          top: y,
          child: const _IncidentDot(),
        ),
      );
=======
      final r = (math.sqrt(((h >> 8).abs() % 1000) / 1000.0) * maxR).clamp(
        18.0,
        maxR,
      );
      final x = center + math.cos(angle) * r;
      final y = center + math.sin(angle) * r;
      out.add(Positioned(left: x, top: y, child: const _IncidentDot()));
>>>>>>> origin/main
    }
    return out;
  }
}

class _RadarPainter extends CustomPainter {
  final Animation<double> animation;
  _RadarPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, size.width * 0.2, paint);
    canvas.drawCircle(center, size.width * 0.35, paint);
    canvas.drawCircle(center, size.width * 0.5, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SweepPainter extends CustomPainter {
<<<<<<< HEAD
  final double sweep;
  _SweepPainter(this.sweep);
=======
  const _SweepPainter();
>>>>>>> origin/main

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      startAngle: 0,
      endAngle: math.pi * 2,
      colors: [
        Colors.blue.withValues(alpha: 0),
        Colors.blue.withValues(alpha: 0.5),
        Colors.blue.withValues(alpha: 0),
      ],
      stops: const [0.0, 0.5, 1.0],
<<<<<<< HEAD
      transform: GradientRotation(sweep * math.pi * 2),
=======
>>>>>>> origin/main
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, paint);
  }

  @override
<<<<<<< HEAD
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
=======
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
>>>>>>> origin/main
}

class _IncidentDot extends StatelessWidget {
  const _IncidentDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.red, blurRadius: 10, spreadRadius: 2),
        ],
      ),
    );
  }
}
