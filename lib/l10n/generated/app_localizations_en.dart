// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navHome => 'Home';

  @override
  String get navMap => 'Map';

  @override
  String get navMy => 'My';

  @override
  String get navStamp => 'Stamp';

  @override
  String get navStorage => 'Storage';

  @override
  String get splashSlogan => 'The world\'s exhibitions, in your hands.';

  @override
  String get loginKakao => 'Login with Kakao';

  @override
  String get loginGoogle => 'Login with Google';

  @override
  String get loginApple => 'Login with Apple';
}
