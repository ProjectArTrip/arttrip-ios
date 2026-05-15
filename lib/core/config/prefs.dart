import 'package:arttrip/core/app_utils.dart';
import 'package:arttrip/core/enum.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences 공용 클래스
class Prefs {
  factory Prefs() => _instance;
  Prefs._();
  static final _instance = Prefs._();

  late SharedPreferences prefs;

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  // ============================================
  // Auth Token
  // ============================================

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _fcmTokenKey = 'fcm_token';

  String? get accessToken => prefs.getString(_accessTokenKey);
  String? get refreshToken => prefs.getString(_refreshTokenKey);
  String? get fcmToken => prefs.getString(_fcmTokenKey);

  /// 첫 로그인 여부 조회
  bool get isFirstLogin => prefs.getBool('is_first_login') ?? false;

  Future<void> setAccessToken(String? value) async {
    if (value == null) {
      await prefs.remove(_accessTokenKey);
    } else {
      await prefs.setString(_accessTokenKey, value);
      AppUtil.debugLog('jwt: $value');
    }
  }

  Future<void> setRefreshToken(String? value) async {
    if (value == null) {
      await prefs.remove(_refreshTokenKey);
    } else {
      await prefs.setString(_refreshTokenKey, value);
    }
  }

  /// 모든 인증 관련 데이터 삭제
  Future<void> clearAuthData() async {
    await Future.wait([
      prefs.remove(_accessTokenKey),
      prefs.remove(_refreshTokenKey),
    ]);
  }

  /// 첫 로그인 여부 저장
  Future<void> setIsFirstLogin(bool value) async {
    await prefs.setBool('is_first_login', value);
  }

  /// FCM 토큰 저장
  Future<void> setFcmToken(String? value) async {
    if (value == null) {
      await prefs.remove(_fcmTokenKey);
    } else {
      await prefs.setString(_fcmTokenKey, value);
    }
  }

  // ============================================
  // Onboarding Step
  // ============================================

  static const String _onboardingStepKey = 'onboarding_step';

  OnboardingStep? get onboardingStep =>
      OnboardingStep.fromString(prefs.getString(_onboardingStepKey));

  Future<void> setOnboardingStep(OnboardingStep? value) async {
    if (value == null) {
      await prefs.remove(_onboardingStepKey);
    } else {
      await prefs.setString(_onboardingStepKey, value.type);
    }
  }
}
