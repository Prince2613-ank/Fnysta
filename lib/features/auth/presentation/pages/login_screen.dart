import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../theme/dnd_toggle.dart';
import '../../../../theme/theme_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: const [
          DndToggle(),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'assets/logoo.png',
                  height: 90,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Hi Welcome!',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Submit your Mobile number',
                style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                    fontSize: 16),
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: Divider(
                        color: themeProvider.isDarkMode
                            ? Colors.grey.shade800
                            : const Color.fromARGB(255, 147, 144, 144),
                        thickness: 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Log in or Sign up',
                      style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.9),
                          fontSize: 14),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                        color: themeProvider.isDarkMode
                            ? const Color.fromARGB(255, 147, 144, 144)
                            : const Color.fromARGB(255, 147, 144, 144),
                        thickness: 1),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                    color: themeProvider.isDarkMode
                        ? Colors.grey.shade800
                        : const Color.fromARGB(255, 128, 125, 125),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.transparent)),
                child: Row(
                  children: [
                    const Text('+91',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Icon(Icons.arrow_drop_down, color: Colors.grey.shade700),
                    Container(
                      height: 24,
                      width: 1,
                      color: Colors.grey.shade400,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter Mobile number',
                          hintStyle: TextStyle(
                              color: const Color.fromARGB(255, 25, 25, 25)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/otp');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC107),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('SEND OTP',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                        fontSize: 12,
                        height: 1.5),
                    children: [
                      const TextSpan(text: 'By signing up, you agree to our '),
                      TextSpan(
                        text: 'Terms of Use',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
