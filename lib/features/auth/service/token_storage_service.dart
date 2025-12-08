import 'package:arttrip/core/config/prefs.dart';
import 'package:flutter/foundation.dart';

/// 토큰 저장소 서비스
///
/// Access Token과 Refresh Token을 안전하게 저장/조회/삭제
class TokenStorageService {
  TokenStorageService._internal();

  static final TokenStorageService _instance = TokenStorageService._internal();

  /// 싱글톤 인스턴스
  static TokenStorageService get instance => _instance;

  /// Access Token 만료 시간: 15분
  static const int _accessTokenExpiryMinutes = 15;

  /// Refresh Token 만료 시간: 7일
  static const int _refreshTokenExpiryDays = 7;

  final _prefs = Prefs();

  /// 토큰 일괄 저장
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    var now = DateTime.now().millisecondsSinceEpoch;

    // Access Token 저장 (15분 만료)
    await _prefs.setAccessToken(accessToken);
    var accessExpiry = now + (_accessTokenExpiryMinutes * 60 * 1000);
    await _prefs.setAccessTokenExpiry(accessExpiry);

    // Refresh Token 저장 (7일 만료)
    await _prefs.setRefreshToken(refreshToken);
    var refreshExpiry = now + (_refreshTokenExpiryDays * 24 * 60 * 60 * 1000);
    await _prefs.setRefreshTokenExpiry(refreshExpiry);

    debugPrint('토큰 저장 완료 (Access: 15분, Refresh: 7일)');
  }

  /// Access Token 조회
  String? getAccessToken() {
    return _prefs.accessToken;
  }

  /// Refresh Token 조회
  String? getRefreshToken() {
    return _prefs.refreshToken;
  }

  /// 토큰 존재 여부 확인
  bool hasToken() {
    var accessToken = _prefs.accessToken;
    return accessToken != null && accessToken.isNotEmpty;
  }

  /// Access Token 만료 여부 확인
  bool isAccessTokenExpired() {
    var expiry = _prefs.accessTokenExpiry;
    if (expiry == null) return true;

    var now = DateTime.now().millisecondsSinceEpoch;
    // 만료 1분 전에 만료로 처리 (갱신 여유 시간)
    return now >= (expiry - 60000);
  }

  /// Refresh Token 만료 여부 확인
  bool isRefreshTokenExpired() {
    var expiry = _prefs.refreshTokenExpiry;
    if (expiry == null) return true;

    var now = DateTime.now().millisecondsSinceEpoch;
    return now >= expiry;
  }

  /// Access Token 만료 여부 (기존 메서드명 호환)
  bool isTokenExpired() {
    return isAccessTokenExpired();
  }

  /// 모든 토큰 삭제
  Future<void> clearTokens() async {
    await _prefs.clearAuthData();
    debugPrint('모든 토큰 삭제 완료');
  }

  /// Access Token만 삭제
  Future<void> clearAccessToken() async {
    await _prefs.setAccessToken(null);
    await _prefs.setAccessTokenExpiry(null);
  }
}
