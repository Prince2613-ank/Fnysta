import 'package:flutter/material.dart';

class KnifePainter extends CustomPainter {
  final Color? color; // Added color property

  const KnifePainter({this.color}); // Added color to constructor

  @override
  void paint(Canvas canvas, Size size) {
    final bladePaint = Paint()
      ..color = color ?? Colors.grey[300]!; // Use color if provided
    final handlePaint = Paint()
      ..color =
          color != null ? color!.withOpacity(0.7) : const Color(0xFF8B4513);

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height * 0.7)
      ..lineTo(size.width, size.height * 0.7)
      ..close();
    canvas.drawPath(path, bladePaint);
    canvas.drawRect(
        Rect.fromLTWH(size.width * 0.2, size.height * 0.7, size.width * 0.6,
            size.height * 0.3),
        handlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
