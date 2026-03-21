import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';

/// 실패한 요청을 자동으로 재시도하는 인터셉터
///
/// 기능:
/// - 지수 백오프(Exponential Backoff) 전략으로 재시도
/// - 재시도 가능한 에러 타입만 선별적으로 처리
/// - 최대 재시도 횟수 제한
/// - 재시도 간 지연 시간 설정
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.retryDelays = const [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 4),
    ],
    this.retryableStatusCodes = const [408, 429, 500, 502, 503, 504],
    this.useExponentialBackoff = true,
  });

  /// Dio 인스턴스 (재요청에 사용)
  final Dio dio;

  /// 최대 재시도 횟수
  final int maxRetries;

  /// 재시도 간 지연 시간 목록
  final List<Duration> retryDelays;

  /// 재시도 가능한 HTTP 상태 코드
  final List<int> retryableStatusCodes;

  /// 지수 백오프 사용 여부
  final bool useExponentialBackoff;

  /// 재시도 횟수 추적을 위한 헤더 키
  static const _retryCountHeader = 'x-retry-count';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final requestOptions = err.requestOptions;

    // 현재 재시도 횟수 확인
    final retryCount = _getRetryCount(requestOptions);

    // 재시도 가능 여부 확인
    if (!_shouldRetry(err, retryCount)) {
      return handler.next(err);
    }

    // 재시도 전 대기
    final delay = _getDelay(retryCount);
    await Future.delayed(delay);

    // 재시도 횟수 증가
    _setRetryCount(requestOptions, retryCount + 1);

    try {
      // 요청 재시도
      final response = await dio.fetch(requestOptions);
      return handler.resolve(response);
    } on DioException catch (e) {
      // 재시도도 실패하면 다시 onError로 전달
      return handler.reject(e);
    }
  }

  /// 재시도 가능 여부 확인
  bool _shouldRetry(DioException err, int retryCount) {
    // 최대 재시도 횟수 초과
    if (retryCount >= maxRetries) {
      return false;
    }

    // 요청 취소는 재시도하지 않음
    if (err.type == DioExceptionType.cancel) {
      return false;
    }

    // 재시도하지 않을 경로
    if (_isNoRetryPath(err.requestOptions.path)) {
      return false;
    }

    // 타임아웃 에러는 재시도
    if (_isTimeoutError(err)) {
      return true;
    }

    // 연결 에러는 재시도
    if (err.type == DioExceptionType.connectionError) {
      return true;
    }

    // 재시도 가능한 상태 코드인지 확인
    final statusCode = err.response?.statusCode;
    if (statusCode != null && retryableStatusCodes.contains(statusCode)) {
      return true;
    }

    return false;
  }

  /// 재시도하지 않을 경로인지 확인
  bool _isNoRetryPath(String path) {
    const noRetryPaths = ['/auth/app/logout', '/auth/social'];
    return noRetryPaths.any((p) => path.contains(p));
  }

  /// 타임아웃 에러인지 확인
  bool _isTimeoutError(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout;
  }

  /// 재시도 전 대기 시간 계산
  Duration _getDelay(int retryCount) {
    if (useExponentialBackoff) {
      // 지수 백오프: baseDelay * 2^retryCount + 랜덤 지터
      final baseDelay =
          retryDelays.isNotEmpty
              ? retryDelays.first
              : const Duration(seconds: 1);
      final exponentialDelay = baseDelay * pow(2, retryCount);
      final jitter = Duration(milliseconds: Random().nextInt(1000));
      return exponentialDelay + jitter;
    }

    // 고정 지연 시간
    if (retryCount < retryDelays.length) {
      return retryDelays[retryCount];
    }

    return retryDelays.isNotEmpty
        ? retryDelays.last
        : const Duration(seconds: 1);
  }

  /// 현재 재시도 횟수 조회
  int _getRetryCount(RequestOptions options) {
    final retryCount = options.headers[_retryCountHeader];
    if (retryCount is int) return retryCount;
    return 0;
  }

  /// 재시도 횟수 설정
  void _setRetryCount(RequestOptions options, int count) {
    options.headers[_retryCountHeader] = count;
  }
}
