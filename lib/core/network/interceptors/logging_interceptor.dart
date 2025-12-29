import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// 간단한 한 줄 로깅 인터셉터
class LoggingInterceptor extends Interceptor {
  LoggingInterceptor({
    this.enableRequestBody = false,
    this.enableResponseBody = true,
  });

  /// 요청 body 출력 여부
  final bool enableRequestBody;

  /// 응답 body 출력 여부
  final bool enableResponseBody;

  /// 요청 시작 시간 저장
  final Map<int, DateTime> _requestTimes = {};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _requestTimes[options.hashCode] = DateTime.now();
    if (enableRequestBody && options.data != null) {
      debugPrint('[API] Request Body: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _log(response.requestOptions, response.statusCode, isError: false);
    if (enableResponseBody && response.data != null) {
      debugPrint('[API] Response Body: ${response.data}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log(err.requestOptions, err.response?.statusCode, isError: true);
    handler.next(err);
  }

  void _log(RequestOptions options, int? statusCode, {required bool isError}) {
    var startTime = _requestTimes.remove(options.hashCode);
    var duration =
        startTime != null
            ? DateTime.now().difference(startTime).inMilliseconds
            : 0;

    var method = options.method.padRight(6);
    var path = options.path;
    var status = statusCode?.toString() ?? 'ERR';
    var icon = isError ? '✗' : '✓';

    debugPrint('[API] $icon $method $path → $status (${duration}ms)');
  }
}
