// lib/features/game/widgets/game_over_overlay.dart
import 'package:flutter/material.dart';

class GameOverOverlay extends StatelessWidget {
  final int level;
  final VoidCallback onRestart;
  final int highScore;

  const GameOverOverlay({
    Key? key,
    required this.level,
    required this.onRestart,
    required this.highScore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;

    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              fit: BoxFit.contain,
              child: Text(
                'Game Over',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: screenWidth * 0.15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  shadows: const [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.red,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'You reached STAGE $level',
              style: TextStyle(
                color: Colors.white70,
                fontSize: isSmallScreen ? 18 : 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'High Score: $highScore',
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen ? 20 : 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: onRestart,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC107),
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 40 : 50,
                  vertical: isSmallScreen ? 15 : 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 8,
                shadowColor: Colors.yellowAccent,
              ),
              child: Text(
                'RESTART',
                style: TextStyle(
                  fontSize: isSmallScreen ? 20 : 24,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white, size: 30),
                  onPressed: () {
                    // TODO: Implement social sharing
                  },
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.leaderboard,
                      color: Colors.white, size: 30),
                  onPressed: () {
                    // TODO: Implement leaderboard
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
