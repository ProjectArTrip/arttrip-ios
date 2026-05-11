import 'dart:async';

import 'package:arttrip/core/config/prefs.dart';
import 'package:arttrip/features/auth/data/auth_api_service.dart';
import 'package:arttrip/features/auth/services/token_storage_service.dart';
import 'package:arttrip/features/login/services/kakao_login_service.dart';
import 'package:arttrip/features/my/viewmodels/my_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// 인증 결과
class AuthResult {
  const AuthResult({
    required this.isSuccess,
    this.firstLogin,
    this.errorMessage,
  });

  factory AuthResult.success({bool? firstLogin}) =>
      AuthResult(isSuccess: true, firstLogin: firstLogin);

  factory AuthResult.failure(String message) =>
      AuthResult(isSuccess: false, errorMessage: message);

  final bool isSuccess;
  final bool? firstLogin;
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
  Future<AuthResult> loginWithKakao(BuildContext context) async {
    try {
      // 1. 카카오 로그인으로 idToken 획득
      final kakaoResult = await _kakaoLogin.login();

      if (!kakaoResult.isSuccess || kakaoResult.idToken == null) {
        return AuthResult.failure(
          kakaoResult.errorMessage ?? '카카오 로그인에 실패했습니다',
        );
      }

      debugPrint('카카오 idToken 획득 성공');

      // 2. 서버에 소셜 로그인 요청
      final serverResult = await _authApi.socialLogin(
        provider: SocialProvider.kakao.value,
        idToken: kakaoResult.idToken!,
      );

      return serverResult.when(
        success: (tokenResult) async {
          // 3. 토큰 저장
          await _tokenStorage.saveTokens(
            accessToken: tokenResult.accessToken,
            refreshToken: tokenResult.refreshToken,
            isFirstLogin: tokenResult.firstLogin,
          );

          if (context.mounted) {
            unawaited(
              context.read<MyViewModel>().registerFcmToken(
                Prefs().fcmToken ?? '',
              ),
            );
          }

          debugPrint('서버 토큰 발급 및 저장 완료, firstLogin: ${tokenResult.firstLogin}');
          return AuthResult.success(firstLogin: tokenResult.firstLogin);
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

  /// 테스트 계정 로그인
  Future<AuthResult> loginWithTestAccount(BuildContext context) async {
    try {
      const testEmail = 'test@arttrip.com';
      const testPassword = 'test1234';

      final result = await _authApi.testLogin(
        email: testEmail,
        password: testPassword,
      );

      return result.when(
        success: (tokenResult) async {
          await _tokenStorage.saveTokens(
            accessToken: tokenResult.accessToken,
            refreshToken: tokenResult.refreshToken,
            isFirstLogin: tokenResult.firstLogin,
          );

          if (context.mounted) {
            unawaited(
              context.read<MyViewModel>().registerFcmToken(
                Prefs().fcmToken ?? '',
              ),
            );
          }

          return AuthResult.success(firstLogin: tokenResult.firstLogin);
        },
        failure: (exception) {
          return AuthResult.failure(exception.message);
        },
      );
    } catch (e) {
      debugPrint('테스트 로그인 오류: $e');
      return AuthResult.failure('테스트 로그인 중 오류가 발생했습니다');
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
    final refreshToken = _tokenStorage.getRefreshToken();

    // 서버 로그아웃 (실패해도 로컬 로그아웃은 진행)
    if (refreshToken != null) {
      final result = await _authApi.logout(refreshToken: refreshToken);
      result.when(
        success: (_) => debugPrint('서버 로그아웃 성공'),
        failure: (e) => debugPrint('서버 로그아웃 실패: ${e.message}'),
      );
    }

    // 카카오 로그아웃
    await _kakaoLogin.logout();

    // 저장된 토큰 삭제
    await _tokenStorage.clearTokens();

    debugPrint('로그아웃 완료');
  }

  /// 회원 탈퇴
  ///
  /// 서버 탈퇴 → 카카오 unlink → 로컬 토큰 삭제
  /// 서버 응답 실패 시 로컬 정리 없이 false 반환 (재시도 가능하도록)
  Future<bool> withdraw() async {
    final refreshToken = _tokenStorage.getRefreshToken();
    if (refreshToken == null) return false;

    final result = await _authApi.withdraw(refreshToken: refreshToken);

    return result.when(
      success: (_) async {
        await _kakaoLogin.unlink();
        await _tokenStorage.clearTokens();
        debugPrint('회원 탈퇴 완료');
        return true;
      },
      failure: (e) {
        debugPrint('회원 탈퇴 실패: ${e.message}');
        return false;
      },
    );
  }

  /// 토큰 갱신
  Future<String?> refreshToken() async {
    final refreshToken = _tokenStorage.getRefreshToken();
    if (refreshToken == null) return null;

    final result = await _authApi.refreshToken(refreshToken: refreshToken);

    return result.when(
      success: (tokenResult) async {
        await _tokenStorage.saveTokens(
          accessToken: tokenResult.accessToken,
          refreshToken: tokenResult.refreshToken,
          isFirstLogin: tokenResult.firstLogin,
        );
        return tokenResult.accessToken;
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

  /// 로그인 상태 확인 (토큰 존재 여부)
  ///
  /// 토큰 만료 여부는 API 호출 시 서버 401 응답으로 판단
  bool isLoggedIn() {
    return _tokenStorage.hasToken();
  }
}
