import 'package:json_annotation/json_annotation.dart';

part 'auth_token_result.g.dart';

/// 인증 토큰 결과 모델
///
/// /auth/social 성공 응답의 result 필드
@JsonSerializable()
class AuthTokenResult {
  const AuthTokenResult({
    required this.accessToken,
    required this.refreshToken,
    required this.firstLogin,
  });

  factory AuthTokenResult.fromJson(Map<String, dynamic> json) =>
      _$AuthTokenResultFromJson(json);

  final String accessToken;
  final String refreshToken;
  final bool firstLogin;

  Map<String, dynamic> toJson() => _$AuthTokenResultToJson(this);
}
