import 'package:json_annotation/json_annotation.dart';

part 'auth_token_result.g.dart';

/// 인증 토큰 결과 모델
///
/// /auth/social 성공 응답의 result 필드
@JsonSerializable()
class AuthTokenResult {
  const AuthTokenResult({
    this.accessToken,
    required this.refreshToken,
    this.firstLogin,
  });

  factory AuthTokenResult.fromJson(Map<String, dynamic> json) {
    final normalized = {
      ...json,
      'accessToken': json['accessToken'] ?? json['newAccessToken'],
    };
    return _$AuthTokenResultFromJson(normalized);
  }

  final String? accessToken;
  final String refreshToken;
  @JsonKey(name: 'isFirstLogin')
  final bool? firstLogin;

  Map<String, dynamic> toJson() => _$AuthTokenResultToJson(this);
}
