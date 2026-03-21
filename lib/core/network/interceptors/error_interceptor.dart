import 'package:arttrip/core/network/network_exceptions.dart';
import 'package:dio/dio.dart';

/// DioException을 NetworkException으로 변환하는 인터셉터
///
/// 기능:
/// - 모든 DioException을 NetworkException으로 통일
/// - 에러 로깅 (디버그 모드)
/// - 에러 발생 시 콜백 호출 (선택적)
class ErrorInterceptor extends Interceptor {
  ErrorInterceptor({this.onErrorCallback, this.enableLogging = true});

  /// 에러 발생 시 호출되는 콜백
  final void Function(NetworkException exception)? onErrorCallback;

  /// 에러 로깅 활성화 여부
  final bool enableLogging;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final networkException = NetworkException.fromDioException(err);

    if (enableLogging) {
      _logError(err, networkException);
    }

    onErrorCallback?.call(networkException);

    // NetworkException을 DioException으로 감싸서 전달
    // 이렇게 하면 상위 레이어에서 NetworkException을 추출할 수 있음
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: networkException,
      ),
    );
  }

  void _logError(DioException err, NetworkException networkException) {
    final buffer = StringBuffer();
    buffer.writeln(
      '╔══════════════════════════════════════════════════════════',
    );
    buffer.writeln('║ ❌ NETWORK ERROR');
    buffer.writeln(
      '╠══════════════════════════════════════════════════════════',
    );
    buffer.writeln('║ URL: ${err.requestOptions.uri}');
    buffer.writeln('║ Method: ${err.requestOptions.method}');
    buffer.writeln('║ Status Code: ${err.response?.statusCode ?? 'N/A'}');
    buffer.writeln('║ Error Type: ${networkException.runtimeType}');
    buffer.writeln('║ Message: ${networkException.message}');

    if (err.response?.data != null) {
      buffer.writeln('║ Response Data: ${err.response?.data}');
    }

    // 실제 에러 원인 출력
    if (err.error != null) {
      buffer.writeln('║ Original Error: ${err.error}');
    }
    if (err.message != null) {
      buffer.writeln('║ Dio Message: ${err.message}');
    }

    buffer.writeln(
      '╚══════════════════════════════════════════════════════════',
    );

    // ignore: avoid_print
    print(buffer.toString());
  }
}
