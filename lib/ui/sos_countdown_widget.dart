import 'dart:math';
import 'package:flutter/material.dart';

/// Pre-dispatch cancellation window. Copy is honest: nothing is sent until the pipeline runs.
class SOSCountdownWidget extends StatelessWidget {
  final int secondsRemaining;
  final VoidCallback onCancel;

  /// User-visible explanation (localized). Must not imply help is already notified.
  final String warningText;
  final String cancelLabel;
  final String secondsLabel;

  const SOSCountdownWidget({
    super.key,
    required this.secondsRemaining,
    required this.onCancel,
    required this.warningText,
    required this.cancelLabel,
    required this.secondsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final progress = secondsRemaining / 10.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 220,
          height: 220,
          child: CustomPaint(
            painter: _CountdownRingPainter(progress: progress),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$secondsRemaining',
                    style: TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.w900,
                      color: scheme.onSurface,
                      fontFamily: 'RobotoMono',
                    ),
                  ),
                  Text(
                    secondsLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface.withOpacity(0.76),
                      letterSpacing: 3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),

        Container(
          constraints: const BoxConstraints(maxWidth: 340),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: scheme.error.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: scheme.error.withOpacity(0.45)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline_rounded, color: scheme.error, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  warningText,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),

        SizedBox(
          width: 280,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: onCancel,
            style: ElevatedButton.styleFrom(
              backgroundColor: scheme.surfaceContainerHighest,
              foregroundColor: scheme.onSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: 4,
            ),
            icon: const Icon(Icons.close, size: 22),
            label: Text(
              cancelLabel,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Draws the countdown ring using precise alpha compositing.
class _CountdownRingPainter extends CustomPainter {
  final double progress;

  _CountdownRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..color = progress > 0.3 ? const Color(0xFFFF453A) : const Color(0xFF880E1F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );

    final glowPaint = Paint()
      ..color = const Color(0xFFFF453A).withOpacity(0.15 * progress.clamp(0.0, 1.0))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, radius, glowPaint);
  }

  @override
  bool shouldRepaint(_CountdownRingPainter old) => old.progress != progress;
}
