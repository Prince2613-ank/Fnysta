import 'package:flutter/foundation.dart';

@immutable
class Fruit {
  final String name;
  final String imageAsset;
  final int cost;
  final bool isUnlocked;

  const Fruit({
    required this.name,
    required this.imageAsset,
    required this.cost,
    this.isUnlocked = false,
  });

  Fruit copyWith({bool? isUnlocked}) {
    return Fruit(
      name: name,
      imageAsset: imageAsset,
      cost: cost,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}
