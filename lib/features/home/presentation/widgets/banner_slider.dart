// lib/features/home/widgets/banner_slider.dart
import 'package:flutter/material.dart';

class BannerSlider extends StatefulWidget {
  final String? heading;
  final List<String> imagePaths;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? cardPadding;

  const BannerSlider({
    super.key,
    required this.imagePaths,
    this.heading,
    this.margin = const EdgeInsets.symmetric(vertical: 8.0),
    this.cardPadding = const EdgeInsets.symmetric(horizontal: 16.0),
  });

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final newPage = _pageController.page?.round();
      if (newPage != null && newPage != _currentPage) {
        setState(() {
          _currentPage = newPage;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imagePaths.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: widget.margin!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.heading != null)
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: widget.cardPadding?.horizontal ?? 0),
              child: Text(
                widget.heading!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (widget.heading != null) const SizedBox(height: 8),
          SizedBox(
            height: 180,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.imagePaths.length,
              itemBuilder: (context, index) {
                // The outer Padding is kept to control space between slider items
                return Padding(
                  padding: widget.cardPadding!,
                  // ⭐ FIX: Replaced Card with Container/ClipRRect
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: Image.asset(
                        widget.imagePaths[index],
                        // Use BoxFit.fill to remove transparent space in the image
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          _buildPageIndicator(),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.imagePaths.length, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          height: 8.0,
          width: _currentPage == index ? 24.0 : 8.0,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? const Color(0xFF0D47A1)
                : Colors.grey.shade400,
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }),
    );
  }
}
