import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../../../theme/theme_provider.dart';
import '../../../astrology/presentation/pages/astrology_screen.dart';
import '../../../community/presentation/pages/community_screen.dart';
import '../../../game/pages/game_list_screen.dart';
import '../../../news/presentation/pages/news_screen.dart';
import '../../../calculator/presentation/pages/calculator_list_screen.dart';
import '../../../user/domain/entities/user_entity.dart';
import '../widgets/greeting_header.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/horoscope_section.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../widgets/banner_slider.dart';

class HomeScreen extends StatefulWidget {
  final UserEntity? user;
  const HomeScreen({super.key, this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = [
      _HomeContent(user: widget.user),
      const AstrologyScreen(),
      const CommunityScreen(),
      const NewsScreen(),
      const GameListScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final bgColor = isDarkMode ? Colors.grey[900] : const Color(0xFFF4F6F9);

    return Scaffold(
      backgroundColor: bgColor,
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  final UserEntity? user;
  const _HomeContent({this.user});

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  late PageController _pageController;
  int _currentPage = 1;
  final List<String> _successImages = [
    'assets/success4.png',
    'assets/success5.png',
    'assets/success6.png',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.35,
      initialPage: _currentPage,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final bgColor = isDarkMode ? Colors.grey[900] : const Color(0xFFF4F6F9);
    final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.black87;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: bgColor,
          pinned: true,
          floating: true,
          elevation: 0,
          titleSpacing: 0,
          title: const HomeAppBar(),
        ),
        GreetingHeader(userName: widget.user?.username),
        const HoroscopeSection(),
        SliverToBoxAdapter(
          child: Transform.translate(
            offset: const Offset(0, -155.0),
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 30, bottom: 12),
                    child: Center(
                      child: Text(
                        'Favorable Day for New Beginnings',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: secondaryTextColor,
                        ),
                      ),
                    ),
                  ),
                  _buildSectionHeaderWidget(
                    'Special for you',
                    onArrowPressed: () {},
                    topPadding: 12,
                  ),
                  const BannerSlider(
                    imagePaths: ['assets/special4.png', 'assets/special3.png'],
                  ),
                  _buildSectionHeaderWidget(
                      'Fnysta – India’s 1st Multi-Platform'),
                  _buildMultiPlatformSectionWidget(),
                  _buildSectionHeaderWidget(
                      'One App - Many Game. Infinite Fun'),
                  const BannerSlider(
                    imagePaths: [
                      'assets/oneapp1.png',
                      'assets/sale2.png',
                      'assets/astro2.png',
                    ],
                    margin: EdgeInsets.fromLTRB(1, 10, 0, 1),
                  ),
                  _buildSectionHeaderWidget('Fnysta Game Zone', topPadding: 25),
                  _buildGameZoneWidget(offset: const Offset(0, -35.0)),
                  _buildBannerWidget(
                    'assets/sale2.png',
                    margin: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 16.0),
                    aspectRatio: 16 / 7,
                  ),
                  _buildSectionHeaderWidget('Quick Trending Highlights'),
                  _buildHorizontalCardListWidget(
                    context: context,
                    imagePaths: const [
                      'assets/trending4.png',
                      'assets/trending5.png',
                      'assets/trending6.png'
                    ],
                    aspectRatio: 9 / 17,
                    itemsOnScreen: 3,
                    showPlayIcon: true,
                  ),
                  const SizedBox(height: 24),
                  const BannerSlider(
                    imagePaths: [
                      'assets/bullbanner2.png',
                      'assets/bullbanner2.png',
                      'assets/bullbanner2.png',
                    ],
                  ),
                  _buildSectionHeaderWidget('WAY TO SUCCESS'),
                  Column(
                    children: [
                      SizedBox(
                        height: 220,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _successImages.length,
                          onPageChanged: (int page) {
                            setState(() {
                              _currentPage = page;
                            });
                          },
                          itemBuilder: (context, index) {
                            return AnimatedBuilder(
                              animation: _pageController,
                              builder: (context, child) {
                                double scale = 1.0;
                                if (_pageController.position.haveDimensions) {
                                  scale = max(
                                      0.85,
                                      1 -
                                          (_pageController.page! - index)
                                                  .abs() *
                                              0.5);
                                }
                                return Transform.scale(
                                  scale: scale,
                                  child: child,
                                );
                              },
                              child: _buildStaticSuccessCard(
                                  imagePath: _successImages[index]),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_successImages.length,
                            (index) => _buildDotIndicator(index: index)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildSectionHeaderWidget('Astro. Game. Market'),
                  _buildBannerWidget(
                    'assets/astro2.png',
                    aspectRatio: 16 / 7,
                  ),
                  const BottomGridSectionWidget(),
                  const SizedBox(height: 0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDotIndicator({required int index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: _currentPage == index ? 24.0 : 8.0,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.blueAccent : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildStaticSuccessCard({required String imagePath}) {
    return Align(
      alignment: Alignment.center,
      child: AspectRatio(
        aspectRatio: 2 / 3,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeaderWidget(
    String title, {
    bool showInfoIcon = false,
    VoidCallback? onArrowPressed,
    double topPadding = 24.0,
    double bottomPadding = 8.0,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    final primaryTextColor = isDarkMode ? Colors.white : Colors.black;
    final iconColor = isDarkMode ? Colors.white70 : Colors.black54;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, topPadding, 16, bottomPadding),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryTextColor),
          ),
          const Spacer(),
          if (showInfoIcon) const Icon(Icons.info_outline, color: Colors.grey),
          if (onArrowPressed != null) ...[
            const SizedBox(width: 8),
            InkWell(
              onTap: onArrowPressed,
              customBorder: const CircleBorder(),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  shape: BoxShape.circle,
                ),
                child:
                    Icon(Icons.arrow_forward_ios, size: 12, color: iconColor),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildHorizontalCardListWidget({
    required BuildContext context,
    required List<String> imagePaths,
    required double aspectRatio,
    double itemsOnScreen = 2.2,
    bool showPlayIcon = false,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double horizontalPadding = 16.0;
    const double itemSpacing = 15.0;
    final cardWidth = (screenWidth -
            (horizontalPadding * 2) -
            (itemSpacing * (itemsOnScreen - 1))) /
        itemsOnScreen;
    final cardHeight = cardWidth / aspectRatio;

    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final cardColor =
        themeProvider.isDarkMode ? Colors.grey[850] : Colors.white;

    return SizedBox(
      height: cardHeight,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
        scrollDirection: Axis.horizontal,
        itemCount: imagePaths.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: itemSpacing),
        itemBuilder: (context, index) {
          return SizedBox(
            width: cardWidth,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    border: Border.all(
                      color: Colors.grey.shade200,
                      width: 1.0,
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
                    child: Image.asset(
                      imagePaths[index],
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                if (showPlayIcon)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBannerWidget(
    String imagePath, {
    EdgeInsetsGeometry margin =
        const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
    Offset offset = const Offset(0, 0),
    double? aspectRatio,
  }) {
    return Transform.translate(
      offset: offset,
      child: Container(
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: aspectRatio != null
              ? AspectRatio(
                  aspectRatio: aspectRatio,
                  child: Image.asset(imagePath, fit: BoxFit.cover),
                )
              : Image.asset(imagePath, fit: BoxFit.fill),
        ),
      ),
    );
  }

  Widget _buildPlatformCard(String label, String imagePath,
      {required double borderRadius}) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final primaryTextColor =
        themeProvider.isDarkMode ? Colors.white : Colors.black;

    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: primaryTextColor),
        ),
      ],
    );
  }

  Widget _buildMultiPlatformSectionWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
      child: SizedBox(
        height: 245,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              flex: 5,
              child: _buildPlatformCard('Community', 'assets/community.png',
                  borderRadius: 5.0),
            ),
            const SizedBox(width: 20),
            Flexible(
              flex: 4,
              child: Column(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                const CalculatorListScreen()));
                      },
                      child: _buildPlatformCard(
                          '  SIP Calculator', 'assets/calculator.png',
                          borderRadius: 5.0),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: _buildPlatformCard(
                        'Stock Market', 'assets/stockmarket.png',
                        borderRadius: 5.0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameZoneWidget({
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 16.0),
    Offset offset = const Offset(0, 0),
  }) {
    final gameCards = [
      'assets/gamezone.png',
      'assets/gamezone4.png',
    ];
    final gameIcons = [
      {'icon': 'assets/flash2.png', 'label': 'Flash'},
      {'icon': 'assets/highlight2.png', 'label': 'Highlight'},
      {'icon': 'assets/rashi2.png', 'label': 'Rashi'},
      {'icon': 'assets/marketx2.png', 'label': 'MarketX'},
    ];
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final primaryTextColor =
        themeProvider.isDarkMode ? Colors.white : Colors.black;

    return Transform.translate(
      offset: offset,
      child: Padding(
        padding: padding,
        child: Column(
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 2,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
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
                    child: Image.asset(
                      gameCards[index],
                      fit: BoxFit.fill,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 35),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: gameIcons.map((item) {
                return Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Image.asset(
                        item['icon']!,
                        width: 67,
                        height: 80,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['label']!,
                      style: TextStyle(
                          fontWeight: FontWeight.w500, color: primaryTextColor),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomGridSectionWidget extends StatelessWidget {
  const BottomGridSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomCards = [
      {'label': 'News', 'path': 'assets/news2.png'},
      {'label': 'Astrology', 'path': 'assets/astrology2.png'},
    ];
    final themeProvider = Provider.of<ThemeProvider>(context);
    final primaryTextColor =
        themeProvider.isDarkMode ? Colors.white : Colors.black;
    final cardColor =
        themeProvider.isDarkMode ? Colors.grey[850] : Colors.white;

    return Transform.translate(
      offset: const Offset(0, -15.0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: bottomCards.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            childAspectRatio: 0.75,
          ),
          itemBuilder: (context, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      border: Border.all(
                        color: const Color.fromARGB(255, 192, 191, 191),
                        width: 1.0,
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
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: primaryTextColor),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
