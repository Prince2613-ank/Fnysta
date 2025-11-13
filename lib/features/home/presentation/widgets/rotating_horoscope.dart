import 'package:flutter/material.dart';
import 'dart:math' as math;

class _SemiCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height * 0.55));
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _ZodiacWheelPainter extends CustomPainter {
  final Offset center;
  final double outerRadius;
  final double innerRadius;

  _ZodiacWheelPainter({
    required this.center,
    required this.outerRadius,
    required this.innerRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.grey.withOpacity(0.15)
      ..strokeWidth = 1.0;

    const segmentCount = 12;
    for (int i = 0; i < segmentCount; i++) {
      final angle = (2 * math.pi / segmentCount) * i - (math.pi / 2);
      final p1 =
          center + Offset(math.cos(angle), math.sin(angle)) * innerRadius;
      final p2 =
          center + Offset(math.cos(angle), math.sin(angle)) * outerRadius;
      canvas.drawLine(p1, p2, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RotatingHoroscope extends StatefulWidget {
  const RotatingHoroscope({super.key});

  @override
  State<RotatingHoroscope> createState() => _RotatingHoroscopeState();
}

class _RotatingHoroscopeState extends State<RotatingHoroscope>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final ValueNotifier<double> _highlightOpacity = ValueNotifier(0.0);

  final List<String> zodiacIllustrations = [
    'assets/gemini2.png',
    'assets/cancer1.png',
    'assets/leo1.png',
    'assets/virgo1.png',
    'assets/libra2.png',
    'assets/scorpio1.png',
    'assets/sagittarius1.png',
    'assets/caprricorn1.png',
    'assets/aquarius1.png',
    'assets/pisces1.png',
    'assets/aries1.png',
    'assets/taurus1.png',
  ];

  final List<String> zodiacSymbolImages = [
    'assets/gemini.png',
    'assets/cancer.png',
    'assets/leo.png',
    'assets/virgo.png',
    'assets/libra.png',
    'assets/scorpio.png',
    'assets/sagittarius.png',
    'assets/capricorn.png',
    'assets/aquarius.png',
    'assets/pisces.png',
    'assets/aries.png',
    'assets/taurus.png',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _highlightOpacity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final center = Offset(size.width / 2, size.height / 2);

        final illustrationRadius = size.width * 0.34;
        final symbolRadius = size.width * 0.21;
        final wheelOuterRadius = size.width * 0.20;
        final wheelInnerRadius = size.width * 0.15;

        // ⭐ FIX: Changed the multiplier from 100.0 to 0.14 to correct the image size.
        final double illustrationSize = size.width * 0.14;
        final double glowSize = size.width * 0.14;
        const double symbolSize = 40.0;

        final satkonWidth = wheelInnerRadius * 2.0;

        return ClipPath(
          clipper: _SemiCircleClipper(),
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final rotation = _controller.value * 2 * math.pi;
                  const topAngle = 1.5 * math.pi;
                  const highlightZone = math.pi / 8;

                  int topIndex = 0;
                  double smallestDelta = 2 * math.pi;
                  for (int i = 0; i < 12; i++) {
                    final angle = (2 * math.pi / 12) * i;
                    final currentScreenAngle =
                        (angle + rotation) % (2 * math.pi);
                    double delta = (currentScreenAngle - topAngle).abs();
                    if (delta > math.pi) delta = 2 * math.pi - delta;
                    if (delta < smallestDelta) {
                      smallestDelta = delta;
                      topIndex = i;
                    }
                  }

                  double topItemProximity = 0.0;
                  if (smallestDelta < highlightZone) {
                    topItemProximity = 1.0 - (smallestDelta / highlightZone);
                  }

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_highlightOpacity.value != topItemProximity) {
                      _highlightOpacity.value = topItemProximity;
                    }
                  });

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.rotate(
                        angle: rotation,
                        child: CustomPaint(
                          size: size,
                          painter: _ZodiacWheelPainter(
                            center: center,
                            outerRadius: wheelOuterRadius,
                            innerRadius: wheelInnerRadius,
                          ),
                        ),
                      ),
                      ...List.generate(12, (index) {
                        const double angleOffset = 0.1;
                        final angle = (2 * math.pi / 12) * index;
                        final currentAngle = angle + rotation + angleOffset;

                        final ilX = center.dx +
                            illustrationRadius * math.cos(currentAngle);
                        final ilY = center.dy +
                            illustrationRadius * math.sin(currentAngle);
                        final symX =
                            center.dx + symbolRadius * math.cos(currentAngle);
                        final symY =
                            center.dy + symbolRadius * math.sin(currentAngle);

                        double scale = index == topIndex
                            ? 1.0 + topItemProximity * 0.4
                            : 1.0;
                        double symbolAndGlowOpacity =
                            index == topIndex ? topItemProximity : 0.0;

                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            if (index == topIndex)
                              Positioned(
                                left: ilX - glowSize / 2,
                                top: ilY - glowSize / 2,
                                child: Opacity(
                                  opacity: symbolAndGlowOpacity,
                                  child: Container(
                                    width: glowSize,
                                    height: glowSize,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color.fromARGB(
                                                  255, 157, 28, 204)
                                              .withOpacity(0.5),
                                          blurRadius: 20.0,
                                          spreadRadius: 5.0,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            Positioned(
                              left: ilX - illustrationSize / 2,
                              top: ilY - illustrationSize / 2,
                              child: Transform.scale(
                                scale: scale,
                                child: Image.asset(
                                  zodiacIllustrations[index],
                                  width: illustrationSize,
                                  height: illustrationSize,
                                ),
                              ),
                            ),
                            if (index == topIndex)
                              Positioned(
                                left: symX - symbolSize / 2,
                                top: symY - symbolSize / 2,
                                child: Opacity(
                                  opacity: symbolAndGlowOpacity,
                                  child: Image.asset(
                                    zodiacSymbolImages[index],
                                    width: symbolSize,
                                    height: symbolSize,
                                  ),
                                ),
                              ),
                          ],
                        );
                      }),
                    ],
                  );
                },
              ),
              ValueListenableBuilder<double>(
                valueListenable: _highlightOpacity,
                builder: (context, opacity, child) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 20.0, right: 55.0),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Opacity(
                        opacity: 1.0,
                        child: Image.asset(
                          'assets/lightbeam.png',
                          width: size.width * 1.75,
                          height: size.height * 0.40,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                top: center.dy - 40,
                left: center.dx - (satkonWidth / 2),
                child: ClipRect(
                  child: Align(
                    alignment: Alignment.topCenter,
                    heightFactor: 0.5,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Transform.translate(
                        offset: const Offset(0, -13),
                        child: Image.asset(
                          'assets/satkon.png',
                          width: satkonWidth * 0.9,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
