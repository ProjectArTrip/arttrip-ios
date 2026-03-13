import 'package:arttrip/core/network/api_result.dart';
import 'package:arttrip/core/network/interceptors/auth_interceptor.dart';
import 'package:arttrip/core/network/interceptors/error_interceptor.dart';
import 'package:arttrip/core/network/interceptors/logging_interceptor.dart';
import 'package:arttrip/core/network/interceptors/retry_interceptor.dart';
import 'package:arttrip/core/network/network_exceptions.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Dio 클라이언트 설정 옵션
class DioClientOptions {
  const DioClientOptions({
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 30),
    this.enableLogging = true,
    this.enableRetry = true,
    this.maxRetries = 3,
    this.headers = const {},
  });

  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;
  final bool enableLogging;
  final bool enableRetry;
  final int maxRetries;
  final Map<String, dynamic> headers;
}

/// Dio HTTP 클라이언트 싱글톤
///
/// 기능:
/// - 싱글톤 패턴으로 전역 인스턴스 관리
/// - 인터셉터 자동 설정 (로깅, 에러 핸들링, 재시도, 인증)
/// - 타입 안전한 API 호출 메서드 제공
/// - ApiResult로 결과 래핑
class DioClient {
  DioClient._internal();

  static final DioClient _instance = DioClient._internal();

  /// 싱글톤 인스턴스 반환
  static DioClient get instance => _instance;

  /// 싱글톤 인스턴스 반환 (짧은 별칭)
  static DioClient get I => _instance;

  late Dio _dio;
  bool _isInitialized = false;

  /// Dio 인스턴스 직접 접근 (고급 사용자용)
  Dio get dio {
    _checkInitialized();
    return _dio;
  }

  /// 초기화 여부 확인
  bool get isInitialized => _isInitialized;

  /// 클라이언트 초기화
  ///
  /// 앱 시작 시 한 번만 호출
  void initialize({
    required DioClientOptions options,
    AuthInterceptor? authInterceptor,
    List<Interceptor>? customInterceptors,
  }) {
    if (_isInitialized) {
      debugPrint('DioClient is already initialized');
      return;
    }

    _dio = Dio(
      BaseOptions(
        baseUrl: options.baseUrl,
        connectTimeout: options.connectTimeout,
        receiveTimeout: options.receiveTimeout,
        sendTimeout: options.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          ...options.headers,
        },
        // 2xx만 성공으로 처리, 나머지는 DioException 발생
        validateStatus:
            (status) => status != null && status >= 200 && status < 300,
      ),
    );

    // 인터셉터 순서가 중요!
    // 1. 인증 (토큰 추가) - 먼저 실행되어야 로그에 토큰이 포함됨
    // 2. 로깅 (요청/응답 로그)
    // 3. 재시도 (실패 시 재요청)
    // 4. 에러 핸들링 (최종 에러 변환)

    // 인증 인터셉터 (먼저 추가)
    if (authInterceptor != null) {
      _dio.interceptors.add(authInterceptor);
    }

    // 로깅 인터셉터 (디버그 모드에서만)
    if (options.enableLogging && kDebugMode) {
      _dio.interceptors.add(LoggingInterceptor(enableRequestBody: true));
    }

    // 재시도 인터셉터
    if (options.enableRetry) {
      _dio.interceptors.add(
        RetryInterceptor(dio: _dio, maxRetries: options.maxRetries),
      );
    }

    // 커스텀 인터셉터
    if (customInterceptors != null) {
      _dio.interceptors.addAll(customInterceptors);
    }

    // 에러 핸들링 인터셉터 (마지막에 추가)
    _dio.interceptors.add(
      ErrorInterceptor(enableLogging: options.enableLogging && kDebugMode),
    );

    _isInitialized = true;
    debugPrint('DioClient initialized with baseUrl: ${options.baseUrl}');
  }

  /// 초기화 확인
  void _checkInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'DioClient is not initialized. Call initialize() first.',
      );
    }
  }

  // ========================================
  // HTTP 메서드 - ApiResult로 래핑
  // ========================================

  /// GET 요청
  Future<ApiResult<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(Object? data)? fromJson,
  }) async {
    return _safeCall<T>(
      () => _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
      fromJson: fromJson,
    );
  }

  /// POST 요청
  Future<ApiResult<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(Object? data)? fromJson,
  }) async {
    return _safeCall<T>(
      () => _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
      fromJson: fromJson,
    );
  }

  /// PUT 요청
  Future<ApiResult<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(Object? data)? fromJson,
  }) async {
    return _safeCall<T>(
      () => _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
      fromJson: fromJson,
    );
  }

  /// PATCH 요청
  Future<ApiResult<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(Object? data)? fromJson,
  }) async {
    return _safeCall<T>(
      () => _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
      fromJson: fromJson,
    );
  }

  /// DELETE 요청
  Future<ApiResult<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(Object? data)? fromJson,
  }) async {
    return _safeCall<T>(
      () => _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
      fromJson: fromJson,
    );
  }

  /// 파일 업로드 (multipart/form-data)
  Future<ApiResult<T>> upload<T>(
    String path, {
    required FormData formData,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int sent, int total)? onSendProgress,
    T Function(Object? data)? fromJson,
  }) async {
    return _safeCall<T>(
      () => _dio.post(
        path,
        data: formData,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      ),
      fromJson: fromJson,
    );
  }

  /// 파일 다운로드
  Future<ApiResult<String>> download(
    String url,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int received, int total)? onReceiveProgress,
  }) async {
    _checkInitialized();

    try {
      await _dio.download(
        url,
        savePath,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return ApiResult.success(savePath);
    } on DioException catch (e) {
      var exception = _extractNetworkException(e);
      return ApiResult.failure(exception);
    } catch (e) {
      return ApiResult.failure(
        NetworkException.unexpected(message: e.toString()),
      );
    }
  }

  // ========================================
  // 유틸리티 메서드
  // ========================================

  /// 안전한 API 호출 래퍼
  Future<ApiResult<T>> _safeCall<T>(
    Future<Response<Object?>> Function() call, {
    T Function(Object? data)? fromJson,
  }) async {
    _checkInitialized();

    try {
      var response = await call();
      var data = response.data;

      // fromJson이 제공된 경우 변환
      if (fromJson != null) {
        return ApiResult.success(fromJson(data));
      }

      // T가 dynamic이거나 변환이 필요 없는 경우
      return ApiResult.success(data as T);
    } on DioException catch (e) {
      var exception = _extractNetworkException(e);
      return ApiResult.failure(exception);
    } catch (e) {
      return ApiResult.failure(
        NetworkException.unexpected(message: e.toString()),
      );
    }
  }

  /// DioException에서 NetworkException 추출
  NetworkException _extractNetworkException(DioException e) {
    // ErrorInterceptor에서 이미 변환한 경우
    if (e.error is NetworkException) {
      return e.error as NetworkException;
    }
    // 변환되지 않은 경우 직접 변환
    return NetworkException.fromDioException(e);
  }

  /// 헤더 추가/업데이트
  void setHeader(String key, String value) {
    _checkInitialized();
    _dio.options.headers[key] = value;
  }

  /// 헤더 제거
  void removeHeader(String key) {
    _checkInitialized();
    _dio.options.headers.remove(key);
  }

  /// 모든 요청 취소
  void cancelAllRequests([CancelToken? cancelToken]) {
    cancelToken?.cancel('Cancelled by user');
  }

  /// 클라이언트 리셋 (테스트용)
  @visibleForTesting
  void reset() {
    _isInitialized = false;
  }
}
