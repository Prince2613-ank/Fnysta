// lib/features/game/widgets/boss_tutorial_overlay.dart
import 'package:flutter/material.dart';

class BossTutorialOverlay extends StatelessWidget {
  final VoidCallback onStart;

  const BossTutorialOverlay({Key? key, required this.onStart})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;

    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24.0),
          margin: const EdgeInsets.symmetric(horizontal: 20.0),
          decoration: BoxDecoration(
            color: const Color(0xFF2c3e50),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.redAccent, width: 3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'BOSS FIGHT!',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: isSmallScreen ? 32 : 40,
                  fontWeight: FontWeight.w900,
                  shadows: const [
                    Shadow(blurRadius: 10, color: Colors.red),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'The log is now armored. Avoid hitting the metal plates!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 16 : 18,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'Aim carefully for the wooden parts to win.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 16 : 18,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: onStart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 30 : 40,
                      vertical: isSmallScreen ? 12 : 15),
                ),
                child: Text(
                  "Let's Go!",
                  style: TextStyle(
                      fontSize: isSmallScreen ? 18 : 20,
                      fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
