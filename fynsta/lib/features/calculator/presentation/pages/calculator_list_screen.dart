// lib/features/calculator/presentation/pages/calculator_list_screen.dart
import 'package:flutter/material.dart';
import 'package:fynsta/features/calculator/widgets/calculator_background.dart';
import 'package:provider/provider.dart';
import '../../../../theme/theme_provider.dart';

class CalculatorListScreen extends StatelessWidget {
  const CalculatorListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    final List<List<Color>> lightModeGradients = [
      [const Color(0xFF8EC5FC), const Color(0xFFE0C3FC)], // Blue to Purple SIP
      [
        const Color(0xFFC79AFA),
        const Color(0xFFFC8AEB)
      ], // Purple to Pink Mutual Fund
      [const Color(0xFFFDD87D), const Color(0xFFFC8AEB)], // Yellow to Pink EMI
      [
        const Color(0xFF84FAB0),
        const Color(0xFF8FD3F4)
      ], // Green to Light Blue Inflation
    ];

    final List<List<Color>> darkModeGradients = [
      [const Color(0xFF6A1B9A), const Color(0xFF4527A0)], // Dark Purple SIP
      [
        const Color(0xFF4A148C),
        const Color(0xFF1A237E)
      ], // Deep Purple to Indigo Mutual Fund
      [const Color(0xFF2E7D32), const Color(0xFF1B5E20)], // Dark Green EMI
      [
        const Color(0xFFBF360C),
        const Color(0xFF880E4F)
      ], // Deep Orange to Dark Pink Inflation
    ];

    final cardGradients = isDarkMode ? darkModeGradients : lightModeGradients;

    return CalculatorBackground(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Text(
              'Calculators',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 34,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Text(
                'Explore our financial tools to help you plan better.',
                style: TextStyle(
                  color: textColor.withOpacity(0.8),
                  fontSize: 16,
                ),
              ),
            ),
            _buildCalculatorCard(
              context: context,
              title: 'SIP Calculator',
              subtitle: 'Calculate your investment returns',
              icon: Icons.auto_graph,
              onTap: () => Navigator.pushNamed(context, '/sip_calculator'),
              gradientColors: cardGradients[0],
              textColor: textColor,
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 12),
            _buildCalculatorCard(
              context: context,
              title: 'Mutual Fund Calculator',
              subtitle: 'Estimate your mutual fund returns',
              icon: Icons.analytics_outlined,
              onTap: () =>
                  Navigator.pushNamed(context, '/mutual_fund_calculator'),
              gradientColors: cardGradients[1],
              textColor: textColor,
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 12),
            _buildCalculatorCard(
              context: context,
              title: 'EMI Calculator',
              subtitle: 'Know your Equated Monthly Installments',
              icon: Icons.account_balance_wallet_outlined,
              onTap: () => Navigator.pushNamed(context, '/emi_calculator'),
              gradientColors: cardGradients[2],
              textColor: textColor,
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 12),
            _buildCalculatorCard(
              context: context,
              title: 'Inflation Calculator',
              subtitle: 'Understand the impact of inflation',
              icon: Icons.trending_up,
              onTap: () =>
                  Navigator.pushNamed(context, '/inflation_calculator'),
              gradientColors: cardGradients[3],
              textColor: textColor,
              isDarkMode: isDarkMode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculatorCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required List<Color> gradientColors,
    required Color textColor,
    required bool isDarkMode,
  }) {
    final Color iconColor = isDarkMode ? Colors.white : Colors.black;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0),
            child: Row(
              children: [
                Icon(icon, size: 38, color: iconColor),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: iconColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: iconColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    size: 18, color: iconColor.withOpacity(0.6)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
