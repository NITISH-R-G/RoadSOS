import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/mesh_network_service.dart';

class BystanderRadar extends StatefulWidget {
  const BystanderRadar({super.key});

  @override
  State<BystanderRadar> createState() => _BystanderRadarState();
}

class _BystanderRadarState extends State<BystanderRadar>
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
            AnimatedBuilder(
              animation: _controller,
              // ⚡ Bolt: Moving static CustomPaint out of builder prevents expensive SweepGradient recreation
              child: const CustomPaint(
                size: Size(200, 200),
                painter: _SweepPainter(),
              ),
              builder: (context, child) {
                return Transform.rotate(
                  // ⚡ Bolt: Rotate the cached child instead of rebuilding
                  angle: _controller.value * math.pi * 2,
                  child: child,
                );
              },
            ),
            // Mock Found Incident
            Positioned(
              top: 40,
              left: 140,
              child: _IncidentDot(),
            ),
            const Icon(Icons.my_location, color: Colors.blue, size: 24),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          "SCANNING MESH NETWORK",
          style: TextStyle(
            color: Colors.blue,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

class _RadarPainter extends CustomPainter {
  final Animation<double> animation;
  _RadarPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.1)
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
  const _SweepPainter();

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
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _IncidentDot extends StatelessWidget {
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
