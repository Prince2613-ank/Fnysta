// lib/features/home/widgets/horoscope_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Make sure these paths are correct for your project
import '../../../../theme/theme_provider.dart';
import '../widgets/rotating_horoscope.dart';

class HoroscopeSection extends StatelessWidget {
  const HoroscopeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return SliverToBoxAdapter(
      // ⭐ FIX: Removed the Container and Padding to allow the parent to control the layout.
      child: SizedBox(
        height: 360,
        child: RotatingHoroscope(), // Assuming this widget exists
      ),
    );
  }
}
