import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleLoginResult {
  const AppleLoginResult({
    required this.isSuccess,
    this.authorizationCode,
    this.errorMessage,
  });

  factory AppleLoginResult.success({
    String? authorizationCode,
  }) {
    return AppleLoginResult(
      isSuccess: true,
      authorizationCode: authorizationCode,
    );
  }

  factory AppleLoginResult.failure(String message) {
    return AppleLoginResult(isSuccess: false, errorMessage: message);
  }

  final bool isSuccess;
  final String? authorizationCode;
  final String? errorMessage;
}

class AppleLoginService {
  AppleLoginService._internal();

  static final AppleLoginService _instance = AppleLoginService._internal();

  static AppleLoginService get instance => _instance;

  Future<AppleLoginResult> login() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        return AppleLoginResult.failure('Identity Token을 받지 못했습니다.');
      }

      debugPrint('애플 로그인 성공');
      return AppleLoginResult.success(
        authorizationCode: credential.authorizationCode,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return AppleLoginResult.failure('로그인이 취소됐습니다');
      }
      debugPrint('애플 로그인 실패: $e');
      return AppleLoginResult.failure('로그인 중 오류가 발생했습니다');
    } catch (e) {
      debugPrint('애플 로그인 실패: $e');
      return AppleLoginResult.failure('로그인 중 오류가 발생했습니다');
    }
  }

  Future<void> logout() async {
    // Apple Sign-In SDK는 별도 로그아웃 메서드를 제공하지 않음
  }
}
