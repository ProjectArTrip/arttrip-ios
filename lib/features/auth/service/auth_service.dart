import 'package:arttrip/features/auth/data/auth_api_service.dart';
import 'package:arttrip/features/auth/service/token_storage_service.dart';
import 'package:arttrip/features/login/service/kakao_login_service.dart';
import 'package:flutter/foundation.dart';

/// 인증 결과
class AuthResult {
  const AuthResult({
    required this.isSuccess,
    this.errorMessage,
  });

  factory AuthResult.success() => const AuthResult(isSuccess: true);

  factory AuthResult.failure(String message) =>
      AuthResult(isSuccess: false, errorMessage: message);

  final bool isSuccess;
  final String? errorMessage;
}

/// 통합 인증 서비스
///
/// 소셜 로그인 + 서버 토큰 발급을 통합 관리
class AuthService {
  AuthService._internal();

  static final AuthService _instance = AuthService._internal();

  /// 싱글톤 인스턴스
  static AuthService get instance => _instance;

  final _authApi = AuthApiService();
  final _tokenStorage = TokenStorageService.instance;
  final _kakaoLogin = KakaoLoginService.instance;

  /// 카카오 로그인 (소셜 로그인 + 서버 토큰 발급)
  Future<AuthResult> loginWithKakao() async {
    try {
      // 1. 카카오 로그인으로 idToken 획득
      var kakaoResult = await _kakaoLogin.login();

      if (!kakaoResult.isSuccess || kakaoResult.idToken == null) {
        return AuthResult.failure(
          kakaoResult.errorMessage ?? '카카오 로그인에 실패했습니다',
        );
      }

      debugPrint('카카오 idToken 획득 성공');

      // 2. 서버에 소셜 로그인 요청
      var serverResult = await _authApi.socialLogin(
        provider: SocialProvider.kakao.value,
        idToken: kakaoResult.idToken!,
      );

      return serverResult.when(
        success: (tokenResponse) async {
          // 3. 토큰 저장
          await _tokenStorage.saveTokens(
            accessToken: tokenResponse.accessToken,
            refreshToken: tokenResponse.refreshToken,
          );

          debugPrint('서버 토큰 발급 및 저장 완료');
          return AuthResult.success();
        },
        failure: (exception) {
          debugPrint('서버 토큰 발급 실패: ${exception.message}');
          return AuthResult.failure(exception.message);
        },
      );
    } catch (e) {
      debugPrint('로그인 중 오류 발생: $e');
      return AuthResult.failure('로그인 중 오류가 발생했습니다');
    }
  }

  /// Google 로그인 (추후 구현)
  Future<AuthResult> loginWithGoogle() async {
    // TODO: Google 로그인 구현
    return AuthResult.failure('Google 로그인은 아직 지원되지 않습니다');
  }

  /// Apple 로그인 (추후 구현)
  Future<AuthResult> loginWithApple() async {
    // TODO: Apple 로그인 구현
    return AuthResult.failure('Apple 로그인은 아직 지원되지 않습니다');
  }

  /// 로그아웃
  Future<void> logout() async {
    try {
      // 서버 로그아웃 (선택적)
      await _authApi.logout();
    } catch (e) {
      debugPrint('서버 로그아웃 실패: $e');
    }

    // 카카오 로그아웃
    await _kakaoLogin.logout();

    // 저장된 토큰 삭제
    await _tokenStorage.clearTokens();

    debugPrint('로그아웃 완료');
  }

  /// 토큰 갱신
  Future<String?> refreshToken() async {
    var refreshToken = _tokenStorage.getRefreshToken();
    if (refreshToken == null) return null;

    var result = await _authApi.refreshToken(refreshToken: refreshToken);

    return result.when(
      success: (tokenResponse) async {
        await _tokenStorage.saveTokens(
          accessToken: tokenResponse.accessToken,
          refreshToken: tokenResponse.refreshToken,
        );
        return tokenResponse.accessToken;
      },
      failure: (exception) {
        debugPrint('토큰 갱신 실패: ${exception.message}');
        return null;
      },
    );
  }

  /// 현재 Access Token 조회
  String? getAccessToken() {
    return _tokenStorage.getAccessToken();
  }

  /// 로그인 상태 확인
  bool isLoggedIn() {
    return _tokenStorage.hasToken();
  }

  /// 토큰 만료 여부 확인
  bool isTokenExpired() {
    return _tokenStorage.isTokenExpired();
  }
}
