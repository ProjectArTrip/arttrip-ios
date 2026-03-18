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
      if (options.data is FormData) {
        final formData = options.data as FormData;
        debugPrint('[API] Request FormData:');
        // extra에 저장된 JSON body 출력
        final requestJson = options.extra['requestJson'];
        if (requestJson != null) {
          debugPrint('[API]   request: $requestJson');
        }
        for (var field in formData.fields) {
          debugPrint('[API]   ${field.key}: ${field.value}');
        }
        // 파일 목록 출력 (JSON 파트 제외)
        for (var file in formData.files) {
          final contentType = file.value.contentType?.toString() ?? '';
          if (!contentType.contains('json')) {
            debugPrint('[API]   ${file.key}: ${file.value.filename}');
          }
        }
      } else {
        debugPrint('[API] Request Body: ${options.data}');
      }
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
    final startTime = _requestTimes.remove(options.hashCode);
    final duration =
        startTime != null
            ? DateTime.now().difference(startTime).inMilliseconds
            : 0;

    final method = options.method.padRight(6);
    final path = options.path;
    final status = statusCode?.toString() ?? 'ERR';
    final icon = isError ? '✗' : '✓';

    debugPrint('[API] $icon $method $path → $status (${duration}ms)');
  }
}
