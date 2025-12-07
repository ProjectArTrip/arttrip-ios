import 'package:arttrip/core/network/network_exceptions.dart';

/// API 호출 결과를 나타내는 sealed class
/// Success와 Failure 두 가지 상태를 타입 안전하게 처리
sealed class ApiResult<T> {
  const ApiResult();

  /// 성공 결과 생성
  factory ApiResult.success(T data) = ApiSuccess<T>;

  /// 실패 결과 생성
  factory ApiResult.failure(NetworkException exception) = ApiFailure<T>;

  /// 결과가 성공인지 확인
  bool get isSuccess => this is ApiSuccess<T>;

  /// 결과가 실패인지 확인
  bool get isFailure => this is ApiFailure<T>;

  /// 성공 시 데이터 반환, 실패 시 null
  T? get dataOrNull => switch (this) {
        ApiSuccess<T> s => s.data,
        ApiFailure<T>() => null,
      };

  /// 실패 시 예외 반환, 성공 시 null
  NetworkException? get exceptionOrNull => switch (this) {
        ApiSuccess<T>() => null,
        ApiFailure<T> f => f.exception,
      };

  /// 결과에 따라 콜백 실행
  R when<R>({
    required R Function(T data) success,
    required R Function(NetworkException exception) failure,
  }) {
    return switch (this) {
      ApiSuccess<T> s => success(s.data),
      ApiFailure<T> f => failure(f.exception),
    };
  }

  /// 결과에 따라 콜백 실행 (nullable 버전)
  R? whenOrNull<R>({
    R Function(T data)? success,
    R Function(NetworkException exception)? failure,
  }) {
    return switch (this) {
      ApiSuccess<T> s => success?.call(s.data),
      ApiFailure<T> f => failure?.call(f.exception),
    };
  }

  /// 성공 데이터 변환
  ApiResult<R> map<R>(R Function(T data) transform) {
    return switch (this) {
      ApiSuccess<T> s => ApiResult.success(transform(s.data)),
      ApiFailure<T> f => ApiResult.failure(f.exception),
    };
  }

  /// 성공 데이터를 다른 ApiResult로 변환
  ApiResult<R> flatMap<R>(ApiResult<R> Function(T data) transform) {
    return switch (this) {
      ApiSuccess<T> s => transform(s.data),
      ApiFailure<T> f => ApiResult.failure(f.exception),
    };
  }

  /// 성공 시 데이터 반환, 실패 시 기본값 반환
  T getOrElse(T Function() orElse) {
    return switch (this) {
      ApiSuccess<T> s => s.data,
      ApiFailure<T>() => orElse(),
    };
  }

  /// 성공 시 데이터 반환, 실패 시 예외 throw
  T getOrThrow() {
    return switch (this) {
      ApiSuccess<T> s => s.data,
      ApiFailure<T> f => throw f.exception,
    };
  }
}

/// 성공 결과
final class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess(this.data);

  final T data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ApiSuccess<T> && runtimeType == other.runtimeType && data == other.data;

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'ApiSuccess(data: $data)';
}

/// 실패 결과
final class ApiFailure<T> extends ApiResult<T> {
  const ApiFailure(this.exception);

  final NetworkException exception;

  /// 에러 메시지 반환
  String get message => exception.message;

  /// HTTP 상태 코드 반환
  int? get statusCode => exception.statusCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiFailure<T> && runtimeType == other.runtimeType && exception == other.exception;

  @override
  int get hashCode => exception.hashCode;

  @override
  String toString() => 'ApiFailure(exception: $exception)';
}

/// ApiResult 확장 메서드
extension ApiResultExtension<T> on Future<ApiResult<T>> {
  /// `Future<ApiResult>`에서 성공 시 데이터 변환
  Future<ApiResult<R>> mapSuccess<R>(R Function(T data) transform) async {
    var result = await this;
    return result.map(transform);
  }

  /// `Future<ApiResult>`에서 성공 시 다른 ApiResult로 변환
  Future<ApiResult<R>> flatMapSuccess<R>(
    ApiResult<R> Function(T data) transform,
  ) async {
    var result = await this;
    return result.flatMap(transform);
  }
}
