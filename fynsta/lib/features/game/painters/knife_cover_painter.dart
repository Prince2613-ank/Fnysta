// lib/features/game/painters/knife_cover_painter.dart
import 'package:flutter/material.dart';

class KnifeCoverPainter extends CustomPainter {
  final Color? color;

  const KnifeCoverPainter({this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final handleOpacity = 0.4;
    final handleColor = const Color(0xFF8B4513).withOpacity(handleOpacity);
    final pommelColor = const Color(0xFFcd7f32).withOpacity(handleOpacity);
    final bladePaint = Paint()..color = Colors.grey.withOpacity(0.1);

    // Faint blade silhouette
    final bladePath = Path()
      ..moveTo(size.width / 2, 0)
      ..cubicTo(size.width * 0.1, size.height * 0.5, 0, size.height * 0.6, 0,
          size.height * 0.7)
      ..lineTo(size.width, size.height * 0.7)
      ..cubicTo(size.width, size.height * 0.6, size.width * 0.9,
          size.height * 0.5, size.width / 2, 0)
      ..close();
    canvas.drawPath(bladePath, bladePaint);

    // --- Semi-transparent Handle ---
    // Cross-guard
    final crossGuardPaint = Paint()..color = pommelColor;
    final crossGuardRect = RRect.fromLTRBR(size.width * 0.1, size.height * 0.68,
        size.width * 0.9, size.height * 0.75, const Radius.circular(2));
    canvas.drawRRect(crossGuardRect, crossGuardPaint);

    // Grip
    final gripPaint = Paint()..color = handleColor;
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
