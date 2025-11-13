// lib/features/game/widgets/pause_menu_overlay.dart
import 'package:flutter/material.dart';

class PauseMenuOverlay extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onQuit;
  final bool isSoundOn;
  final ValueChanged<bool> onSoundToggle;
  final VoidCallback onAchievements;
  final VoidCallback onDailyBonus;
  final bool canClaimDailyBonus;
  // ⭐ FIX 1: Define the missing parameter that knife_hit_screen is trying to use.
  final VoidCallback? onBonusCooldownTap;

  const PauseMenuOverlay({
    Key? key,
    required this.onResume,
    required this.onQuit,
    required this.isSoundOn,
    required this.onSoundToggle,
    required this.onAchievements,
    required this.onDailyBonus,
    required this.canClaimDailyBonus,
    this.onBonusCooldownTap, // ⭐ FIX 2: Add it to the constructor.
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;

    return Container(
      color: Colors.black.withOpacity(0.75),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Paused',
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen ? 40 : 50,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            _buildMenuButton(
              context,
              text: 'Resume',
              onPressed: onResume,
              icon: Icons.play_arrow,
              color: Colors.green,
            ),
            const SizedBox(height: 20),
            _buildMenuButton(
              context,
              text: 'Achievements',
              onPressed: onAchievements,
              icon: Icons.star,
              color: Colors.amber,
            ),
            const SizedBox(height: 20),
            _buildMenuButton(
              context,
              text: 'Daily Bonus',
              // ⭐ FIX 3: Use the parameter to make the disabled button tappable.
              onPressed: canClaimDailyBonus ? onDailyBonus : onBonusCooldownTap,
              icon: Icons.card_giftcard,
              color: canClaimDailyBonus
                  ? Colors.deepPurpleAccent
                  : const Color.fromARGB(255, 141, 69, 69),
            ),
            const SizedBox(height: 20),
            _buildMenuButton(
              context,
              text: 'Sound Off',
              onPressed: () => onSoundToggle(!isSoundOn),
              icon: isSoundOn ? Icons.volume_up : Icons.volume_off,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            _buildMenuButton(
              context,
              text: 'Quit',
              onPressed: onQuit,
              icon: Icons.exit_to_app,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required String text,
    required VoidCallback? onPressed,
    required IconData icon,
    required Color color,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;

    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 30 : 40,
            vertical: isSmallScreen ? 12 : 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      icon: Icon(icon, color: Colors.white),
      label: Text(
        text,
        style: TextStyle(
          fontSize: isSmallScreen ? 18 : 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
