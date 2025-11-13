import 'package:flutter/material.dart';

class GameHeader extends StatelessWidget {
  final int score;
  final int level;
  final int collectedApples;
  final VoidCallback onStoreTap;
  final int combo;

  const GameHeader({
    Key? key,
    required this.score,
    required this.level,
    required this.collectedApples,
    required this.onStoreTap,
    required this.combo,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Text('$score',
                  style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 36,
                      fontWeight: FontWeight.bold)),
              if (combo > 1)
                Text(
                  'x$combo',
                  style: const TextStyle(
                    color: Colors.yellow,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 49.0),
            child: Column(
              children: [
                Row(
                    children: List.generate(
                        5,
                        (index) => Icon(Icons.circle,
                            color: index < level % 5
                                ? Colors.orange
                                : Colors.white30,
                            size: 8))),
                const SizedBox(height: 5),
                Text('STAGE $level',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2)),
              ],
            ),
          ),
          _buildAppleCounter(context),
        ],
      ),
    );
  }
}
