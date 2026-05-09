import 'dart:math';
import 'package:flutter/material.dart';
<<<<<<< HEAD

/// Circular countdown timer with a large cancel button.
/// Displayed during the 10-second SOS cancellation window.
class SOSCountdownWidget extends StatelessWidget {
  final int secondsRemaining;
  final VoidCallback onCancel;

=======
import 'package:flutter/services.dart';

/// Pre-dispatch cancellation window.
///
/// Phase 7 UX hardening — life-critical stress UX:
///   • Cancel button is full-width and 72px tall (large thumb target under panic).
///   • Haptic feedback fires on widget appearance (pattern: medium + 80ms + heavy)
///     so the user feels the countdown starting even if the screen is not visible.
///   • Warning box uses [withAlpha] (not deprecated [withOpacity]).
///   • Copy is honest: nothing is sent until the pipeline runs after countdown.
class SOSCountdownWidget extends StatefulWidget {
  final int secondsRemaining;
  final VoidCallback onCancel;

  final String warningText;
  final String cancelLabel;
  final String secondsLabel;

>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
  const SOSCountdownWidget({
    super.key,
    required this.secondsRemaining,
    required this.onCancel,
<<<<<<< HEAD
  });

  @override
  Widget build(BuildContext context) {
    final progress = secondsRemaining / 10.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Countdown ring
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
                    style: const TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      fontFamily: 'RobotoMono',
                    ),
                  ),
                  const Text(
                    'SECONDS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                      letterSpacing: 3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Warning text
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 20),
              SizedBox(width: 8),
              Text(
                'SOS will dispatch when timer reaches 0',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),

        // Cancel button
        SizedBox(
          width: 280,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: onCancel,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade800,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: 4,
            ),
            icon: const Icon(Icons.close, size: 22),
            label: const Text(
              'CANCEL SOS',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ],
=======
    required this.warningText,
    required this.cancelLabel,
    required this.secondsLabel,
  });

  @override
  State<SOSCountdownWidget> createState() => _SOSCountdownWidgetState();
}

class _SOSCountdownWidgetState extends State<SOSCountdownWidget> {
  @override
  void initState() {
    super.initState();
    // Haptic burst on first appearance — notifies even with screen face-down.
    _triggerStartHaptics();
  }

  Future<void> _triggerStartHaptics() async {
    await HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final progress = widget.secondsRemaining / 10.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          // ── Countdown ring ────────────────────────────────────────────────
          Center(
            child: SizedBox(
              width: 220,
              height: 220,
              child: CustomPaint(
                painter: _CountdownRingPainter(progress: progress),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${widget.secondsRemaining}',
                        style: TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.w900,
                          color: scheme.onSurface,
                          fontFamily: 'RobotoMono',
                        ),
                      ),
                      Text(
                        widget.secondsLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface.withAlpha(194),
                          letterSpacing: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // ── Warning notice ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: scheme.error.withAlpha(31),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: scheme.error.withAlpha(115)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: scheme.error, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.warningText,
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
          const SizedBox(height: 32),

          // ── Cancel button — full-width, 72px, instant response ────────────
          // Full-width target makes it easy to tap in low-light or panic.
          // Uses [HapticFeedback.heavyImpact] on press so the user feels
          // the cancellation even without looking at the screen.
          SizedBox(
            height: 72,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.heavyImpact();
                widget.onCancel();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.surfaceContainerHighest,
                foregroundColor: scheme.onSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: scheme.outline.withAlpha(100)),
                ),
                elevation: 4,
              ),
              icon: const Icon(Icons.close_rounded, size: 26),
              label: Text(
                widget.cancelLabel,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
    );
  }
}

<<<<<<< HEAD
/// Draws the animated countdown ring.
class _CountdownRingPainter extends CustomPainter {
  final double progress; // 1.0 = full, 0.0 = empty
=======
/// Draws the countdown ring using [withAlpha] for precise alpha compositing.
class _CountdownRingPainter extends CustomPainter {
  final double progress;
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41

  _CountdownRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

<<<<<<< HEAD
    // Background ring
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
=======
    // Track ring
    final bgPaint = Paint()
      ..color = Colors.white.withAlpha(36)
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
<<<<<<< HEAD
      ..color = progress > 0.3 ? Colors.red : Colors.red.shade900
=======
      ..color = progress > 0.3 ? const Color(0xFFFF453A) : const Color(0xFF880E1F)
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
<<<<<<< HEAD
      -pi / 2, // Start from top
=======
      -pi / 2,
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
      2 * pi * progress,
      false,
      progressPaint,
    );

<<<<<<< HEAD
    // Glow effect
    final glowPaint = Paint()
      ..color = Colors.red.withOpacity(0.15 * progress)
=======
    // Glow
    final glowAlpha = (38 * progress.clamp(0.0, 1.0)).round();
    final glowPaint = Paint()
      ..color = Color.fromARGB(glowAlpha, 0xFF, 0x45, 0x3A)
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, radius, glowPaint);
  }

  @override
  bool shouldRepaint(_CountdownRingPainter old) => old.progress != progress;
}
