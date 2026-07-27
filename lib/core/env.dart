import 'package:arttrip/core/app_consts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 환경 변수 접근 클래스
class Env {
  Env._();

  /// 카카오 Native App Key
  static String get kakaoNativeAppKey =>
      dotenv.env['KAKAO_NATIVE_APP_KEY'] ?? '';

  /// API Base URL
  static String get apiBaseUrl => AppConsts.isDevServer
      ? dotenv.env['API_BASE_URL'] ?? ''
      : dotenv.env['REAL_API_BASE_URL'] ?? '';

  /// Google iOS Client ID (웹 앱 Client ID와 같은 GCP 프로젝트의 iOS 타입)
  static String get googleClientId => dotenv.env['GOOGLE_CLIENT_ID'] ?? '';

  /// Google Server Client ID (웹 애플리케이션 타입 Client ID)
  static String get googleServerClientId =>
      dotenv.env['GOOGLE_SERVER_CLIENT_ID'] ?? '';
}
