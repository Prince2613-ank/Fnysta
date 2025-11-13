// lib/features/game/pages/game_list_screen.dart
import 'dart:async'; // Import async
import 'package:flutter/material.dart';
import 'package:fynsta/features/game/pages/color_switch_screen.dart';
import 'package:fynsta/features/game/pages/knife_hit_screen.dart';

// Import the new slot machine screen
import 'package:fynsta/features/game/pages/slot_machine_screen.dart';
// Import the new animation widget
import '../widgets/flying_emoji_painter.dart';

// CONVERT TO STATEFULWIDGET
class GameListScreen extends StatefulWidget {
  const GameListScreen({super.key});

  @override
  State<GameListScreen> createState() => _GameListScreenState();
}

class _GameListScreenState extends State<GameListScreen> {
  bool _showAnimation = false;
  Timer? _animationTimer;

  void _triggerAnimation() {
    setState(() {
      _showAnimation = true;
    });

    // Cancel any existing timer to avoid conflicts
    _animationTimer?.cancel();
    // The animation runs for 3.5 seconds, so we'll hide it after 4.
    _animationTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _showAnimation = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationTimer?.cancel(); // Dispose the timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Zone'),
        centerTitle: true,
      ),
      // WRAP BODY IN A STACK
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _GameListItem(
                title: 'Knife Hit',
                subtitle: 'Throw knives and break the log!',
                gradientColors: const [
                  Color.fromARGB(255, 34, 42, 199),
                  Color.fromARGB(255, 153, 179, 22),
                ],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const KnifeHitGame()),
                  );
                },
              ),
              const SizedBox(height: 16),
              // New list item for the Slot Machine Game
              _GameListItem(
                title: 'Slot Machine',
                subtitle: 'Spin the wheel and test your luck!',
                icon: Icons.casino,
                gradientColors: const [
                  Color(0xFF6A1B9A), // Dark Purple
                  Color(0xFFD81B60), // Pink
                ],
                onTap: () {
                  // Navigate using the new named route
                  Navigator.pushNamed(context, '/slot_machine');
                },
              ),
              // New list item for the Color Switch Game
              const SizedBox(height: 16),
              _GameListItem(
                title: 'Color Switch',
                subtitle: 'Match the colors and switch it up!',
                icon: Icons.palette,
                gradientColors: const [
                  Color(0xFF8e44ad), // Amethyst
                  Color(0xFF3498db), // Peter River
                ],
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ColorSwitchScreen()));
                },
              ),
              const SizedBox(height: 30),
              // ADD THE NEW BUTTON
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Wing', style: TextStyle(fontSize: 18)),
                  onPressed: _triggerAnimation,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // ADD THE ANIMATION WIDGET TO THE STACK
          if (_showAnimation) const FlyingEmojiPainter(),
        ],
      ),
    );
  }
}

// Helper widget to create consistent list items with tap animations
class _GameListItem extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final VoidCallback onTap;
  final IconData icon;

  const _GameListItem({
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.onTap,
    this.icon = Icons.gamepad_outlined,
  });

  @override
  State<_GameListItem> createState() => _GameListItemState();
}

class _GameListItemState extends State<_GameListItem> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() => _scale = 0.95);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _scale = 1.0);
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) {
        widget.onTap();
      }
    });
  }

  void _onTapCancel() {
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            leading: Icon(widget.icon, size: 28, color: Colors.white),
            title: Text(widget.title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white)),
            subtitle: Text(widget.subtitle,
                style: const TextStyle(fontSize: 14, color: Colors.white70)),
            trailing: const Icon(Icons.arrow_forward_ios,
                size: 18, color: Colors.white70),
          ),
        ),
      ),
    );
  }
}
