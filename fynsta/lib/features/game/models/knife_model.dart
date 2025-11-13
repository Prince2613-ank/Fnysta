// lib/features/game/models/knife_model.dart
import 'package:flutter/material.dart';

enum KnifeAbility { none, slowing, secondChance }

@immutable
class Knife {
  final String name;
  final KnifeAbility ability;
  final Color color;
  final int cost;
  final bool isUnlocked;

  const Knife({
    required this.name,
    required this.ability,
    required this.color,
    this.cost = 0,
    this.isUnlocked = false,
  });

  Knife copyWith({bool? isUnlocked}) {
    return Knife(
      name: name,
      ability: ability,
      color: color,
      cost: cost,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}
