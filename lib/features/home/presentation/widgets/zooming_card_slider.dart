// lib/features/home/widgets/zooming_card_slider.dart
import 'dart:async';
import 'package:flutter/material.dart';

class ZoomingCardSlider extends StatefulWidget {
  final List<Map<String, String>> cardData;
  final double cardHeight;
  final double viewportFraction;
  final double zoomFactor;
  final bool showIndicator; // ⭐ 1. Add new parameter
  final bool autoSwipe; // ⭐ Add new parameter

  const ZoomingCardSlider({
    super.key,
    required this.cardData,
    this.cardHeight = 240,
    this.viewportFraction = 0.65,
    this.zoomFactor = 0.15,
    this.showIndicator = true, // Default to true
    this.autoSwipe = true, // Default to true
  });

  @override
  State<ZoomingCardSlider> createState() => _ZoomingCardSliderState();
}

class _ZoomingCardSliderState extends State<ZoomingCardSlider> {
  late PageController _pageController;
  double _currentPage = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: widget.viewportFraction,
      initialPage: 0,
    );

    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0.0;
      });
    });

    if (widget.autoSwipe) {
      _startAutoSwipe();
    }
  }

  void _startAutoSwipe() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      int nextPage =
          (_pageController.page!.round() + 1) % widget.cardData.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cardData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: widget.cardHeight + (widget.cardHeight * widget.zoomFactor),
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.cardData.length,
            itemBuilder: (context, index) {
              double diff = index - _currentPage;
              diff = diff.clamp(-1.0, 1.0);
              final double scale = 1.0 - (diff.abs() * widget.zoomFactor);

              return Align(
                alignment: Alignment.center,
                child: Transform.scale(
                  scale: scale,
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: SizedBox(
                      height: widget.cardHeight,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            widget.cardData[index]['image']!,
                            fit: BoxFit.cover,
                          ),
                          if (widget.cardData[index]['title'] != null)
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.1),
                                    Colors.black.withOpacity(0.7),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  stops: const [0.5, 0.7, 1.0],
                                ),
                              ),
                            ),
                          if (widget.cardData[index]['title'] != null)
                            Positioned(
                              bottom: 16,
                              left: 16,
                              right: 16,
                              child: Text(
                                widget.cardData[index]['title']!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // ⭐ 2. Conditionally show the indicator
        if (widget.showIndicator) ...[
          const SizedBox(height: 12),
          _buildPageIndicator(),
        ],
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.cardData.length, (index) {
        int currentPageInt = _currentPage.round() % widget.cardData.length;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          height: 8.0,
          width: currentPageInt == index ? 24.0 : 8.0,
          decoration: BoxDecoration(
            color: currentPageInt == index
                ? const Color(0xFF0D47A1)
                : Colors.grey.shade400,
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }),
    );
  }
}
