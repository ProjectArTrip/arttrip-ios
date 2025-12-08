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
  static const String _accessTokenExpiryKey = 'access_token_expiry';
  static const String _refreshTokenExpiryKey = 'refresh_token_expiry';

  String? get accessToken => prefs.getString(_accessTokenKey);
  String? get refreshToken => prefs.getString(_refreshTokenKey);
  int? get accessTokenExpiry => prefs.getInt(_accessTokenExpiryKey);
  int? get refreshTokenExpiry => prefs.getInt(_refreshTokenExpiryKey);

  Future<void> setAccessToken(String? value) async {
    if (value == null) {
      await prefs.remove(_accessTokenKey);
    } else {
      await prefs.setString(_accessTokenKey, value);
    }
  }

  Future<void> setRefreshToken(String? value) async {
    if (value == null) {
      await prefs.remove(_refreshTokenKey);
    } else {
      await prefs.setString(_refreshTokenKey, value);
    }
  }

  Future<void> setAccessTokenExpiry(int? value) async {
    if (value == null) {
      await prefs.remove(_accessTokenExpiryKey);
    } else {
      await prefs.setInt(_accessTokenExpiryKey, value);
    }
  }

  Future<void> setRefreshTokenExpiry(int? value) async {
    if (value == null) {
      await prefs.remove(_refreshTokenExpiryKey);
    } else {
      await prefs.setInt(_refreshTokenExpiryKey, value);
    }
  }

  /// 모든 인증 관련 데이터 삭제
  Future<void> clearAuthData() async {
    await Future.wait([
      prefs.remove(_accessTokenKey),
      prefs.remove(_refreshTokenKey),
      prefs.remove(_accessTokenExpiryKey),
      prefs.remove(_refreshTokenExpiryKey),
    ]);
  }
}
