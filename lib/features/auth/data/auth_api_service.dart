import 'package:arttrip/core/network/network.dart';

/// 인증 관련 API 서비스
class AuthApiService extends BaseApiService {
  AuthApiService({super.client});

  /// 소셜 로그인
  ///
  /// [provider] - 소셜 로그인 제공자 (KAKAO, GOOGLE, APPLE)
  /// [idToken] - 소셜 로그인에서 받은 토큰
  Future<ApiResult<AuthTokenResponse>> socialLogin({
    required String provider,
    required String idToken,
  }) {
    return post<AuthTokenResponse>(
      '/auth/social',
      data: {
        'provider': provider,
        'idToken': idToken,
      },
      fromJson: (data) {
        var json = data as Map<String, dynamic>;
        var result = json['result'] as Map<String, dynamic>?;
        return AuthTokenResponse.fromJson(result ?? json);
      },
    );
  }

  /// 토큰 갱신 (재발행)
  ///
  /// [refreshToken] - 갱신에 사용할 리프레시 토큰
  Future<ApiResult<AuthTokenResponse>> refreshToken({
    required String refreshToken,
  }) {
    return post<AuthTokenResponse>(
      '/auth/app/reissue',
      data: {
        'refreshToken': refreshToken,
      },
      fromJson: (data) {
        var json = data as Map<String, dynamic>;
        var result = json['result'] as Map<String, dynamic>?;
        return AuthTokenResponse.fromJson(result ?? json);
      },
    );
  }

  /// 로그아웃
  Future<ApiResult<void>> logout() async {
    var result = await post<Object?>('/auth/logout');
    return result.map((_) {});
  }
}

/// 인증 토큰 응답 모델
class AuthTokenResponse {
  const AuthTokenResponse({
    required this.accessToken,
    required this.refreshToken,
    this.expiresIn,
    this.tokenType = 'Bearer',
  });

  factory AuthTokenResponse.fromJson(Map<String, dynamic> json) {
    return AuthTokenResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresIn: json['expiresIn'] as int?,
      tokenType: json['tokenType'] as String? ?? 'Bearer',
    );
  }

  final String accessToken;
  final String refreshToken;
  final int? expiresIn;
  final String tokenType;

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      if (expiresIn != null) 'expiresIn': expiresIn,
      'tokenType': tokenType,
    };
  }

  @override
  String toString() {
    return 'AuthTokenResponse(accessToken: ${accessToken.substring(0, 10)}..., refreshToken: ${refreshToken.substring(0, 10)}...)';
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
