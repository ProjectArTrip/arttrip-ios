import 'package:flutter/foundation.dart';

class AppUtil {
  const AppUtil._();

  static void debugLog(str) {
    if (kDebugMode) print('AppLog : $str');
  }
}
