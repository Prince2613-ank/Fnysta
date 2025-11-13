// lib/features/kundli/presentation/pages/kundli_report_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../theme/theme_provider.dart';

class KundliReportScreen extends StatelessWidget {
  const KundliReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    // Theme-aware colors to match the Figma design
    final scaffoldColor =
        isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFFFF9F2);
    final primaryTextColor = isDarkMode ? Colors.white : Colors.black87;
    final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.black54;
    final appBarIconColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        title: Text(
          'Your Report',
          style:
              TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: appBarIconColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        // Using a more standard padding for better aesthetics
        padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 1.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                'Your Report is Ready!',
                style: TextStyle(
                    color: primaryTextColor,
                    fontSize: 28,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 0),

            // Zodiac Wheel Image
            Image.asset(
              'assets/kundli_report_wheel.png',
              // Adjusted height for better proportions
              height: 450,
            ),
            // ⭐ FIX: Reduced vertical space here to reduce padding from the wheel
            const SizedBox(height: 1),

            // Section Header call updated to pass two separate lines
            _buildSectionHeader(
              'Here is your',
              'Birth Chart/Kundli',
              primaryTextColor,
            ),
            const SizedBox(height: 10),

            // Ganesha Image
            Image.asset(
              'assets/ganesha_mandala.png',
              // Adjusted height for better proportions
              height: 320,
            ),
            const SizedBox(height: 30),

            // Details Text Section
            _buildFeatureText(
              context,
              title: 'Fnysta Free Kundli – Accurate & Instant!',
              description:
                  '100% Free & Instant – Get your Kundli in seconds, no hidden fees.',
              textColor: secondaryTextColor,
            ),
            _buildFeatureText(
              context,
              title: 'Powered by Vedic Astrology',
              description: 'Authentic planetary calculations & predictions.',
              textColor: secondaryTextColor,
            ),
            _buildFeatureText(
              context,
              title: 'Multilingual',
              description:
                  'Available in English, Hindi, Tamil, Kannada, Marathi & more.',
              textColor: secondaryTextColor,
            ),
            _buildFeatureText(
              context,
              title: 'Mobile & Desktop Friendly',
              description: 'Access anytime, anywhere.',
              textColor: secondaryTextColor,
            ),
            _buildFeatureText(
              context,
              title: 'Detailed Life Insights',
              description: 'Career, finance, health, marriage & future events.',
              textColor: secondaryTextColor,
            ),

            const SizedBox(height: 40),

            // Download Button
            _buildDownloadButton(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Helper updated to separate the two lines of text
  Widget _buildSectionHeader(String line1, String line2, Color textColor) {
    return Column(
      children: [
        Text(
          line1,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontSize: 16, // Slightly smaller font for the top line
            fontWeight: FontWeight.normal,
          ),
        ),
        const SizedBox(height: 8), // Space between the two text lines
        Row(
          children: [
            // ⭐ FIX: Increased thickness of the Divider for bolder lines
            Expanded(
                child:
                    Divider(thickness: 1.5, color: textColor.withOpacity(0.7))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                line2,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w500),
              ),
            ),
            // ⭐ FIX: Increased thickness of the Divider for bolder lines
            Expanded(
                child:
                    Divider(thickness: 1.5, color: textColor.withOpacity(0.7))),
          ],
        ),
      ],
    );
  }

  // Helper for the feature text list
  Widget _buildFeatureText(BuildContext context,
      {required String title,
      required String description,
      required Color textColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13.0),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
            style: TextStyle(color: textColor, fontSize: 15, height: 1.4),
            children: [
              TextSpan(
                  text: '$title – ',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: description),
            ]),
      ),
    );
  }

  // Helper for the gradient download button
  Widget _buildDownloadButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          colors: [Color(0xFF101461), Color(0xFF3F0545)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ElevatedButton.icon(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 19, horizontal: 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        icon: const Icon(Icons.download_sharp, color: Colors.white),
        label: const Text(
          'Download PDF',
          style: TextStyle(
              fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
