// lib/features/game/painters/knife_painter.dart
import 'package:flutter/material.dart';

class KnifePainter extends CustomPainter {
  final Color? color;

  const KnifePainter({this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // --- Realistic Blade with Metallic Sheen ---
    final bladePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.grey[300]!,
          Colors.white,
          Colors.grey[400]!,
          Colors.grey[300]!
        ],
        stops: const [0.0, 0.4, 0.8, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.7));

    // A slightly darker paint for the sharp edge
    final edgePaint = Paint()..color = Colors.grey[500]!;

    final bladePath = Path()
      ..moveTo(size.width / 2, 0) // Tip of the blade
      ..cubicTo(size.width * 0.1, size.height * 0.5, 0, size.height * 0.6, 0,
          size.height * 0.7) // Left curve
      ..lineTo(size.width, size.height * 0.7) // Bottom edge
      ..cubicTo(size.width, size.height * 0.6, size.width * 0.9,
          size.height * 0.5, size.width / 2, 0) // Right curve
      ..close();
    canvas.drawPath(bladePath, bladePaint);
    canvas.drawLine(
        Offset(size.width * 0.05, size.height * 0.7),
        Offset(size.width * 0.95, size.height * 0.7),
        edgePaint..strokeWidth = 1.5);

    // --- Detailed Handle ---
    final handleColor = const Color(0xFF8B4513); // SaddleBrown
    final pommelColor = const Color(0xFFcd7f32); // Bronze

    // Cross-guard
    final crossGuardPaint = Paint()..color = pommelColor;
    final crossGuardRect = RRect.fromLTRBR(size.width * 0.1, size.height * 0.68,
        size.width * 0.9, size.height * 0.75, const Radius.circular(2));
    canvas.drawRRect(crossGuardRect, crossGuardPaint);

    // Grip
    final gripPaint = Paint()
      ..shader = LinearGradient(
        colors: [handleColor.withOpacity(0.8), handleColor],
      ).createShader(Rect.fromLTWH(size.width * 0.25, size.height * 0.75,
          size.width * 0.5, size.height * 0.2));
    final gripRect = RRect.fromLTRBR(size.width * 0.25, size.height * 0.75,
        size.width * 0.75, size.height * 0.95, const Radius.circular(3));
    canvas.drawRRect(gripRect, gripPaint);

    // Pommel
    final pommelPaint = Paint()..color = pommelColor;
    canvas.drawCircle(Offset(size.width / 2, size.height * 0.95),
        size.width * 0.2, pommelPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
