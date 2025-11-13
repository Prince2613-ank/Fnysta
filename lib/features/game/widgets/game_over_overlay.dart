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
    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Game Over',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 60,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.red,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'You reached STAGE $level',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'High Score: $highScore',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: onRestart,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC107),
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 8,
                shadowColor: Colors.yellowAccent,
              ),
              child: const Text(
                'RESTART',
                style: TextStyle(
                  fontSize: 24,
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
