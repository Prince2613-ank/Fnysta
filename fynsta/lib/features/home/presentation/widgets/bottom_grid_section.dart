// lib/features/home/widgets/bottom_grid_section.dart
import 'package:flutter/material.dart';

class BottomGridSection extends StatelessWidget {
  final EdgeInsetsGeometry padding;

  const BottomGridSection({
    super.key,
    this.padding = const EdgeInsets.fromLTRB(15, 20, 15, 0),
  });

  @override
  Widget build(BuildContext context) {
    final bottomCards = [
      {'label': 'News', 'path': 'assets/news.png'},
      {'label': 'Astrology', 'path': 'assets/astrology.png'},
    ];

    return SliverPadding(
      padding: padding,
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          childAspectRatio: 0.75,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      // ⭐ FIX: Add a background color and a subtle border
                      color: Colors.white, // Ensures a solid card background
                      border: Border.all(
                        color: const Color.fromARGB(
                            255, 192, 191, 191), // Light grey border
                        width: 1.0, // 1 pixel wide
                      ),
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Transform.scale(
                        scale: index == 0 ? 1.1 : 1.0,
                        child: Image.asset(
                          bottomCards[index]['path']!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  bottomCards[index]['label']!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ],
            );
          },
          childCount: bottomCards.length,
        ),
      ),
    );
  }
}
