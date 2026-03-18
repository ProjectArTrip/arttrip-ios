import 'package:arttrip/core/network/api_result.dart';
import 'package:arttrip/core/network/dio_client.dart';
import 'package:dio/dio.dart';

/// API 서비스 베이스 클래스
///
/// 모든 API 서비스가 상속받아 사용하는 추상 클래스
/// DioClient를 통해 HTTP 요청을 수행하고 결과를 ApiResult로 반환
abstract class BaseApiService {
  BaseApiService({DioClient? client}) : _client = client ?? DioClient.instance;

  final DioClient _client;

  /// DioClient 인스턴스 접근
  DioClient get client => _client;

  /// GET 요청
  Future<ApiResult<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(Object? data)? fromJson,
  }) {
    return _client.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
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
  }) {
    return _client.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
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
  }) {
    return _client.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
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
  }) {
    return _client.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
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
  }) {
    return _client.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      fromJson: fromJson,
    );
  }

  /// 파일 업로드
  Future<ApiResult<T>> upload<T>(
    String path, {
    required FormData formData,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int sent, int total)? onSendProgress,
    T Function(Object? data)? fromJson,
  }) {
    return _client.upload<T>(
      path,
      formData: formData,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
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
  }) {
    return _client.download(
      url,
      savePath,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// 리스트 데이터 파싱 헬퍼
  List<T> parseList<T>(
    Object? data,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    if (data is List) {
      return data
          .map((item) => fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// 페이지네이션 응답 파싱 헬퍼
  PaginatedResponse<T> parsePaginatedResponse<T>(
    Map<String, dynamic> data,
    T Function(Map<String, dynamic> json) fromJson, {
    String itemsKey = 'items',
    String totalKey = 'total',
    String pageKey = 'page',
    String limitKey = 'limit',
  }) {
    final items = parseList<T>(data[itemsKey], fromJson);
    return PaginatedResponse<T>(
      items: items,
      total: data[totalKey] as int? ?? 0,
      page: data[pageKey] as int? ?? 1,
      limit: data[limitKey] as int? ?? 20,
    );
  }
}

/// 페이지네이션 응답 모델
class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });

  final List<T> items;
  final int total;
  final int page;
  final int limit;

  /// 다음 페이지 존재 여부
  bool get hasNextPage => page * limit < total;

  /// 이전 페이지 존재 여부
  bool get hasPreviousPage => page > 1;

  /// 전체 페이지 수
  int get totalPages => (total / limit).ceil();

  /// 빈 응답 여부
  bool get isEmpty => items.isEmpty;

  /// 데이터 존재 여부
  bool get isNotEmpty => items.isNotEmpty;
}
