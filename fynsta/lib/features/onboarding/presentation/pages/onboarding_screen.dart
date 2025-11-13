// lib/features/onboarding/presentation/pages/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../theme/dnd_toggle.dart';
import '../../../../theme/theme_provider.dart';

class OnboardingPageInfo {
  final String? imageAsset;
  final String title;
  final String? description;
  final bool isFirstPage;

  OnboardingPageInfo({
    this.imageAsset,
    required this.title,
    this.description,
    this.isFirstPage = false,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _buttonAnimationController;
  late Animation<double> _scaleAnimation;
  late AnimationController _skipButtonAnimationController;
  late Animation<double> _skipButtonBreatheAnimation;

  final List<OnboardingPageInfo> _pages = [
    OnboardingPageInfo(
      imageAsset: 'assets/logoo.png',
      title: 'Fnysta',
      isFirstPage: true,
    ),
    OnboardingPageInfo(
      imageAsset: 'assets/horoimage.png',
      title: 'Kundali. Horoscope.',
      description:
          'Plan, Predict & Find Match "Connect with your future Horoscope, kundali, and matchmaking made simple."',
    ),
    OnboardingPageInfo(
      imageAsset: 'assets/markettrend.png',
      title: 'Market Trends',
      description:
          'Your Daily Market Dose! Quick insights, sector highlights, and economic trends to keep you smart, sharp & aware.',
    ),
    OnboardingPageInfo(
      imageAsset: 'assets/nextgen.png',
      title: 'Fnysta Game Zone',
      description:
          'Play. Connect. Win. Repeat. Experience social games, instant fun, and non-stop entertainment built for today\'s thrill-loving gamers.',
    ),
  ];

  void _navigateToLogin() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  void initState() {
    super.initState();
    _buttonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation =
        Tween<double>(begin: 1.0, end: 1.1).animate(_buttonAnimationController);
    _buttonAnimationController.repeat(reverse: true);

    _skipButtonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _skipButtonBreatheAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _skipButtonAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _buttonAnimationController.dispose();
    _skipButtonAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    SystemChrome.setSystemUIOverlayStyle(themeProvider.isDarkMode
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark);
    bool isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return OnboardingPage(
                pageInfo: _pages[index],
                isActive: index == _currentPage,
              );
            },
          ),
          const Positioned(
            top: 40,
            right: 10,
            child: DndToggle(),
          ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ⭐ Animated "Skip" Button
                ScaleTransition(
                  scale: _skipButtonBreatheAnimation,
                  child: AnimatedOpacity(
                    opacity: _currentPage > 0 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeIn,
                    child: InkWell(
                      onTap: _navigateToLogin,
                      borderRadius: BorderRadius.circular(20.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          // ⭐ FIX: Set background color based on theme. Black for light, white for dark.
                          color: themeProvider.isDarkMode
                              ? Colors.white
                              : Colors.black,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            // ⭐ FIX: Set text color for contrast.
                            color: themeProvider.isDarkMode
                                ? Colors.black
                                : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ⭐ Animated Page Indicator
                AnimatedOpacity(
                  opacity: _currentPage > 0 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeIn,
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: _pages.length - 1,
                    onDotClicked: (index) => _pageController.animateToPage(
                      index + 1,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeIn,
                    ),
                    effect: ExpandingDotsEffect(
                      dotColor: Colors.grey,
                      activeDotColor: themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.black,
                      dotHeight: 8,
                      dotWidth: 8,
                    ),
                  ),
                ),

                // ⭐ Animated Next/Done Button
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(scale: animation, child: child),
                    );
                  },
                  child: _currentPage == 0
                      ? IconButton(
                          key: const ValueKey('arrow_button'),
                          icon: const Icon(Icons.arrow_forward_ios,
                              color: Color(0xFF004AAD), size: 18),
                          onPressed: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                            );
                          },
                        )
                      : ScaleTransition(
                          key: const ValueKey('circle_button'),
                          scale: _scaleAnimation,
                          child: InkWell(
                            onTap: () {
                              if (isLastPage) {
                                _navigateToLogin();
                              } else {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeIn,
                                );
                              }
                            },
                            child: CircleAvatar(
                              backgroundColor: themeProvider.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                              radius: 25,
                              child: Icon(
                                isLastPage
                                    ? Icons.check
                                    : Icons.arrow_forward_ios,
                                color: themeProvider.isDarkMode
                                    ? Colors.black
                                    : Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatefulWidget {
  final OnboardingPageInfo pageInfo;
  final bool isActive;
  const OnboardingPage(
      {super.key, required this.pageInfo, required this.isActive});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    if (widget.isActive) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant OnboardingPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _animationController.forward(from: 0.0);
    } else if (!widget.isActive && oldWidget.isActive) {
      _animationController.reverse(from: 1.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    List<TextSpan> _buildTextSpans(String text, Color textColor) {
      final List<TextSpan> spans = [];
      final boldWords = ['Horoscope', 'sector highlights', 'entertainment'];

      text.splitMapJoin(
        RegExp(r'\b(' + boldWords.join('|') + r')\b'),
        onMatch: (m) {
          spans.add(
            TextSpan(
              text: m[0],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          );
          return '';
        },
        onNonMatch: (n) {
          spans.add(
            TextSpan(
              text: n,
              style: TextStyle(
                color: textColor,
              ),
            ),
          );
          return '';
        },
      );
      return spans;
    }

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.pageInfo.imageAsset != null)
            FadeTransition(
              opacity: CurvedAnimation(
                  parent: _animationController, curve: Curves.easeIn),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.5),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                    parent: _animationController, curve: Curves.easeOut)),
                child: Image.asset(
                  widget.pageInfo.imageAsset!,
                  height: widget.pageInfo.isFirstPage ? 220 : 250,
                ),
              ),
            ),
          if (widget.pageInfo.isFirstPage)
            Transform.translate(
              offset: const Offset(0, -50),
              child: FadeTransition(
                opacity: CurvedAnimation(
                    parent: _animationController, curve: Curves.easeIn),
                child: Text(
                  widget.pageInfo.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF004AAD),
                  ),
                ),
              ),
            )
          else ...[
            const SizedBox(height: 60),
            FadeTransition(
              opacity: CurvedAnimation(
                  parent: _animationController, curve: Curves.easeIn),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.5),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                    parent: _animationController,
                    curve: const Interval(0.3, 1.0, curve: Curves.easeOut))),
                child: Text(
                  widget.pageInfo.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color:
                        themeProvider.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ],
          if (widget.pageInfo.description != null) ...[
            const SizedBox(height: 20),
            FadeTransition(
              opacity: CurvedAnimation(
                  parent: _animationController, curve: Curves.easeIn),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.5),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                    parent: _animationController,
                    curve: const Interval(0.6, 1.0, curve: Curves.easeOut))),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: _buildTextSpans(
                      widget.pageInfo.description!,
                      themeProvider.isDarkMode
                          ? Colors.white70
                          : Colors.black54,
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: themeProvider.isDarkMode
                          ? Colors.white70
                          : Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
