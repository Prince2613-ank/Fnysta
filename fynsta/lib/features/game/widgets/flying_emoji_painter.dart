import 'dart:math';
import 'package:flutter/material.dart';

class FlyingEmojiPainter extends StatefulWidget {
  const FlyingEmojiPainter({Key? key}) : super(key: key);

  @override
  _FlyingEmojiPainterState createState() => _FlyingEmojiPainterState();
}

class _FlyingEmojiPainterState extends State<FlyingEmojiPainter>
    with TickerProviderStateMixin {
  late AnimationController _flightController;
  late AnimationController _wingController;

  late Animation<Offset> _flightAnimation;
  late Animation<double> _wingAnimation;

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    _flightController = AnimationController(
      duration: const Duration(milliseconds: 3500),
      vsync: this,
    );

    _wingController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..repeat(reverse: true);

    _wingAnimation = Tween<double>(begin: -0.6, end: 0.2).animate(
      CurvedAnimation(parent: _wingController, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final size = MediaQuery.of(context).size;
      _flightAnimation = Tween<Offset>(
        begin: Offset(-80, size.height * 0.75),
        end: Offset(size.width + 80, size.height * 0.1),
      ).animate(CurvedAnimation(
        parent: _flightController,
        curve: Curves.easeInOut,
      ));
      _flightController.forward();
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _flightController.dispose();
    _wingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_flightController, _wingController]),
      builder: (context, child) {
        return CustomPaint(
          painter: _EmojiPainter(
            position: _flightAnimation.value,
            wingAngle: _wingAnimation.value,
            time: _flightController.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _EmojiPainter extends CustomPainter {
  final Offset position;
  final double wingAngle;
  final double time;

  _EmojiPainter({
    required this.position,
    required this.wingAngle,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (position == null) return;

    final emojiRadius = 40.0;

    // --- Draw Sparkles ---
    final sparklePaint = Paint()
      ..color = Colors.yellowAccent.withOpacity(1 - (2 * (time - 0.5)).abs());
    for (int i = 0; i < 3; i++) {
      final angle = 2 * pi / 3 * i + (time * 2 * pi);
      final sparklePos =
          position + Offset.fromDirection(angle, emojiRadius + 20);
      canvas.save();
      canvas.translate(sparklePos.dx, sparklePos.dy);
      canvas.rotate(time * pi * (i.isEven ? 1 : -1));
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: 8, height: 2),
          sparklePaint);
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: 2, height: 8),
          sparklePaint);
      canvas.restore();
    }

    canvas.save();
    canvas.translate(position.dx, position.dy);

    // --- Define Shimmering Iridescent Wing Paint ---
    final iridescentShader = SweepGradient(
      colors: const [
        Colors.red,
        Colors.yellow,
        Colors.green,
        Colors.cyan,
        Colors.blue,
        Colors.purple,
        Colors.red,
      ],
      transform: GradientRotation(time * 2 * pi), // Animate the rotation
    ).createShader(Rect.fromCircle(center: Offset.zero, radius: 80));

    final wingPaint = Paint()
      ..shader = iridescentShader
      ..style = PaintingStyle.fill;

    // --- Define a soft white glow for the wings ---
    final wingGlowPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final wingPath = Path()
      ..moveTo(0, 0)
      ..cubicTo(-40, -50, -80, -30, -70, 0)
      ..cubicTo(-60, 30, -20, 20, 0, 0)
      ..close();

    void drawWing(void Function() transformCallback) {
      canvas.save();
      transformCallback();
      canvas.drawPath(wingPath, wingGlowPaint);
      canvas.drawPath(wingPath, wingPaint);
      canvas.restore();
    }

    drawWing(() {
      canvas.translate(-emojiRadius * 0.6, 0);
      canvas.rotate(wingAngle);
    });

    drawWing(() {
      canvas.translate(emojiRadius * 0.6, 0);
      canvas.scale(-1, 1);
      canvas.rotate(wingAngle);
    });

    // --- Draw Game Emoji ---
    final textSpan = TextSpan(
      text: '🎮',
      style: TextStyle(fontSize: 70), // A good size for the emoji
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Calculate the offset to center the emoji
    final emojiOffset = Offset(
      -textPainter.width / 2,
      -textPainter.height / 2,
    );

    textPainter.paint(canvas, emojiOffset);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _EmojiPainter oldDelegate) {
    return position != oldDelegate.position ||
        wingAngle != oldDelegate.wingAngle ||
        time != oldDelegate.time;
  }
}
