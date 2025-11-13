import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../theme/theme_provider.dart';
import '../../../kundli/presentation/pages/kundli_form_screen.dart';
import '../../data/datasources/horoscope_remote_data_source.dart';
import '../../data/repositories/horoscope_repository_impl.dart';
import '../../domain/entities/horoscope.dart';
import '../../domain/usecases/get_horoscope.dart';
import '../bloc/horoscope_bloc.dart';
import '../bloc/horoscope_event.dart';
import '../bloc/horoscope_state.dart';

class AstrologyScreen extends StatelessWidget {
  const AstrologyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HoroscopeBloc(
        getHoroscope: GetHoroscope(
          HoroscopeRepositoryImpl(
            remoteDataSource: HoroscopeRemoteDataSourceImpl(
              client: http.Client(),
            ),
          ),
        ),
      ),
      child: const _AstrologyScreenView(),
    );
  }
}

enum PredictionCategory { career, love, business, student }

class _AstrologyScreenView extends StatefulWidget {
  const _AstrologyScreenView();

  @override
  State<_AstrologyScreenView> createState() => _AstrologyScreenViewState();
}

class _AstrologyScreenViewState extends State<_AstrologyScreenView>
    with TickerProviderStateMixin {
  final GlobalKey _horoscopeSectionKey = GlobalKey();

  int _selectedZodiacIndex = 0;
  late TabController _tabController;

  late String dailyDate;
  late String weeklyDateRange;
  late String monthlyDate;
  late String yearlyDate;

  PredictionCategory _selectedCategory = PredictionCategory.career;
  String _displayedPrediction = '';

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

  @override
  void initState() {
    super.initState();
    _updateDates();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 1);
    _tabController.addListener(_onTabChanged);
    _fetchHoroscopeData();
  }

  void _updateDates() {
    final now = DateTime.now();
    dailyDate = DateFormat('MMM d, yyyy').format(now);
    monthlyDate = DateFormat('MMMM').format(now);
    yearlyDate = DateFormat('yyyy').format(now);

    final startOfWeek =
        now.subtract(Duration(days: now.weekday - DateTime.monday));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    weeklyDateRange =
        '${DateFormat('d MMM').format(startOfWeek)} - ${DateFormat('d MMM').format(endOfWeek)}';
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) return;
    _fetchHoroscopeData();
  }

  void _onZodiacChanged(int index) {
    setState(() {
      _selectedZodiacIndex = index;
    });
    _fetchHoroscopeData();
  }

  void _fetchHoroscopeData() {
    setState(() {
      _selectedCategory = PredictionCategory.career;
    });
    final selectedSign = _zodiacSigns[_selectedZodiacIndex];
    final horoscopeType = _getHoroscopeTypeForIndex(_tabController.index);
    context
        .read<HoroscopeBloc>()
        .add(FetchHoroscope(zodiacSign: selectedSign, type: horoscopeType));
  }

  HoroscopeType _getHoroscopeTypeForIndex(int index) {
    switch (index) {
      case 0:
        return HoroscopeType.weekly;
      case 1:
        return HoroscopeType.daily;
      case 2:
        return HoroscopeType.monthly;
      case 3:
        return HoroscopeType.yearly;
      default:
        return HoroscopeType.daily;
    }
  }

  String _getHoroscopeTitleForIndex(int index) {
    switch (index) {
      case 0:
        return 'Weekly';
      case 1:
        return 'Daily';
      case 2:
        return 'Monthly';
      case 3:
        return 'Yearly';
      default:
        return 'Daily';
    }
  }

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

  void _updateDisplayedPrediction(
      Horoscope horoscope, PredictionCategory category) {
    setState(() {
      _selectedCategory = category;
      switch (category) {
        case PredictionCategory.love:
          _displayedPrediction = horoscope.lovePrediction;
          break;
        case PredictionCategory.business:
        case PredictionCategory.career:
          _displayedPrediction = horoscope.careerPrediction;
          break;
        case PredictionCategory.student:
          _displayedPrediction = horoscope.studentPrediction;
          break;
      }
    });
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
                    onTap: () => _onZodiacChanged(index),
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
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    indicatorColor: tabIndicatorColor,
                    labelColor: textColor,
                    unselectedLabelColor: Colors.grey.shade600,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                    tabs: [
                      _Tab('Weekly', weeklyDateRange),
                      _Tab('Daily', dailyDate),
                      _Tab('Monthly', monthlyDate),
                      _Tab('Yearly', yearlyDate),
                    ],
                  ),
                  _buildHoroscopeDetails(
                      textColor, buttonTextColor, selectedZodiacColor),
                ],
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
    return BlocListener<HoroscopeBloc, HoroscopeState>(
      listener: (context, state) {
        if (state is HoroscopeLoaded) {
          setState(() {
            _displayedPrediction = state.horoscope.generalPrediction;
            _selectedCategory = PredictionCategory.career;
          });
        }
      },
      child: BlocBuilder<HoroscopeBloc, HoroscopeState>(
        builder: (context, state) {
          Widget content;
          final String horoscopeTitle =
              _getHoroscopeTitleForIndex(_tabController.index);

          if (state is HoroscopeLoading) {
            content = const Center(child: CircularProgressIndicator());
          } else if (state is HoroscopeLoaded) {
            content = Column(
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
                      Text("$horoscopeTitle Horoscope",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      Text("Today's horoscope",
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14)),
                      const Divider(color: Colors.white30, height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Lucky Colour',
                                  style: TextStyle(color: Colors.white70)),
                              Text(state.horoscope.luckyColour,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 16)),
                              const SizedBox(height: 10),
                              const Text('Favourable Aspects',
                                  style: TextStyle(color: Colors.white70)),
                              Text(state.horoscope.favourableAspects,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 16)),
                            ],
                          ),
                          Column(
                            children: [
                              const Text('Lucky Number',
                                  style: TextStyle(color: Colors.white70)),
                              Text(state.horoscope.luckyNumber,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 16)),
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
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryButton(state.horoscope, 'Career',
                          PredictionCategory.career, primaryActionColor),
                      const SizedBox(width: 10),
                      _buildCategoryButton(state.horoscope, 'Love',
                          PredictionCategory.love, primaryActionColor),
                      const SizedBox(width: 10),
                      _buildCategoryButton(state.horoscope, 'Business',
                          PredictionCategory.business, primaryActionColor),
                      const SizedBox(width: 10),
                      _buildCategoryButton(state.horoscope, 'Student',
                          PredictionCategory.student, primaryActionColor),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _displayedPrediction,
                  style: TextStyle(color: buttonTextColor, height: 1.5),
                ),
                const SizedBox(height: 24),
                _buildAdditionalInfoSection(
                    'What to Do',
                    state.horoscope.whatToDo,
                    Icons.check_circle_outline,
                    Colors.green,
                    textColor,
                    primaryActionColor),
                _buildAdditionalInfoSection(
                    'What Not to Do',
                    state.horoscope.whatNotToDo,
                    Icons.highlight_off,
                    Colors.red,
                    textColor,
                    primaryActionColor),
                _buildAdditionalInfoSection('Remedy', state.horoscope.remedy,
                    Icons.healing, Colors.blue, textColor, primaryActionColor),
              ],
            );
          } else if (state is HoroscopeError) {
            content = Center(
                child: Text(state.message,
                    style: const TextStyle(color: Colors.red)));
          } else {
            content = const SizedBox.shrink();
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: content,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryButton(Horoscope horoscope, String title,
      PredictionCategory category, Color activeColor) {
    bool isSelected = _selectedCategory == category;
    return ElevatedButton(
      onPressed: () => _updateDisplayedPrediction(horoscope, category),
      style: ElevatedButton.styleFrom(
        foregroundColor: isSelected ? Colors.white : activeColor,
        backgroundColor: isSelected ? activeColor : Colors.transparent,
        side: isSelected ? null : BorderSide(color: activeColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: Text(title),
    );
  }

  Widget _buildAdditionalInfoSection(String title, String content,
      IconData icon, Color iconColor, Color textColor, Color activeColor) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    final tileBackgroundColor = isDarkMode
        ? Colors.grey.shade800.withOpacity(0.3)
        : const Color(0xFFF8F1FF);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
              color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200)),
      color: tileBackgroundColor,
      child: ExpansionTile(
        tilePadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        title: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
            child: Text(
              content,
              style: TextStyle(
                color: textColor.withOpacity(0.8),
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
        ],
        iconColor: activeColor,
        collapsedIconColor: iconColor,
      ),
    );
  }
}

// ⭐ FIX: Increased font sizes for better visibility.
class _Tab extends StatelessWidget {
  final String title;
  final String subtitle;

  const _Tab(this.title, this.subtitle);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 75,
      child: Tab(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
