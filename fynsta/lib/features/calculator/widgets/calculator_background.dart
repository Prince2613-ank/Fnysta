import 'package:flutter/material.dart';
import 'dart:math';

class CalculatorBackground extends StatelessWidget {
  final Widget child;

  const CalculatorBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final List<Color> lightGradientColors = [
      const Color(0xFFE3F2FD), // Light Blue
      const Color(0xFFBBDEFB), // Slightly darker blue
      const Color(0xFF90CAF9), // Even darker blue
    ];
    final List<Color> darkGradientColors = [
      const Color(0xFF1A237E), // Deep Indigo
      const Color(0xFF283593), // Slightly lighter Indigo
      const Color(0xFF303F9F), // Even lighter Indigo
    ];

    final Color shapeColorLight = const Color(0xFF004AAD).withOpacity(0.15);
    final Color shapeColorDark = Colors.blueAccent.withOpacity(0.1);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode ? darkGradientColors : lightGradientColors,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -150,
              left: -150,
              child: _buildShape(isDarkMode ? shapeColorDark : shapeColorLight,
                  400, BorderRadius.circular(200)),
            ),
            Positioned(
              bottom: -200,
              right: -200,
              child: _buildShape(isDarkMode ? shapeColorDark : shapeColorLight,
                  500, BorderRadius.circular(250)),
            ),
            Positioned(
              top: 50,
              right: -50,
              child: _buildShape(
                  isDarkMode
                      ? shapeColorDark.withOpacity(0.08)
                      : shapeColorLight.withOpacity(0.08),
                  200,
                  BorderRadius.circular(100)),
            ),
            Positioned(
              bottom: 100,
              left: -80,
              child: _buildShape(
                  isDarkMode
                      ? shapeColorDark.withOpacity(0.08)
                      : shapeColorLight.withOpacity(0.08),
                  250,
                  BorderRadius.circular(125)),
            ),
            // ⭐ FIX: Ensure the child (your calculator content) has explicit constraints
            // and apply the safe area padding directly to the child content.
            Positioned.fill(
              child: Builder(
                // Using Builder to get a new BuildContext for MediaQuery
                builder: (BuildContext innerContext) {
                  return Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(innerContext).padding.top),
                    child:
                        child, // The child is expected to handle its own scrolling if necessary
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShape(Color color, double size, BorderRadius borderRadius) {
    return Transform.rotate(
        angle: Random().nextDouble() * 2 * pi,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: borderRadius,
          ),
        ));
  }
}
