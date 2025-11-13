import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum PowerUpType { none, coinMagnet, invincibility }

@immutable
class Fruit {
  final String name;
  // MODIFIED: imageAsset is now optional
  final String? imageAsset;
  final int cost;
  final bool isUnlocked;
  final PowerUpType powerUp;
  // ADDED: color property for procedurally drawn fruits
  final Color? color;

  const Fruit({
    required this.name,
    this.imageAsset,
    required this.cost,
    this.isUnlocked = false,
    this.powerUp = PowerUpType.none,
    this.color,
  });

  Fruit copyWith({bool? isUnlocked}) {
    return Fruit(
      name: name,
      imageAsset: imageAsset,
      cost: cost,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      powerUp: powerUp,
      color: color,
    );
  }
}
