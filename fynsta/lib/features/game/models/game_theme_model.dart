// lib/features/game/models/game_theme_model.dart
import 'package:flutter/material.dart';

class GameTheme {
  final String name;
  final List<Color> backgroundGradient;
  final Color logBaseColor;
  final Color logBarkColor;
  final Color logRingColor;
  final String hitSound;
  // You could add theme-specific music here as well
  // final String music;

  const GameTheme({
    required this.name,
    required this.backgroundGradient,
    required this.logBaseColor,
    required this.logBarkColor,
    required this.logRingColor,
    required this.hitSound,
  });
}
