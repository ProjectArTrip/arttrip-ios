import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleLoginResult {
  const GoogleLoginResult({
    required this.isSuccess,
    this.idToken,
    this.errorMessage,
  });

  factory GoogleLoginResult.success({required String idToken}) {
    return GoogleLoginResult(isSuccess: true, idToken: idToken);
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
    await GoogleSignIn.instance.initialize();
  }

  Future<GoogleLoginResult> login() async {
    try {
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;

      if (idToken == null) {
        return GoogleLoginResult.failure(
          'ID Token을 받지 못했습니다. Google Cloud Console에서 OAuth 클라이언트 설정을 확인해주세요.',
        );
      }

      debugPrint('구글 로그인 성공: ${account.email}');
      return GoogleLoginResult.success(idToken: idToken);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return GoogleLoginResult.failure('로그인이 취소됐습니다');
      }
      debugPrint('구글 로그인 실패: $e');
      return GoogleLoginResult.failure('로그인 중 오류가 발생했습니다');
    } catch (e) {
      debugPrint('구글 로그인 실패: $e');
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
