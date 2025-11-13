// lib/features/game/painters/aiming_line_painter.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:math';

class AimingLinePainter extends CustomPainter {
  // Drag properties for the pullback effect
  final Offset? dragStart;
  final Offset? dragCurrent;
  final Offset knifePosition;

  AimingLinePainter({
    required this.dragStart,
    required this.dragCurrent,
    required this.knifePosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dragStart == null || dragCurrent == null) return;

    // --- Draw the Pullback Line ---
    final pullOffset = dragCurrent! - dragStart!;
    // We only care about the downward pull, and cap it at a max distance.
    final pullDistance = pullOffset.dy.clamp(0.0, 150.0);

    // Make the line get thicker and more opaque as you pull back
    final pullRatio = pullDistance / 150.0;
    final linePaint = Paint()
      ..color = Colors.yellowAccent.withOpacity(0.5 + (pullRatio * 0.5))
      ..strokeWidth = 2.0 + (pullRatio * 4.0)
      ..strokeCap = StrokeCap.round;

    // The line starts at the knife and goes "backwards" (down)
    final endPullPoint = knifePosition + Offset(0, pullDistance);
    canvas.drawLine(knifePosition, endPullPoint, linePaint);
  }

  @override
  bool shouldRepaint(covariant AimingLinePainter oldDelegate) {
    // Repaint whenever drag points change to show the aiming line move
    return oldDelegate.dragStart != dragStart ||
        oldDelegate.dragCurrent != dragCurrent;
  }
}
