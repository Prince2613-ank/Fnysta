// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get searchServices => 'सेवाएं खोजें';

  @override
  String hello(String userName) {
    return 'नमस्ते, $userName!';
  }

  @override
  String get myProfile => 'मेरी प्रोफ़ाइल';

  @override
  String get notifications => 'सूचना';

  @override
  String get skip => 'छोड़ें';

  @override
  String get selectLanguage => 'भाषा चुने';

  @override
  String get english => 'अंग्रेज़ी';

  @override
  String get hindi => 'हिन्दी';
}
