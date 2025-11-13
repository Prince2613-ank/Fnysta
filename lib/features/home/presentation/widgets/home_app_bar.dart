// lib/features/home/presentation/widgets/home_app_bar.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ⭐ FIX: Corrected the import path for the generated localization file
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../theme/locale_provider.dart';
import '../../../../theme/theme_provider.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final provider = Provider.of<LocaleProvider>(context, listen: false);
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.selectLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(AppLocalizations.of(context)!.english),
                onTap: () {
                  provider.setLocale(const Locale('en'));
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text(AppLocalizations.of(context)!.hindi),
                onTap: () {
                  provider.setLocale(const Locale('hi'));
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    final appBarColor = isDarkMode ? Colors.grey[850] : Colors.white;
    final iconColor = isDarkMode ? Colors.white70 : Colors.grey[800];
    final textColor = isDarkMode ? Colors.white54 : Colors.grey;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: appBarColor,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.menu, color: iconColor),
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
            Expanded(
              // ⭐ Use the localized string
              child: Text(AppLocalizations.of(context)!.searchServices,
                  style: TextStyle(color: textColor, fontSize: 16)),
            ),
            IconButton(
              icon: Icon(Icons.translate, color: iconColor),
              // ⭐ Call the dialog function
              onPressed: () => _showLanguageDialog(context),
            ),
            IconButton(
              icon: Icon(
                isDarkMode
                    ? Icons.wb_sunny_outlined
                    : Icons.nights_stay_outlined,
                color: iconColor,
              ),
              onPressed: () {
                themeProvider.toggleTheme();
              },
            ),
            IconButton(
              icon: Icon(Icons.notifications_none, color: iconColor),
              onPressed: () {
                Navigator.pushNamed(context, '/notifications');
              },
            ),
          ],
        ),
      ),
    );
  }
}
