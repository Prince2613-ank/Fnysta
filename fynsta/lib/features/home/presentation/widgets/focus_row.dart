// lib/features/home/widgets/focus_row.dart
import 'dart:async';
import 'package:flutter/material.dart';

class FocusRow extends StatefulWidget {
  final List<Map<String, String>> cardData;
  final double cardAspectRatio;

  const FocusRow({
    super.key,
    required this.cardData,
    this.cardAspectRatio = 3 / 4,
  });

  @override
  State<FocusRow> createState() => _FocusRowState();
}

class _FocusRowState extends State<FocusRow> {
  int _focusedIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _focusedIndex = (_focusedIndex + 1) % widget.cardData.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ⭐ FIX 1: Set a fixed height for the entire section.
    // This is the most important change to stop the screen from moving up and down.
    return SizedBox(
      height: 200, // Adjust this height to fit your design
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(widget.cardData.length, (index) {
          bool isFocused = (index == _focusedIndex);

          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              // ⭐ FIX 2: Animate margin to create the slide/focus effect.
              margin: EdgeInsets.symmetric(horizontal: isFocused ? 6.0 : 12.0),
              child: AspectRatio(
                aspectRatio: widget.cardAspectRatio,
                // ⭐ FIX 3: Animate the scale for a visual zoom without layout changes.
                child: Transform.scale(
                  scale: isFocused ? 1.15 : 1.0,
                  alignment: Alignment.center,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color:
                              Colors.black.withOpacity(isFocused ? 0.2 : 0.1),
                          blurRadius: isFocused ? 8 : 4,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: Image.asset(
                        widget.cardData[index]['image']!,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
