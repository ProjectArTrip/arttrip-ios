import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 환경 변수 접근 클래스
class Env {
  Env._();

  /// 카카오 Native App Key
  static String get kakaoNativeAppKey =>
      dotenv.env['KAKAO_NATIVE_APP_KEY'] ?? '';

  /// API Base URL
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? '';
}
