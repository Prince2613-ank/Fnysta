import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../theme/theme_provider.dart';
import '../../../kundli/presentation/pages/kundli_form_screen.dart';

class AstrologyScreen extends StatefulWidget {
  const AstrologyScreen({super.key});

  @override
  State<AstrologyScreen> createState() => _AstrologyScreenState();
}

class _AstrologyScreenState extends State<AstrologyScreen> {
  final GlobalKey _horoscopeSectionKey = GlobalKey();

  int _selectedZodiacIndex = 0;
  final List<String> _zodiacSigns = [
    'Aries',
    'Taurus',
    'Gemini',
    'Cancer',
    'Leo',
    'Virgo',
    'Libra',
    'Scorpio',
    'Sagittarius',
    'Capricorn',
    'Aquarius',
    'Pisces'
  ];

  final List<String> _zodiacSymbols = [
    '♈',
    '♉',
    '♊',
    '♋',
    '♌',
    '♍',
    '♎',
    '♏',
    '♐',
    '♑',
    '♒',
    '♓'
  ];

  final List<String> _zodiacIcons = [
    'assets/ariesi.png',
    'assets/taurusi.png',
    'assets/geminii.png',
    'assets/canceri.png',
    'assets/leoi.png',
    'assets/virgoi.png',
    'assets/librai.png',
    'assets/scorpioi.png',
    'assets/sagittariusi.png',
    'assets/capricorni.png',
    'assets/aquariusi.png',
    'assets/piscesi.png',
  ];

  void _scrollToHoroscope() {
    final context = _horoscopeSectionKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _navigateToKundli() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const KundliFormScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    final scaffoldColor = isDarkMode ? Colors.grey[900] : Colors.white;
    final appBarColor = isDarkMode ? Colors.grey[900] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final iconColor = isDarkMode ? Colors.white : Colors.black;
    final tabBackgroundColor =
        isDarkMode ? Colors.black : const Color(0xFFF8F8F8);
    final selectedZodiacColor = isDarkMode ? Colors.amber : Colors.purple;
    final unselectedZodiacColor = textColor;
    final tabIndicatorColor = isDarkMode ? Colors.amber : Colors.purple;

    // ⭐ FIX: Used .shade300 and .shade600 to ensure the color is not nullable
    final buttonTextColor =
        isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
        title: Text('Astrology', style: TextStyle(color: textColor)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: iconColor),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 129,
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                gradient: const LinearGradient(
                  colors: [Color(0xFF101461), Color(0xFF3F0545)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Text('Banner',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  _buildGradientButton('Horoscope',
                      onPressed: _scrollToHoroscope),
                  const SizedBox(width: 16),
                  _buildGradientButton('Kundli', onPressed: _navigateToKundli),
                ],
              ),
            ),
            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _zodiacSigns.length,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                itemBuilder: (context, index) {
                  bool isSelected = _selectedZodiacIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedZodiacIndex = index),
                    child: SizedBox(
                      width: 94,
                      height: 153,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(_zodiacIcons[index], height: 120),
                          const SizedBox(height: 8),
                          Text(
                            _zodiacSigns[index],
                            style: TextStyle(
                              color: isSelected
                                  ? selectedZodiacColor
                                  : unselectedZodiacColor,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 54,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xFF101461), Color(0xFF3F0545)]),
              ),
              child: Center(
                child: Text(
                  '${_zodiacSymbols[_selectedZodiacIndex]} ${_zodiacSigns[_selectedZodiacIndex]} ${_zodiacSymbols[_selectedZodiacIndex]}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Container(
              key: _horoscopeSectionKey,
              color: tabBackgroundColor,
              child: DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    TabBar(
                      indicatorColor: tabIndicatorColor,
                      labelColor: textColor,
                      unselectedLabelColor: Colors.grey,
                      tabs: const [
                        _Tab('Weekly', '9th-15th'),
                        _Tab('Daily', '15-09-2025'),
                        _Tab('Monthly', 'September'),
                      ],
                    ),
                    _buildHoroscopeDetails(
                        textColor, buttonTextColor, selectedZodiacColor),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientButton(String text, {required VoidCallback onPressed}) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF101461), Color(0xFF3F0545)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              alignment: Alignment.center,
              child: Text(text,
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHoroscopeDetails(
      Color textColor, Color buttonTextColor, Color primaryActionColor) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              gradient: const LinearGradient(
                colors: [Color(0xFF101461), Color(0xFF3F0545)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Daily Horoscope",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                Text("Today's horoscope",
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.8), fontSize: 14)),
                const Divider(color: Colors.white30, height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Lucky Colour',
                            style: TextStyle(color: Colors.white70)),
                        Text('Purple',
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                        SizedBox(height: 10),
                        Text('Favourable Aspects',
                            style: TextStyle(color: Colors.white70)),
                        Text('Finance, Family',
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('Lucky Number',
                            style: TextStyle(color: Colors.white70)),
                        const Text('6',
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                        const SizedBox(height: 20),
                        Image.asset(_zodiacIcons[_selectedZodiacIndex],
                            height: 50),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Know More About Your Day....',
            style: TextStyle(
                color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: primaryActionColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Career'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryActionColor,
                    side: BorderSide(color: primaryActionColor),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Love'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryActionColor,
                    side: BorderSide(color: primaryActionColor),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Business'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
            style: TextStyle(color: buttonTextColor),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String title;
  final String subtitle;

  const _Tab(this.title, this.subtitle);

  @override
  Widget build(BuildContext context) {
    return Tab(
      height: 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title),
          const SizedBox(height: 2),
          Text(subtitle,
              style: const TextStyle(
                  fontSize: 15, color: Color.fromARGB(255, 49, 48, 48))),
        ],
      ),
    );
  }
}
