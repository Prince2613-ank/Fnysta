import 'dart:math';
import 'package:flutter/material.dart';

class BrokenLogPainter extends CustomPainter {
  final Animation<double> animation;
  final List<Offset> pieces = [];
  final Random _random = Random();

  BrokenLogPainter({required this.animation}) : super(repaint: animation) {
    for (int i = 0; i < 15; i++) {
      pieces.add(Offset(
        _random.nextDouble() * 2 - 1,
        _random.nextDouble() * 2 - 1,
      ));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()..color = const Color(0xFFa1662d);

    for (var piece in pieces) {
      // Add a downward motion to the pieces to simulate gravity
      final offset = Offset(
        piece.dx * animation.value * 200,
        piece.dy * animation.value * 200 + (animation.value * 300),
      );
      canvas.drawCircle(
        center + offset,
        radius / 4 * (1 - animation.value),
        paint
          ..color = Color.lerp(
              const Color(0xFFa1662d), Colors.transparent, animation.value)!,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
