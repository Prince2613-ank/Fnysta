import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../theme/theme_provider.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    const double iconSize = 38.0;
    const double selectedLabelSize = 14.0;

    final navBarColor = isDarkMode ? Colors.grey[900] : Colors.white;
    final selectedColor =
        isDarkMode ? Colors.blue[300] : const Color(0xFF0D47A1);
    final unselectedColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: navBarColor,
      elevation: 10,
      showSelectedLabels: true,
      showUnselectedLabels: false,
      selectedItemColor: selectedColor,
      selectedFontSize: selectedLabelSize,
      unselectedItemColor: unselectedColor,
      items: [
        BottomNavigationBarItem(
          icon:
              Image.asset('assets/nav6.png', width: iconSize, height: iconSize),
          activeIcon:
              Image.asset('assets/nav6.png', width: iconSize, height: iconSize),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon:
              Image.asset('assets/nav7.png', width: iconSize, height: iconSize),
          label: 'Astrology',
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/nav8.png',
              width: iconSize + 8, height: iconSize + 8),
          label: 'Community',
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/nav10.png',
              width: iconSize, height: iconSize),
          // ⭐ FIX: Swapped label to correctly show 'News' for the NewsScreen.
          label: 'News',
        ),
        BottomNavigationBarItem(
          icon:
              Image.asset('assets/game.png', width: iconSize, height: iconSize),
          // ⭐ FIX: Swapped label to correctly show 'News' for the NewsScreen.
          label: 'Game',
        ),

        // 🎯 REMOVED: The calculator icon is now gone
      ],
    );
  }
}
