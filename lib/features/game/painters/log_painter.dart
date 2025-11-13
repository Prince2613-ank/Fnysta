import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'knife_painter.dart';

class LogPainter extends CustomPainter {
  final List<double> hitKnivesAngles;
  final List<double> fruitAngles;
  final ui.Image? fruitUiImage;
  final double time;

  LogPainter({
    required this.hitKnivesAngles,
    required this.fruitAngles,
    required this.fruitUiImage,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // --- Draw Log ---
    canvas.drawCircle(center, radius, Paint()..color = const Color(0xFFa1662d));
    canvas.drawCircle(
        center, radius * 0.95, Paint()..color = const Color(0xFF653d18));
    canvas.drawCircle(
        center, radius * 0.85, Paint()..color = const Color(0xFFf5d490));
    for (int i = 1; i < 5; i++) {
      canvas.drawCircle(
          center,
          (radius * 0.85) * (i / 5),
          Paint()
            ..color = const Color(0xFF8B4513).withOpacity(0.2)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);
    }

    // --- Draw Fruits ---
    _drawFruitImages(canvas, center, radius);

    // --- Draw Hit Knives ---
    for (double angle in hitKnivesAngles) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      final double wiggle = sin(time * 10 + angle * 5) * 0.05;
      canvas.rotate(angle + wiggle);

      final knifeSize = Size(radius * 0.15, radius * 0.7);
      canvas.save();

      canvas.translate(0, -radius - (knifeSize.height * 0.35));
      canvas.rotate(pi);
      canvas.translate(-knifeSize.width / 2, -knifeSize.height / 2);

      KnifePainter().paint(canvas, knifeSize);

      canvas.restore();
      canvas.restore();
    }
  }

  void _drawFruitImages(Canvas canvas, Offset center, double radius) {
    if (fruitUiImage == null) return;

    for (double angle in fruitAngles) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);

      final imageSize = radius * 0.45;
      final srcRect = Rect.fromLTWH(0, 0, fruitUiImage!.width.toDouble(),
          fruitUiImage!.height.toDouble());
      final dstRect = Rect.fromCenter(
          center: Offset(0, -radius * 0.8),
          width: imageSize,
          height: imageSize);

      canvas.drawImageRect(fruitUiImage!, srcRect, dstRect, Paint());

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
