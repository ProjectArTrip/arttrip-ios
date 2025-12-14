import 'package:arttrip/core/env.dart';
import 'package:arttrip/core/network/models/api_response.dart';
import 'package:arttrip/core/network/network.dart';
import 'package:arttrip/features/auth/data/models/auth_token_result.dart';
import 'package:arttrip/features/auth/service/token_storage_service.dart';
import 'package:dio/dio.dart';

/// 인증 관련 API 서비스
class AuthApiService extends BaseApiService {
  AuthApiService({super.client});

  /// 소셜 로그인
  ///
  /// [provider] - 소셜 로그인 제공자 (KAKAO, GOOGLE, APPLE)
  /// [idToken] - 소셜 로그인에서 받은 토큰
  Future<ApiResult<ApiResponse<AuthTokenResult>>> socialLogin({
    required String provider,
    required String idToken,
  }) {
    return post<ApiResponse<AuthTokenResult>>(
      '/auth/social',
      data: {
        'provider': provider,
        'idToken': idToken,
      },
      fromJson: (data) {
        var json = data as Map<String, dynamic>;
        return ApiResponse.fromJson(
          json,
          (obj) => AuthTokenResult.fromJson(obj as Map<String, dynamic>),
        );
      },
    );
  }

  /// 토큰 갱신 (재발행)
  ///
  /// [refreshToken] - 갱신에 사용할 리프레시 토큰
  Future<ApiResult<ApiResponse<AuthTokenResult>>> refreshToken({
    required String refreshToken,
  }) {
    return post<ApiResponse<AuthTokenResult>>(
      '/auth/app/reissue',
      data: {
        'refreshToken': refreshToken,
      },
      fromJson: (data) {
        var json = data as Map<String, dynamic>;
        return ApiResponse.fromJson(
          json,
          (obj) => AuthTokenResult.fromJson(obj as Map<String, dynamic>),
        );
      },
    );
  }

  /// 로그아웃
  ///
  /// [refreshToken] - 로그아웃할 리프레시 토큰
  /// 인터셉터를 거치지 않도록 별도 Dio 인스턴스 사용 (무한 루프 방지)
  Future<ApiResult<void>> logout({required String refreshToken}) async {
    try {
      var accessToken = TokenStorageService.instance.getAccessToken();
      var dio = Dio(BaseOptions(
        baseUrl: Env.apiBaseUrl,
        headers: {
          'Content-Type': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      ));

      await dio.post('/auth/app/logout', data: {'refreshToken': refreshToken});
      return ApiResult.success(null);
    } catch (e) {
      // 로그아웃 실패해도 로컬 로그아웃은 진행되므로 에러 무시
      return ApiResult.failure(NetworkException.unexpected(message: e.toString()));
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
