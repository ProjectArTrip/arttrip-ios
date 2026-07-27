import 'package:arttrip/core/config/prefs.dart';
import 'package:flutter/foundation.dart';

/// 토큰 저장소 서비스
///
/// Access Token과 Refresh Token을 저장/조회/삭제
/// 토큰 만료 여부는 서버 401 응답으로 판단 (로컬 만료 시간 체크 불필요)
class TokenStorageService {
  TokenStorageService._internal();

  static final TokenStorageService _instance = TokenStorageService._internal();

  /// 싱글톤 인스턴스
  static TokenStorageService get instance => _instance;

  final _prefs = Prefs();

  /// 토큰 일괄 저장
  Future<void> saveTokens({
    String? accessToken,
    required String refreshToken,
    bool? isFirstLogin,
  }) async {
    await _prefs.setAccessToken(accessToken);
    await _prefs.setRefreshToken(refreshToken);
    await _prefs.setIsFirstLogin(isFirstLogin ?? false);
    debugPrint('토큰 저장 완료');
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
    final accessToken = _prefs.accessToken;
    return accessToken != null && accessToken.isNotEmpty;
  }

  /// 모든 토큰 삭제
  Future<void> clearTokens() async {
    await _prefs.clearAuthData();
    debugPrint('모든 토큰 삭제 완료');
  }
}
