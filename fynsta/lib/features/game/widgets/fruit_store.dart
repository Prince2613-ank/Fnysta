import 'package:flutter/material.dart';
import '../models/fruit_model.dart';

class FruitStore extends StatefulWidget {
  final List<Fruit> fruits;
  final Fruit currentFruit;
  final int collectedApples;
  final Function(Fruit) onFruitSelected;
  final Function(Fruit, int) onFruitUnlocked;

  const FruitStore({
    Key? key,
    required this.fruits,
    required this.currentFruit,
    required this.collectedApples,
    required this.onFruitSelected,
    required this.onFruitUnlocked,
  }) : super(key: key);

  @override
  _FruitStoreState createState() => _FruitStoreState();
}

class _FruitStoreState extends State<FruitStore>
    with SingleTickerProviderStateMixin {
  late Fruit _currentFruit;
  late int _collectedApples;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _currentFruit = widget.currentFruit;
    _collectedApples = widget.collectedApples;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 1.0, end: 1.1).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
          color: Color(0xFF34495E),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Fruit Store',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Wrap(
            spacing: 15,
            runSpacing: 15,
            children: widget.fruits.map((fruit) {
              bool isSelected = fruit.name == _currentFruit.name;
              return GestureDetector(
                onTap: () {
                  if (fruit.isUnlocked) {
                    setState(() => _currentFruit = fruit);
                    widget.onFruitSelected(fruit);
                  } else if (_collectedApples >= fruit.cost) {
                    setState(() {
                      _collectedApples -= fruit.cost;
                    });
                    widget.onFruitUnlocked(fruit, _collectedApples);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Not enough apples!"),
                        backgroundColor: Colors.red));
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.orange.withOpacity(0.5)
                          : Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: isSelected ? Colors.orange : Colors.grey,
                          width: 2)),
                  child: Column(
                    children: [
                      ScaleTransition(
                        scale: isSelected
                            ? _animation
                            : const AlwaysStoppedAnimation(1.0),
                        // MODIFIED: Conditionally display image or colored circle
                        child: fruit.imageAsset != null
                            ? Image.asset(fruit.imageAsset!,
                                width: 60,
                                height: 60,
                                color: fruit.isUnlocked
                                    ? null
                                    : Colors.black.withOpacity(0.7),
                                colorBlendMode: BlendMode.srcATop)
                            : Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: fruit.isUnlocked
                                      ? fruit.color
                                      : fruit.color?.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                              ),
                      ),
                      const SizedBox(height: 5),
                      if (!fruit.isUnlocked)
                        Row(
                          children: [
                            Image.asset('assets/apple.png',
                                width: 16, height: 16),
                            const SizedBox(width: 4),
                            Text('${fruit.cost}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold))
                          ],
                        )
                      else
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 20)
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20)
        ],
      ),
    );
  }
}
