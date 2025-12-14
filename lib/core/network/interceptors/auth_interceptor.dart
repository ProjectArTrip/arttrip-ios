import 'package:dio/dio.dart';

/// 인증 토큰을 자동으로 헤더에 추가하는 인터셉터
///
/// 기능:
/// - 모든 요청에 Access Token 추가
/// - 401 응답 시 토큰 갱신 후 재요청
/// - 토큰 갱신 중 다른 요청 대기 처리
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.tokenProvider,
    required this.onTokenRefresh,
    required this.onTokenExpired,
  });

  /// 현재 토큰을 제공하는 콜백
  final Future<String?> Function() tokenProvider;

  /// 토큰 갱신을 수행하는 콜백 (refresh token으로 새 access token 획득)
  /// 성공 시 새 access token 반환, 실패 시 null 반환
  final Future<String?> Function() onTokenRefresh;

  /// 토큰이 완전히 만료되었을 때 호출되는 콜백 (로그아웃 처리 등)
  final Future<void> Function() onTokenExpired;

  /// 토큰 갱신 중인지 여부
  bool _isRefreshing = false;

  /// 토큰 갱신 대기 중인 요청들
  final List<_PendingRequest> _pendingRequests = [];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 토큰이 필요 없는 엔드포인트는 건너뛰기
    if (_isPublicEndpoint(options.path)) {
      return handler.next(options);
    }

    var token = await tokenProvider();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // 401 Unauthorized 에러가 아니면 그대로 전달
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // 토큰 갱신 엔드포인트에서 401이 발생하면 완전 만료 처리
    if (_isTokenRefreshEndpoint(err.requestOptions.path)) {
      await onTokenExpired();
      return handler.next(err);
    }

    // 응답 body에서 code 확인
    var errorCode = _extractErrorCode(err.response);

    // JWT401-EXPIRED_ACCESS만 토큰 갱신 시도, 나머지는 바로 로그아웃
    if (errorCode != 'JWT401-EXPIRED_ACCESS') {
      await onTokenExpired();
      return handler.next(err);
    }

    // 이미 토큰 갱신 중이면 대기열에 추가
    if (_isRefreshing) {
      return _queueRequest(err.requestOptions, handler);
    }

    // 토큰 갱신 시작
    _isRefreshing = true;

    try {
      var newToken = await onTokenRefresh();

      if (newToken != null) {
        // 토큰 갱신 성공 - 현재 요청 재시도
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        var response = await _retry(err.requestOptions);
        handler.resolve(response);

        // 대기 중인 요청들도 재시도
        await _processPendingRequests(newToken);
      } else {
        // 토큰 갱신 실패 - 만료 처리
        await onTokenExpired();
        _rejectPendingRequests(err);
        handler.next(err);
      }
    } catch (e) {
      // 토큰 갱신 중 에러 발생
      await onTokenExpired();
      _rejectPendingRequests(err);
      handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }

  /// 응답에서 에러 코드 추출
  String? _extractErrorCode(Response<dynamic>? response) {
    if (response?.data == null) return null;

    try {
      var data = response!.data;
      if (data is Map<String, dynamic>) {
        return data['code'] as String?;
      }
    } catch (_) {}

    return null;
  }

  /// 토큰이 필요 없는 공개 엔드포인트인지 확인
  bool _isPublicEndpoint(String path) {
    const publicEndpoints = [
      '/auth/login',
      '/auth/register',
      '/auth/refresh',
      '/auth/social',
      '/auth/app/reissue',
      '/health',
    ];

    return publicEndpoints.any((endpoint) => path.contains(endpoint));
  }

  /// 토큰 갱신 엔드포인트인지 확인
  bool _isTokenRefreshEndpoint(String path) {
    return path.contains('/auth/refresh') || path.contains('/auth/app/reissue');
  }

  /// 요청을 대기열에 추가
  void _queueRequest(
    RequestOptions options,
    ErrorInterceptorHandler handler,
  ) {
    _pendingRequests.add(_PendingRequest(options, handler));
  }

  /// 대기 중인 요청들을 새 토큰으로 재시도
  Future<void> _processPendingRequests(String newToken) async {
    var requests = List<_PendingRequest>.from(_pendingRequests);
    _pendingRequests.clear();

    for (var request in requests) {
      try {
        request.options.headers['Authorization'] = 'Bearer $newToken';
        var response = await _retry(request.options);
        request.handler.resolve(response);
      } catch (e) {
        request.handler.reject(
          DioException(
            requestOptions: request.options,
            error: e,
          ),
        );
      }
    }
  }

  /// 대기 중인 요청들을 에러로 거부
  void _rejectPendingRequests(DioException error) {
    var requests = List<_PendingRequest>.from(_pendingRequests);
    _pendingRequests.clear();

    for (var request in requests) {
      request.handler.reject(
        DioException(
          requestOptions: request.options,
          error: error.error,
          response: error.response,
          type: error.type,
        ),
      );
    }
  }

  /// 요청 재시도
  Future<Response<Object?>> _retry(RequestOptions options) async {
    var dio = Dio();
    return dio.fetch(options);
  }
}

/// 대기 중인 요청 정보
class _PendingRequest {
  _PendingRequest(this.options, this.handler);

  final RequestOptions options;
  final ErrorInterceptorHandler handler;
}
