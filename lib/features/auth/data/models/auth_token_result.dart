import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_token_result.freezed.dart';
part 'auth_token_result.g.dart';

/// 인증 토큰 결과 모델
///
/// /auth/social 성공 응답의 result 필드
/// 서버 응답에서 accessToken 또는 newAccessToken 키를 모두 지원
@freezed
abstract class AuthTokenResult with _$AuthTokenResult {
  const factory AuthTokenResult({
    @JsonKey(readValue: _readAccessToken) String? accessToken,
    required String refreshToken,
    @JsonKey(name: 'isFirstLogin') bool? firstLogin,
  }) = _AuthTokenResult;

  factory AuthTokenResult.fromJson(Map<String, dynamic> json) =>
      _$AuthTokenResultFromJson(json);
}

Object? _readAccessToken(Map<dynamic, dynamic> json, String key) =>
    json['accessToken'] ?? json['newAccessToken'];
