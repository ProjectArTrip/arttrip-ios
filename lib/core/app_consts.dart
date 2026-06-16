import 'package:flutter/foundation.dart';

class AppConsts {
  const AppConsts._();

  static const bool _useDevServer = true; // true: 개발 서버, false: 운영 서버
  static const bool isDevServer = _useDevServer && !kReleaseMode;
  static const bool useMock = false; // Force using dummy data
  static const int mockLoadingDelayMs =
      500; // Dummy data loading delay in milliseconds

  static const shimmerDurationMs = 1200;
  static const shimmerIntervalMs = 400;

  static const weekDaysKo = ['일', '월', '화', '수', '목', '금', '토'];
  static const weekDaysEn = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
}
