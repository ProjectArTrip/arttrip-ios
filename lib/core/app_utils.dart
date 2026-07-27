import 'package:arttrip/core/app_consts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppUtil {
  const AppUtil._();

  static void debugLog(String str) {
    if (kDebugMode) print('AppLog : $str');
  }

  /// 이번주의 각 DateTime 리스트
  static List<DateTime> getCurrentWeek(DateTime focusedDay) {
    // 일요일 시작
    final sunday = focusedDay.subtract(Duration(days: focusedDay.weekday % 7));
    return List.generate(7, (index) => sunday.add(Duration(days: index)));
  }

  /// 일자별 요일
  static String weekdayLabel({required DateTime date, required Locale locale}) {
    final isKorean = locale.languageCode == 'ko';
    final labels = isKorean ? AppConsts.weekDaysKo : AppConsts.weekDaysEn;

    // DateTime.weekday: Mon=1 ... Sun=7
    return labels[date.weekday % 7];
  }

  /// 일 ~ 월 요일 리스트
  static List<String> getLocalizedWeekdays(Locale locale) {
    final isKorean = locale.languageCode == 'ko';
    final labels = isKorean ? AppConsts.weekDaysKo : AppConsts.weekDaysEn;
    return labels;
  }

  /// 언어에 따라 날짜 + 요일 포맷 반환
  /// ko: '2025년 12월 25일(목)' / en: 'December 25, 2025 (Thu)'
  static String formatDateFullWithWeekday(BuildContext context, DateTime date) {
    final lang = getLanguage(context);
    if (lang == 'ko') {
      final weekday = AppConsts.weekDaysKo[date.weekday % 7];
      return '${DateFormat('yyyy년 MM월 dd일').format(date)}($weekday)';
    } else {
      final weekday = AppConsts.weekDaysEn[date.weekday % 7];
      return '${DateFormat('MMMM d, yyyy').format(date)} ($weekday)';
    }
  }

  /// String → DateTime 변환, 파싱 실패 시 null 반환
  /// [format] 미지정 시 ISO 8601 파싱 ('2025-12-25', '2025-12-25T10:00:00' 등)
  static DateTime parseDate(String dateStr) {
    return DateTime.tryParse(dateStr) ?? DateTime.now();
  }

  /// '2025-12-25' 포맷 반환
  static String formatDateYMD(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  /// 언어에 따라 '2025년 12월' 포맷 반환
  static String formatDateLocaleYM(BuildContext context, DateTime date) {
    final lang = getLanguage(context);

    if (lang == 'ko') {
      // 한국어: 2026년 10월
      return DateFormat('yyyy년 MM월').format(date);
    } else {
      // 영어: October 2026 (또는 원하는 영어 형식)
      return DateFormat('MMMM yyyy').format(date);
    }
  }

  static String getLanguage(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final language = locale.languageCode == 'ko' ? 'ko' : 'en';
    return language;
  }

  /// 언어에 따라 12.17 (수) - 12.22 (월) 포멧 반환
  static String getRangeDateString({
    required BuildContext context,
    required DateTime start,
    required DateTime end,
  }) {
    final lang = getLanguage(context);
    final DateFormat formatter = DateFormat('MM.dd (E)', lang);

    final String startStr = formatter.format(start);
    final String endStr = formatter.format(end);

    return '$startStr - $endStr';
  }
}
