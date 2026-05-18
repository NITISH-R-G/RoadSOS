import 'dart:ui';

import 'package:flutter/material.dart';

/// iOS-style frosted glass panel (BackdropFilter). Works on all platforms;
/// pair with [LiquidGlassView] from `liquid_glass_easy` on hero widgets if desired.
class RoadSosGlassPanel extends StatelessWidget {
  const RoadSosGlassPanel({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.padding = const EdgeInsets.all(16),
    this.blurSigma = 22,
    this.tint = const Color(0x14FFFFFF),
    this.borderColor = const Color(0x33FFFFFF),
  });

  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final double blurSigma;
  final Color tint;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: tint,
            borderRadius: borderRadius,
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Bottom navigation bar with glass chrome.
class RoadSosGlassNavBar extends StatelessWidget {
  const RoadSosGlassNavBar({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: RoadSosGlassPanel(
          borderRadius: BorderRadius.circular(28),
          padding: EdgeInsets.zero,
          blurSigma: 28,
          tint: const Color(0x1AFFFFFF),
          child: child,
        ),
      ),
    );
  }
}
