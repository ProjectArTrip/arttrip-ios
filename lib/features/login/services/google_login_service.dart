import 'package:arttrip/core/env.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleLoginResult {
  const GoogleLoginResult({
    required this.isSuccess,
    this.errorMessage,
    this.idToken,
  });

  factory GoogleLoginResult.success({
    String? idToken,
  }) {
    return GoogleLoginResult(
      isSuccess: true,
      idToken: idToken,
    );
  }

  factory GoogleLoginResult.failure(String message) {
    return GoogleLoginResult(isSuccess: false, errorMessage: message);
  }

  final bool isSuccess;
  final String? idToken;
  final String? errorMessage;
}

class GoogleLoginService {
  GoogleLoginService._internal();

  static final GoogleLoginService _instance = GoogleLoginService._internal();

  static GoogleLoginService get instance => _instance;

  static Future<void> initialize() async {
    await GoogleSignIn.instance.initialize(
      clientId: Env.googleClientId.isNotEmpty ? Env.googleClientId : null,
      serverClientId: Env.googleServerClientId.isNotEmpty
          ? Env.googleServerClientId
          : null,
    );
  }

  Future<GoogleLoginResult> login() async {
    try {
      final account = await GoogleSignIn.instance.authenticate();
      final serverAuth = account.authentication.idToken;
      final idToken = serverAuth;

      if (idToken == null) {
        return GoogleLoginResult.failure(
          'ID Token을 받지 못했습니다. .env의 GOOGLE_SERVER_CLIENT_ID(웹 애플리케이션 클라이언트 ID)를 확인해주세요.',
        );
      }

      debugPrint('구글 로그인 성공: ${account.email}');
      return GoogleLoginResult.success(
        idToken: idToken,
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return GoogleLoginResult.failure('로그인이 취소됐습니다');
      }
      debugPrint('구글 로그인 실패 (GoogleSignInException): code=${e.code}, msg=$e');
      return GoogleLoginResult.failure('로그인 중 오류가 발생했습니다');
    } catch (e, st) {
      debugPrint('구글 로그인 실패 (catch): $e\n$st');
      return GoogleLoginResult.failure('로그인 중 오류가 발생했습니다');
    }
  }

  Future<void> logout() async {
    try {
      await GoogleSignIn.instance.signOut();
      debugPrint('구글 로그아웃 성공');
    } catch (e) {
      debugPrint('구글 로그아웃 실패: $e');
    }
  }
}
