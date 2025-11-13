import 'package:flutter/material.dart';

class LevelCompleteOverlay extends StatelessWidget {
  final int level;

  const LevelCompleteOverlay({Key? key, required this.level}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('STAGE ${level - 1} COMPLETE!',
                style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black, blurRadius: 10)])),
          ],
        ),
      ),
    );
  }
}
