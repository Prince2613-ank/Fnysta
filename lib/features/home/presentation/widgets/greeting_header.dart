// lib/features/home/widgets/greeting_header.dart
import 'package:flutter/material.dart';

class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: GestureDetector(
          onTap: () {
            // Navigate to the profile screen when tapped
            Navigator.pushNamed(context, '/profile');
          },
          child: Container(
            clipBehavior: Clip.hardEdge,
            padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 17),
            decoration: BoxDecoration(
              color: const Color(0xFF1A73E8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Hello, Prince!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'September, 17 2025 - 05:56 AM',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
