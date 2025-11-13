import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fynsta/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'theme/locale_provider.dart';
import 'theme/theme_provider.dart';

import 'features/onboarding/presentation/pages/onboarding_screen.dart';
import 'features/auth/presentation/pages/login_screen.dart';
import 'features/auth/presentation/pages/otp_screen.dart';
import 'features/home/presentation/pages/home_screen.dart';
import 'features/game/pages/knife_hit_screen.dart';
import 'features/game/pages/slot_machine_screen.dart';
import 'features/game/pages/color_switch_screen.dart'; // Import the new game
import 'features/splash/presentation/pages/splash_screen.dart';
import 'features/notifications/presentation/pages/notification_screen.dart';
import 'features/profile/presentation/pages/profile_screen.dart';
import 'features/profile/presentation/pages/edit_profile_screen.dart';
import 'features/astrology/presentation/pages/astrology_screen.dart';
import 'features/kundli/presentation/pages/kundli_form_screen.dart';
import 'features/calculator/presentation/pages/sip_calculator_screen.dart';
import 'features/calculator/presentation/pages/emi_calculator_screen.dart';
import 'features/calculator/presentation/pages/inflation_calculator_screen.dart';
import 'features/calculator/presentation/pages/mutual_fund_calculator_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ErrorWidget.builder = (FlutterErrorDetails details) {
    debugPrint(details.exception.toString());
    return const SplashScreen(
      message: 'Something went wrong. Please restart the app.',
    );
  };

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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return GestureDetector(
      onTap: () {
        SystemSound.play(SystemSoundType.click);
        HapticFeedback.lightImpact();
      },
      child: MaterialApp(
        title: 'Fnyasta App',
        themeMode: themeProvider.themeMode,
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
          // ⭐ FIX: Removed the old '/otp' route that was causing the error.
          // Navigation is now handled by the LoginScreen's BlocListener.
          '/home': (context) => const HomeScreen(),
          '/game': (context) => const KnifeHitGame(),
          '/slot_machine': (context) => const SlotMachineScreen(),
          '/color_switch': (context) => const ColorSwitchScreen(),
          '/notifications': (context) => const NotificationScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/edit_profile': (context) => const EditProfileScreen(),
          '/astrology': (context) => const AstrologyScreen(),
          '/kundli': (context) => const KundliFormScreen(),
          '/sip_calculator': (context) => const SipCalculatorScreen(),
          '/emi_calculator': (context) => const EmiCalculatorScreen(),
          '/inflation_calculator': (context) =>
              const InflationCalculatorScreen(),
          '/mutual_fund_calculator': (context) =>
              const MutualFundCalculatorScreen(),
        },
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const SplashScreen(
              message: 'Oops! Page not found.',
            ),
          );
        },
      ),
    );
  }
}
