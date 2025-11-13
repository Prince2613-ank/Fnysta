import 'package:flutter/material.dart';

class TutorialOverlay extends StatefulWidget {
  final VoidCallback onDismiss;

  const TutorialOverlay({Key? key, required this.onDismiss}) : super(key: key);

  @override
  _TutorialOverlayState createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController1;
  late AnimationController _slideController2;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..forward();
    _slideController1 = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _slideController2 = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _slideController1.forward();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _slideController2.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController1.dispose();
    _slideController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeController,
      child: Container(
        color: Colors.black.withOpacity(0.85),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'How to Play',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.cyanAccent, blurRadius: 10)],
                ),
              ),
              const SizedBox(height: 40),
              _buildRuleRow(
                  _slideController1, Icons.casino, 'Match 3 to win 100 COINS!'),
              const SizedBox(height: 30),
              _buildRuleRow(_slideController2, Icons.star,
                  'Match 2 to boost your SCORE!'),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: widget.onDismiss,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: const Text(
                  'Got It!',
                  style: TextStyle(
                      fontSize: 22,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRuleRow(
      AnimationController controller, IconData icon, String text) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1.5, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.cyanAccent.withOpacity(0.7)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.yellowAccent, size: 40),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
