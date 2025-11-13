// lib/features/game/pages/achievements_screen.dart
import 'package:flutter/material.dart';
import '../managers/achievement_manager.dart';
import '../models/achievement_model.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  @override
  _AchievementsScreenState createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final AchievementManager _achievementManager = AchievementManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: _achievementManager.achievements.length,
        itemBuilder: (context, index) {
          final achievement = _achievementManager.achievements[index];
          final progress =
              (achievement.progress / achievement.goal).clamp(0.0, 1.0);

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: achievement.isUnlocked
                ? Colors.green.withOpacity(0.3)
                : Theme.of(context).cardColor,
            child: ListTile(
              leading: Icon(
                achievement.icon,
                size: 40,
                color: achievement.isUnlocked ? Colors.green : Colors.grey,
              ),
              title: Text(achievement.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(achievement.description),
                  if (!achievement.isUnlocked)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[300],
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                ],
              ),
              trailing: achievement.isUnlocked
                  ? const Icon(Icons.check_circle,
                      color: Colors.green, size: 30)
                  : Text('${achievement.progress}/${achievement.goal}'),
            ),
          );
        },
      ),
    );
  }
}
