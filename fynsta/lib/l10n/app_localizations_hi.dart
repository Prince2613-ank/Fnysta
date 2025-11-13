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

  @override
  String get favorableDay => 'नई शुरुआत के लिए शुभ दिन';

  @override
  String get specialForYou => 'आपके लिए विशेष';

  @override
  String get multiPlatform => 'Fnysta – भारत का पहला मल्टी-प्लेटफ़ॉर्म';

  @override
  String get navHome => 'होम';

  @override
  String get navAstrology => 'ज्योतिष';

  @override
  String get navCommunity => 'समुदाय';

  @override
  String get navNews => 'समाचार';

  @override
  String get navMore => 'अधिक';
}
