import 'package:arttrip/core/api_endpoints.dart';
import 'package:arttrip/core/env.dart';
import 'package:arttrip/core/network/network.dart';
import 'package:arttrip/features/auth/data/models/auth_token_result.dart';
import 'package:arttrip/features/auth/services/token_storage_service.dart';
import 'package:dio/dio.dart';

/// 인증 관련 API 서비스
class AuthApiService extends BaseApiService {
  AuthApiService({super.client});

  /// 소셜 로그인
  ///
  /// [provider] - 소셜 로그인 제공자 (KAKAO, GOOGLE, APPLE)
  /// [idToken] - 소셜 로그인에서 받은 토큰
  Future<ApiResult<AuthTokenResult>> socialLogin({
    required String provider,
    String? idToken,
    String? authorizationCode,
  }) {
    return post<AuthTokenResult>(
      ApiEndpoints.authSocial,
      data: {
        'provider': provider,
        'idToken': ?idToken,
        'authorizationCode': ?authorizationCode,
      },
      fromJson: (data) =>
          AuthTokenResult.fromJson(data as Map<String, dynamic>),
    );
  }

  /// 테스트 계정 로그인
  Future<ApiResult<AuthTokenResult>> testLogin({
    required String email,
    required String password,
  }) {
    return post<AuthTokenResult>(
      ApiEndpoints.authLoginTest,
      data: {'email': email, 'password': password},
      fromJson: (data) =>
          AuthTokenResult.fromJson(data as Map<String, dynamic>),
    );
  }

  /// 토큰 갱신 (재발행)
  ///
  /// [refreshToken] - 갱신에 사용할 리프레시 토큰
  Future<ApiResult<AuthTokenResult>> refreshToken({
    required String refreshToken,
  }) {
    return post<AuthTokenResult>(
      ApiEndpoints.authReissue,
      data: {'refreshToken': refreshToken},
      fromJson: (data) =>
          AuthTokenResult.fromJson(data as Map<String, dynamic>),
    );
  }

  /// 로그아웃
  ///
  /// [refreshToken] - 로그아웃할 리프레시 토큰
  /// 인터셉터를 거치지 않도록 별도 Dio 인스턴스 사용 (무한 루프 방지)
  Future<ApiResult<void>> logout({required String refreshToken}) async {
    try {
      final accessToken = TokenStorageService.instance.getAccessToken();
      final dio = Dio(
        BaseOptions(
          baseUrl: Env.apiBaseUrl,
          headers: {
            'Content-Type': 'application/json',
            if (accessToken != null) 'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      await dio.post(
        ApiEndpoints.authLogout,
        data: {'refreshToken': refreshToken},
      );
      return const ApiResult.success(null);
    } catch (e) {
      // 로그아웃 실패해도 로컬 로그아웃은 진행되므로 에러 무시
      return ApiResult.failure(
        NetworkException.unexpected(message: e.toString()),
      );
    }
  }
}

/// 소셜 로그인 제공자
enum SocialProvider {
  kakao('KAKAO'),
  google('GOOGLE'),
  apple('APPLE');

  const SocialProvider(this.value);
  final String value;
}
