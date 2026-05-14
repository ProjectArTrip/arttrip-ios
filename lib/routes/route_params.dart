import 'dart:convert';

/// GoRouter의 extra 직렬화 경고를 억제하기 위한 codec.
///
/// GoRouter는 extra 파라미터를 JSON으로 직렬화하려 시도하며,
/// 실패 시 경고를 출력합니다. 모바일에서는 메모리 참조로 전달되므로
/// 실제 직렬화가 필요 없지만, 경고 억제를 위해 null을 반환합니다.
class ExtraCodec extends Codec<Object?, Object?> {
  const ExtraCodec();

  @override
  Converter<Object?, Object?> get encoder => const _NullConverter();

  @override
  Converter<Object?, Object?> get decoder => const _NullConverter();
}

class _NullConverter extends Converter<Object?, Object?> {
  const _NullConverter();

  @override
  Object? convert(Object? input) => null;
}

/// WebView 페이지 파라미터
class WebViewParams {
  const WebViewParams({required this.title, required this.url});

  final String title;
  final String url;
}

/// 약관동의 화면으로 전달하는 소셜 로그인 파라미터
class SocialLoginParams {
  const SocialLoginParams({
    required this.provider,
    this.idToken,
    this.authorizationCode,
  });

  final String provider;
  final String? idToken;
  final String? authorizationCode;
}
