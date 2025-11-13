// lib/features/game/painters/explosion_painter.dart
import 'package:flutter/material.dart';

class ExplosionPainter extends CustomPainter {
  final Animation<double> animation;
  final Offset center;

  ExplosionPainter({required this.animation, required this.center})
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final progress = animation.value;
    if (progress == 0.0 || progress == 1.0) return;

    final screenRadius = size.width > size.height ? size.width : size.height;

    // Outer shockwave (fades out)
    final shockwavePaint = Paint()
      ..color = Colors.orangeAccent.withOpacity(1.0 - progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20.0 * (1.0 - progress);
    canvas.drawCircle(center, screenRadius * progress, shockwavePaint);

    // Inner core (bright and expands)
    final corePaint = Paint()
      ..color = Colors.yellow.withOpacity(0.8 - (progress * 0.8))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, screenRadius * progress * 0.5, corePaint);

    // White flash (intense at the beginning)
    final flashPaint = Paint()
      ..color = Colors.white.withOpacity(0.9 - (progress * 0.9))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, screenRadius * progress * 0.25, flashPaint);
  }

  @override
  bool shouldRepaint(covariant ExplosionPainter oldDelegate) => true;
}
