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
    final List<String> beacons = ref.watch(meshPeersProvider).valueOrNull ?? [];
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(200, 200),
              painter: _RadarPainter(_controller),
            ),
            RotationTransition(
              turns: _controller,
              child: const CustomPaint(
                size: Size(200, 200),
                painter: _SweepPainter(),
              ),
            ),
            ..._buildBeaconDots(beacons),
            const Icon(Icons.my_location, color: Colors.blue, size: 24),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          beacons.isEmpty
              ? 'SCANNING (NO PEERS)'
              : 'PEERS DETECTED: ${beacons.length}',
          style: const TextStyle(
            color: Colors.blue,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildBeaconDots(List<String> ids) {
    final List<Widget> out = <Widget>[];
    const double center = 100.0;
    const double maxR = 78.0;
    for (final String id in ids) {
      final int h = id.hashCode;
      final double angle = ((h % 360) * math.pi) / 180.0;
      final double r =
          (math.sqrt(((h >> 8).abs() % 1000) / 1000.0) * maxR).clamp(
        18.0,
        maxR,
      );
      final double x = center + math.cos(angle) * r;
      final double y = center + math.sin(angle) * r;
      out.add(Positioned(left: x, top: y, child: const _IncidentDot()));
    }
    return out;
  }
}

class _RadarPainter extends CustomPainter {
  final Animation<double> animation;
  _RadarPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final Offset center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, size.width * 0.2, paint);
    canvas.drawCircle(center, size.width * 0.35, paint);
    canvas.drawCircle(center, size.width * 0.5, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SweepPainter extends CustomPainter {
  const _SweepPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2;

    final Rect rect = Rect.fromCircle(center: center, radius: radius);
    final SweepGradient gradient = SweepGradient(
      startAngle: 0,
      endAngle: math.pi * 2,
      colors: [
        Colors.blue.withValues(alpha: 0),
        Colors.blue.withValues(alpha: 0.5),
        Colors.blue.withValues(alpha: 0),
      ],
      stops: const <double>[0.0, 0.5, 1.0],
    );

    final Paint paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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