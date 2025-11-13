// lib/features/game/widgets/spin_the_wheel_overlay.dart
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class SpinTheWheelOverlay extends StatefulWidget {
  final Function(String) onReward;

  const SpinTheWheelOverlay({Key? key, required this.onReward})
      : super(key: key);

  @override
  _SpinTheWheelOverlayState createState() => _SpinTheWheelOverlayState();
}

class _SpinTheWheelOverlayState extends State<SpinTheWheelOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Tween<double> _rotationTween = Tween<double>(begin: 0, end: 0);
  late Animation<double> _rotationAnimation;

  final List<String> _rewards = [
    "+10 Apples",
    "1x Revive",
    "+20 Apples",
    "1x Slow-Mo",
    "+5 Apples",
    "+2 Apples"
  ];
  final _random = Random();
  bool _isSpinning = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          final finalAngle = _rotationTween.end!;
          final normalizedAngle = finalAngle % (2 * pi);
          final sectionAngle = (2 * pi) / _rewards.length;
          final correctedAngle =
              normalizedAngle + (sectionAngle / 2) + (pi / 2);
          final selectedRewardIndex =
              (_rewards.length - (correctedAngle / sectionAngle).floor()) %
                  _rewards.length;

          setState(() {
            _isSpinning = false;
          });

          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              widget.onReward(_rewards[selectedRewardIndex]);
            }
          });
        }
      });

    _rotationAnimation = _rotationTween.animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  void _spin() {
    if (_isSpinning) return;
    setState(() {
      _isSpinning = true;
    });
    _audioPlayer.play(AssetSource('audios/spineffect.mp3'));

    final randomSpins = _random.nextInt(5) + 8;
    final randomAngle = _random.nextDouble() * 2 * pi;
    final finalAngle = (randomSpins * 2 * pi) + randomAngle;

    _rotationTween.begin = _rotationAnimation.value;
    _rotationTween.end = finalAngle;

    _controller.reset();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Daily Bonus',
              style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(blurRadius: 10, color: Colors.yellowAccent)
                  ]),
            ),
            const SizedBox(height: 40),
            Stack(
              clipBehavior:
                  Clip.none, // Allow pointer to draw outside the stack
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _rotationAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationAnimation.value,
                      child: child,
                    );
                  },
                  child: Image.asset(
                    'assets/spin_wheel.png',
                    width: 300,
                    height: 300,
                  ),
                ),
                // ⭐ FIX: A new, custom-painted pointer for a better look.
                const Positioned(
                  top: -30,
                  child: _WheelPointer(),
                ),
              ],
            ),
            const SizedBox(height: 40),
            if (!_isSpinning)
              ElevatedButton(
                onPressed: _spin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                ),
                child: const Text('SPIN!',
                    style: TextStyle(fontSize: 24, color: Colors.black)),
              )
            else
              Container(
                height: 64,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(
                  color: Colors.orangeAccent,
                ),
              )
          ],
        ),
      ),
    );
  }
}

// ⭐ A new custom widget for the pointer
class _WheelPointer extends StatelessWidget {
  const _WheelPointer();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(40, 50), // Define the size of the pointer
      painter: _PointerPainter(),
    );
  }
}

class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFDD835), Color(0xFFFB8C00)], // Yellow to Orange
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final borderPaint = Paint()
      ..color = const Color(0xFFC66900) // Darker orange for the border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final path = Path();
    path.moveTo(size.width / 2, size.height); // Bottom center point
    path.lineTo(0, size.height * 0.4); // Top left
    path.quadraticBezierTo(
        size.width / 2,
        0, // Control point for the curve at the top
        size.width,
        size.height * 0.4); // Top right
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
