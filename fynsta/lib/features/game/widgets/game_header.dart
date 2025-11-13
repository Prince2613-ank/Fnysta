// lib/features/game/widgets/game_header.dart
import 'package:flutter/material.dart';

class GameHeader extends StatelessWidget {
  final int score;
  final int level;
  final int collectedApples;
  final VoidCallback onStoreTap;
  final VoidCallback onPauseTap;
  final int combo;
  final bool isBossLevel;
  final int reviveCount;
  final int slowMoCount;

  const GameHeader({
    Key? key,
    required this.score,
    required this.level,
    required this.collectedApples,
    required this.onStoreTap,
    required this.onPauseTap,
    required this.combo,
    required this.isBossLevel,
    required this.reviveCount,
    required this.slowMoCount,
  }) : super(key: key);

  Widget _buildAppleCounter(BuildContext context) {
    const double appleIconSize = 60.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('$collectedApples',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
        const SizedBox(width: 1),
        GestureDetector(
          onTap: onStoreTap,
          child: Image.asset(
            'assets/apple.png',
            width: 55,
            height: appleIconSize,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // A simple combo threshold for the reward
    const int comboRewardThreshold = 10;
    final double comboProgress = (combo / comboRewardThreshold).clamp(0.0, 1.0);

    // This is the original, unchanged widget for the stage/boss display
    Widget stageDisplay = Padding(
      padding: const EdgeInsets.only(right: 28.0),
      child: Column(
        children: [
          Row(
              children: List.generate(
                  5,
                  (index) => Icon(Icons.circle,
                      color: isBossLevel
                          ? Colors.red
                          : (index < level % 5
                              ? Colors.orange
                              : Colors.white30),
                      size: 8))),
          const SizedBox(height: 5),
          Text(isBossLevel ? 'BOSS FIGHT!' : 'STAGE $level',
              style: TextStyle(
                  color: isBossLevel ? Colors.redAccent : Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2)),
        ],
      ),
    );

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.pause, color: Colors.white, size: 30),
              onPressed: onPauseTap,
            ),
            Column(
              children: [
                Text('$score',
                    style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 36,
                        fontWeight: FontWeight.bold)),
                if (combo > 1)
                  Column(
                    children: [
                      Text(
                        'x$combo',
                        style: const TextStyle(
                          color: Colors.yellow,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      SizedBox(
                        width: 60,
                        child: LinearProgressIndicator(
                          value: comboProgress,
                          backgroundColor: Colors.grey,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.yellowAccent),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.red, size: 20),
                    const SizedBox(width: 4),
                    Text('$reviveCount',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(width: 15),
                    const Icon(Icons.slow_motion_video,
                        color: Colors.blue, size: 20),
                    const SizedBox(width: 4),
                    Text('$slowMoCount',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ],
                )
              ],
            ),
            // ⭐ FIX: Conditionally wrap the stage display to handle overflow
            // only during a boss fight.
            if (isBossLevel) Flexible(child: stageDisplay) else stageDisplay,
            _buildAppleCounter(context),
          ],
        ),
      ),
    );
  }
}
