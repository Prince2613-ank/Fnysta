import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'knife_painter.dart';

class BrokenLogAndKnivesPainter extends CustomPainter {
  final Animation<double> animation;
  final List<double> hitKnivesAngles;
  final ui.Image? fruitUiImage; // Keep fruit image for consistency
  final List<Offset> _pieceVelocities = [];
  // ADD: List to store random rotation speeds for each piece
  final List<double> _pieceRotations = [];
  final Random _random = Random();

  BrokenLogAndKnivesPainter({
    required this.animation,
    required this.hitKnivesAngles,
    this.fruitUiImage,
  }) : super(repaint: animation) {
    // Generate random velocities and rotations for log pieces and knives
    for (int i = 0; i < hitKnivesAngles.length + 5; i++) {
      _pieceVelocities.add(Offset(
        _random.nextDouble() * 4 - 2, // Random horizontal velocity
        _random.nextDouble() * 2 + 1, // Random initial vertical velocity
      ));
      // ADD: Assign a random rotation speed to each piece
      _pieceRotations.add(_random.nextDouble() * 4 - 2);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final progress = animation.value;
    final gravity = 9.8 * progress * 50; // Simulate gravity

    // --- Draw Falling Knives ---
    for (int i = 0; i < hitKnivesAngles.length; i++) {
      final angle = hitKnivesAngles[i];
      final velocity = _pieceVelocities[i];
      // ADD: Get the rotation for the current knife
      final rotation = _pieceRotations[i];

      canvas.save();

      // Apply falling and scattering animation
      final horizontalTranslation = velocity.dx * progress * 50;
      final verticalTranslation = velocity.dy * progress * 50 + gravity;
      canvas.translate(
          center.dx + horizontalTranslation, center.dy + verticalTranslation);

      // MODIFIED: Apply a more realistic rotation as the knife falls
      canvas.rotate(angle + progress * rotation);

      // Draw the knife
      final knifeSize = Size(radius * 0.15, radius * 0.7);
      canvas.save();
      canvas.translate(0, -radius - (knifeSize.height * 0.35));
      canvas.rotate(pi);
      canvas.translate(-knifeSize.width / 2, -knifeSize.height / 2);
      KnifePainter().paint(canvas, knifeSize);
      canvas.restore();

      canvas.restore();
    }

    // --- Draw Falling Log Pieces ---
    final logPaint = Paint()
      ..color =
          Color.lerp(const Color(0xFFa1662d), Colors.transparent, progress)!;
    final pieceCount = 5;
    for (int i = 0; i < pieceCount; i++) {
      final velocity = _pieceVelocities[hitKnivesAngles.length + i];
      // ADD: Get the rotation for the current log piece
      final rotation = _pieceRotations[hitKnivesAngles.length + i];
      final horizontalTranslation = velocity.dx * progress * 60;
      final verticalTranslation = velocity.dy * progress * 60 + gravity;
      final piecePath = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(
            Rect.fromCircle(center: center, radius: radius),
            i * (2 * pi / pieceCount),
            (2 * pi / pieceCount) * 0.8, // 0.8 to create gaps
            false)
        ..close();

      canvas.save();
      canvas.translate(horizontalTranslation, verticalTranslation);
      // MODIFIED: Apply rotation to the log pieces as they fall
      canvas.rotate(progress * rotation);
      canvas.drawPath(piecePath, logPaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
