// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ⭐ 1. Import generated localizations and providers
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'theme/locale_provider.dart';
import 'theme/theme_provider.dart';

// Your other page imports
import 'features/onboarding/presentation/pages/onboarding_screen.dart';
import 'features/auth/presentation/pages/login_screen.dart';
import 'features/auth/presentation/pages/otp_screen.dart';
import 'features/home/presentation/pages/home_screen.dart';
import 'features/game/pages/knife_hit_screen.dart';
import 'features/splash/presentation/pages/splash_screen.dart';
import 'features/notifications/presentation/pages/notification_screen.dart';
import 'features/profile/presentation/pages/profile_screen.dart';
import 'features/profile/presentation/pages/edit_profile_screen.dart';
import 'features/astrology/presentation/pages/astrology_screen.dart';
import 'features/kundli/presentation/pages/kundli_form_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ErrorWidget.builder = (FlutterErrorDetails details) {
    debugPrint(details.exception.toString());
    return const SplashScreen(
      message: 'Something went wrong. Please restart the app.',
    );
  };

  // ⭐ 2. Use MultiProvider to handle both Theme and Locale
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ⭐ 3. Get both providers from the context
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      title: 'Fnyasta App',
      themeMode: themeProvider.themeMode,

      // ⭐ 4. Add localization settings
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      locale: localeProvider.locale,

      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF004AAD),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF004AAD),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/otp': (context) => const OTPScreen(),
        '/home': (context) => const HomeScreen(),
        '/game': (context) => const KnifeHitGame(),
        '/notifications': (context) => const NotificationScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/edit_profile': (context) => const EditProfileScreen(),
        '/astrology': (context) => const AstrologyScreen(),
        '/kundli': (context) => const KundliFormScreen(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const SplashScreen(
            message: 'Oops! Page not found.',
          ),
        );
      },
    );
  }
}
