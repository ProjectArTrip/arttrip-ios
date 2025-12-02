// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get navHome => '홈';

  @override
  String get navMap => '지도';

  @override
  String get navMy => 'My';

  @override
  String get navStamp => '스탬프';

  @override
  String get navStorage => '보관함';

  @override
  String get splashSlogan => '세상의 전시, 내 손 안에.';

  @override
  String get loginKakao => '카카오로 로그인';

  @override
  String get loginGoogle => 'Google로 로그인';

  @override
  String get loginApple => 'Apple로 로그인';
}
