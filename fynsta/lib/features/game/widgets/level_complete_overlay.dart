// lib/features/game/widgets/level_complete_overlay.dart
import 'package:flutter/material.dart';

class LevelCompleteOverlay extends StatefulWidget {
  final int level;

  const LevelCompleteOverlay({Key? key, required this.level}) : super(key: key);

  @override
  State<LevelCompleteOverlay> createState() => _LevelCompleteOverlayState();
}

class _LevelCompleteOverlayState extends State<LevelCompleteOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut, // A bouncy effect
    );

    // Start the animation as soon as the widget is built
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      color: Colors.black.withOpacity(0.75),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Text(
                'STAGE ${widget.level - 1} COMPLETE!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 50,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                      blurRadius: 15.0,
                      color: Colors.black,
                      offset: Offset(0, 0),
                    ),
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.green,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
