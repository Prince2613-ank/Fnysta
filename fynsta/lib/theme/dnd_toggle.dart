import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class DndToggle extends StatelessWidget {
  const DndToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return IconButton(
      icon: Icon(
        themeProvider.isDarkMode ? Icons.nights_stay : Icons.wb_sunny,
      ),
      onPressed: () {
        themeProvider.toggleTheme();
      },
    );
  }
}
