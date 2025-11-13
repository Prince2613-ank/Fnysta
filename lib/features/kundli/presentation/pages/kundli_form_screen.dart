// lib/features/kundli/presentation/pages/kundli_form_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// ⭐ 1. Import ThemeProvider and the report screen
import '../../../../theme/theme_provider.dart';
import 'kundli_report_screen.dart';

class KundliFormScreen extends StatefulWidget {
  const KundliFormScreen({super.key});

  @override
  State<KundliFormScreen> createState() => _KundliFormScreenState();
}

class _KundliFormScreenState extends State<KundliFormScreen> {
  bool _agreedToTerms = false;
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _tobController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _tobController.text = picked.format(context);
      });
    }
  }

  @override
  void dispose() {
    _dobController.dispose();
    _tobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ⭐ 2. Get theme provider and define theme-aware colors
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    final scaffoldColor =
        isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey.shade100;
    final cardColor = isDarkMode ? const Color(0xFF2C2C2E) : Colors.white;
    final primaryTextColor = isDarkMode ? Colors.white : Colors.black;
    final secondaryTextColor =
        isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
    final textFieldFillColor =
        isDarkMode ? const Color(0xFF3A3A3C) : Colors.grey.shade100;
    final appBarIconColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        title:
            Text('Kundli Onboarding', style: TextStyle(color: appBarIconColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: appBarIconColor),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Tell us More About You',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor),
                ),
                const SizedBox(height: 8),
                Text(
                  'This information would help us generate accurate details',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: secondaryTextColor, fontSize: 14),
                ),
                const SizedBox(height: 32),
                // ⭐ 3. Pass theme colors down to the text field widgets
                _buildTextField('Name', 'Enter Your Name',
                    labelColor: secondaryTextColor,
                    fillColor: textFieldFillColor,
                    inputTextColor: primaryTextColor),
                const SizedBox(height: 16),
                _buildTextField('DOB', 'Select Your DOB',
                    isDatePicker: true,
                    controller: _dobController,
                    labelColor: secondaryTextColor,
                    fillColor: textFieldFillColor,
                    inputTextColor: primaryTextColor),
                const SizedBox(height: 16),
                _buildTextField('Place of Birth', 'Enter Place of Birth',
                    labelColor: secondaryTextColor,
                    fillColor: textFieldFillColor,
                    inputTextColor: primaryTextColor),
                const SizedBox(height: 16),
                _buildTextField('Time of Birth', 'Select Time',
                    isTimePicker: true,
                    controller: _tobController,
                    labelColor: secondaryTextColor,
                    fillColor: textFieldFillColor,
                    inputTextColor: primaryTextColor),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: Text(
                    'I agree to let Fynsta use this information to get Kundli details',
                    style: TextStyle(fontSize: 12, color: secondaryTextColor),
                  ),
                  value: _agreedToTerms,
                  onChanged: (bool? value) =>
                      setState(() => _agreedToTerms = value ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  activeColor: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 24),
                _buildGradientButton(),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'Terms & Conditions',
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: secondaryTextColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ⭐ 4. Update the _buildTextField helper to accept and use theme colors
  Widget _buildTextField(
    String label,
    String hint, {
    bool isDatePicker = false,
    bool isTimePicker = false,
    TextEditingController? controller,
    required Color labelColor,
    required Color fillColor,
    required Color inputTextColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontWeight: FontWeight.w500, color: labelColor)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          readOnly: isDatePicker || isTimePicker,
          style: TextStyle(color: inputTextColor), // Set input text color
          onTap: () {
            if (isDatePicker) _selectDate(context);
            if (isTimePicker) _selectTime(context);
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: labelColor),
            filled: true,
            fillColor: fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none, // Removed border for a cleaner look
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGradientButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          colors: [Color(0xFF101461), Color(0xFF3F0545)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const KundliReportScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text('Generate Kundli',
            style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
    );
  }
}
