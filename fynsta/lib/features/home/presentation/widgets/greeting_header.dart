import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ⭐ FIX: GreetingHeader now accepts a userName
class GreetingHeader extends StatefulWidget {
  final String? userName;
  const GreetingHeader({super.key, this.userName});

  @override
  State<GreetingHeader> createState() => _GreetingHeaderState();
}

class _GreetingHeaderState extends State<GreetingHeader> {
  String _formattedDateTime = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer =
        Timer.periodic(const Duration(minutes: 1), (Timer t) => _updateTime());
  }

  void _updateTime() {
    final String formatted =
        DateFormat('MMMM, d yyyy - hh:mm a').format(DateTime.now());
    if (mounted) {
      setState(() {
        _formattedDateTime = formatted;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ⭐ FIX: Use the passed userName, or default to "User"
    final displayName = widget.userName ?? 'User';

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/profile');
          },
          child: Container(
            clipBehavior: Clip.hardEdge,
            padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 17),
            decoration: BoxDecoration(
              color: const Color(0xFF1A73E8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // ⭐ FIX: Displaying the dynamic user name
                  'Hello, $displayName!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formattedDateTime,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
