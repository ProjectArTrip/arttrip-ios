import 'package:arttrip/core/app_consts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppUtil {
  const AppUtil._();

  static void debugLog(str) {
    if (kDebugMode) print('AppLog : $str');
  }

  /// 이번주의 각 DateTime 리스트
  static List<DateTime> getCurrentWeek(DateTime focusedDay) {
    // 일요일 시작
    var sunday = focusedDay.subtract(Duration(days: focusedDay.weekday % 7));
    return List.generate(7, (index) => sunday.add(Duration(days: index)));
  }

  /// 일자별 요일
  static String weekdayLabel({required DateTime date, required Locale locale}) {
    var isKorean = locale.languageCode == 'ko';
    var labels = isKorean ? AppConsts.weekDaysKo : AppConsts.weekDaysEn;

    // DateTime.weekday: Mon=1 ... Sun=7
    return labels[date.weekday % 7];
  }

  /// 일 ~ 월 요일 리스트
  static List<String> getLocalizedWeekdays(Locale locale) {
    var isKorean = locale.languageCode == 'ko';
    var labels = isKorean ? AppConsts.weekDaysKo : AppConsts.weekDaysEn;
    return labels;
  }

  /// '2025-12-25' 포맷 반환
  static String formatDateYMD(DateTime date) {
    var year = date.year.toString().padLeft(4, '0');
    var month = date.month.toString().padLeft(2, '0');
    var day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  static String getLanguage(BuildContext context) {
    var locale = Localizations.localeOf(context);
    var language = locale.languageCode == 'ko' ? 'ko' : 'en';
    return language;
  }
}
