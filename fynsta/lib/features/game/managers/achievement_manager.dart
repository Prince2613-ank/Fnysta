// lib/features/game/managers/achievement_manager.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement_model.dart';
import 'package:flutter/material.dart';

class AchievementManager {
  static final AchievementManager _instance = AchievementManager._internal();
  factory AchievementManager() => _instance;
  AchievementManager._internal();

  List<Achievement> achievements = [
    Achievement(
        id: 'apples_1',
        title: 'Apple Picker',
        description: 'Collect 50 apples',
        icon: Icons.shopping_basket,
        goal: 50),
    Achievement(
        id: 'bosses_1',
        title: 'Boss Slayer',
        description: 'Defeat your first boss',
        icon: Icons.security,
        goal: 1),
    Achievement(
        id: 'score_1',
        title: 'High Scorer',
        description: 'Reach a score of 5000',
        icon: Icons.trending_up,
        goal: 5000),
  ];

  Future<void> loadAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    for (var ach in achievements) {
      ach.progress = prefs.getInt('ach_progress_${ach.id}') ?? 0;
      ach.isUnlocked = prefs.getBool('ach_unlocked_${ach.id}') ?? false;
    }
  }

  Future<void> _saveAchievement(Achievement ach) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('ach_progress_${ach.id}', ach.progress);
    await prefs.setBool('ach_unlocked_${ach.id}', ach.isUnlocked);
  }

  void updateProgress(String id, int value) {
    Achievement? ach = achievements.firstWhere((a) => a.id == id,
        orElse: () => throw Exception('Achievement not found'));
    if (ach.isUnlocked) return;

    ach.progress = value;
    if (ach.progress >= ach.goal) {
      ach.isUnlocked = true;
      // You could add a notification here to the user
    }
    _saveAchievement(ach);
  }
}
