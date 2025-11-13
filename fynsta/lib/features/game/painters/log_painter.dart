// lib/features/game/painters/log_painter.dart
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/fruit_model.dart';
import 'knife_painter.dart';

class LogPainter extends CustomPainter {
  final List<double> hitKnivesAngles;
  final List<double> fruitAngles;
  final ui.Image? fruitUiImage;
  final Fruit currentFruit;
  final double time;
  final Color baseColor;
  final Color barkColor;
  final Color ringColor;
  final List<Map<String, double>> armoredSections;
  final List<double> bombAngles;

  LogPainter({
    required this.hitKnivesAngles,
    required this.fruitAngles,
    required this.fruitUiImage,
    required this.currentFruit,
    required this.time,
    required this.baseColor,
    required this.barkColor,
    required this.ringColor,
    required this.armoredSections,
    required this.bombAngles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // --- 1. Draw Textured Bark (Bottom Layer) ---
    final barkPaint = Paint()..color = barkColor;
    final path = Path();
    for (double i = 0; i < 2 * pi; i += 0.1) {
      final r = radius * (0.9 + (_random.nextDouble() * 0.1));
      final x = center.dx + r * cos(i);
      final y = center.dy + r * sin(i);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, barkPaint);
    canvas.drawCircle(
        center, radius * 0.9, Paint()..color = barkColor.withOpacity(0.7));

    // --- 2. Draw Hit Knives (Middle Layer) ---
    for (double angle in hitKnivesAngles) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      final double wiggle = sin(time * 10 + angle * 5) * 0.05;
      canvas.rotate(angle + wiggle);
      final knifeSize = Size(radius * 0.15, radius * 0.7);
      canvas.save();
      // THIS IS THE MODIFIED LINE FOR MAXIMUM PENETRATION
      canvas.translate(0, -radius - (knifeSize.height * 0.01));
      canvas.rotate(pi);
      canvas.translate(-knifeSize.width / 2, -knifeSize.height / 2);
      const KnifePainter().paint(canvas, knifeSize);
      canvas.restore();
      canvas.restore();
    }

    // --- 3. Draw Realistic Log Face with Gradient (Top Layer) ---
    final logFacePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFf8e6c4), // Lighter center
          baseColor, // Main wood color
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.85));

    canvas.drawCircle(center, radius * 0.85, logFacePaint);

    // --- 4. Draw More Natural Tree Rings (On Top of the Face) ---
    for (int i = 1; i < 6; i++) {
      canvas.drawCircle(
          center,
          (radius * 0.85) * (i / 6),
          Paint()
            ..color = ringColor.withOpacity(0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1 + (i * 0.5)); // Varying thickness
    }

    // --- 5. Draw Obstacles (On Top of Everything) ---
    final armorPaint = Paint()
      ..color = Colors.blueGrey[700]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.25;
    for (var section in armoredSections) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * 0.875),
        section['start']!,
        section['sweep']!,
        false,
        armorPaint,
      );
    }

    _drawFruits(canvas, center, radius);

    for (double angle in bombAngles) {
      final bombSize = radius * 0.3;
      final bombOffset = center + Offset.fromDirection(angle, radius * 0.65);
      final textPainter = TextPainter(
          text: const TextSpan(text: '💣', style: TextStyle(fontSize: 30)),
          textDirection: TextDirection.ltr);
      textPainter.layout();
      textPainter.paint(canvas,
          bombOffset - Offset(textPainter.width / 2, textPainter.height / 2));
    }
  }

  void _drawFruits(Canvas canvas, Offset center, double radius) {
    for (double angle in fruitAngles) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);

      final fruitSize = radius * 0.65;
      final fruitCenter = Offset(0, -radius * 1.0);

      if (fruitUiImage != null) {
        final srcRect = Rect.fromLTWH(0, 0, fruitUiImage!.width.toDouble(),
            fruitUiImage!.height.toDouble());
        final dstRect = Rect.fromCenter(
            center: fruitCenter, width: fruitSize, height: fruitSize);
        canvas.drawImageRect(fruitUiImage!, srcRect, dstRect, Paint());
      } else if (currentFruit.color != null) {
        final paint = Paint()..color = currentFruit.color!;
        canvas.drawCircle(fruitCenter, fruitSize / 2, paint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  final Random _random = Random();
}
