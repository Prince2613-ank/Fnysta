// lib/features/game/models/achievement_model.dart
import 'package:flutter/material.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int goal;
  bool isUnlocked;
  int progress;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.goal,
    this.isUnlocked = false,
    this.progress = 0,
  });
}
