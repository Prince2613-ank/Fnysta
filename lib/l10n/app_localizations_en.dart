// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get searchServices => 'Search services';

  @override
  String hello(String userName) {
    return 'Hello, $userName!';
  }

  @override
  String get myProfile => 'My Profile';

  @override
  String get notifications => 'Notification';

  @override
  String get skip => 'Skip';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get english => 'English';

  @override
  String get hindi => 'Hindi';
}
