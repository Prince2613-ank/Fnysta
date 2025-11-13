// lib/features/game/widgets/knife_store.dart
import 'package:flutter/material.dart';
import '../models/knife_model.dart';
import '../painters/knife_painter.dart';

class KnifeStore extends StatefulWidget {
  final List<Knife> knives;
  final Knife currentKnife;
  final int collectedApples;
  final Function(Knife) onKnifeSelected;
  final Function(Knife, int) onKnifeUnlocked;

  const KnifeStore({
    Key? key,
    required this.knives,
    required this.currentKnife,
    required this.collectedApples,
    required this.onKnifeSelected,
    required this.onKnifeUnlocked,
  }) : super(key: key);

  @override
  _KnifeStoreState createState() => _KnifeStoreState();
}

class _KnifeStoreState extends State<KnifeStore> {
  late Knife _currentKnife;
  late int _collectedApples;

  @override
  void initState() {
    super.initState();
    _currentKnife = widget.currentKnife;
    _collectedApples = widget.collectedApples;
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
          const Text('Knife Arsenal',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Wrap(
            spacing: 15,
            runSpacing: 15,
            alignment: WrapAlignment.center,
            children: widget.knives.map((knife) {
              bool isSelected = knife.name == _currentKnife.name;
              return GestureDetector(
                onTap: () {
                  if (knife.isUnlocked) {
                    setState(() => _currentKnife = knife);
                    widget.onKnifeSelected(knife);
                  } else if (_collectedApples >= knife.cost) {
                    setState(() {
                      _collectedApples -= knife.cost;
                    });
                    widget.onKnifeUnlocked(knife, _collectedApples);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Not enough apples to unlock!"),
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
                      SizedBox(
                        width: 45,
                        height: 90,
                        child: CustomPaint(
                            painter: KnifePainter(color: knife.color)),
                      ),
                      const SizedBox(height: 5),
                      if (!knife.isUnlocked)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset('assets/apple.png',
                                width: 16, height: 16),
                            const SizedBox(width: 4),
                            Text('${knife.cost}',
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
