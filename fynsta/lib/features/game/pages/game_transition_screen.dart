import 'package:flutter/material.dart';
import '../widgets/flying_emoji_painter.dart';
import 'game_list_screen.dart';

class GameTransitionScreen extends StatefulWidget {
  const GameTransitionScreen({super.key});

  @override
  State<GameTransitionScreen> createState() => _GameTransitionScreenState();
}

class _GameTransitionScreenState extends State<GameTransitionScreen> {
  @override
  void initState() {
    super.initState();
    // The flying emoji animation runs for 3.5 seconds.
    // We navigate after 3.6 seconds to ensure it completes fully.
    Future.delayed(const Duration(milliseconds: 3600), () {
      if (mounted) {
        // Replace the current screen with the game list for a smooth transition
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const GameListScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // This screen just shows a dark background with the animation playing on top.
    return const Scaffold(
      backgroundColor: Color(0xFF0C2434),
      body: Stack(
        children: [
          FlyingEmojiPainter(),
        ],
      ),
    );
  }
}
