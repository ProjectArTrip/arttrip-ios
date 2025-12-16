import 'package:arttrip/core/network/network_exceptions.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_result.freezed.dart';

/// API 호출 결과를 나타내는 sealed class
/// Success와 Failure 두 가지 상태를 타입 안전하게 처리
@freezed
sealed class ApiResult<T> with _$ApiResult<T> {
  const ApiResult._();

  /// 성공 결과 생성
  const factory ApiResult.success(T data) = ApiSuccess<T>;

  /// 실패 결과 생성
  const factory ApiResult.failure(NetworkException exception) = ApiFailure<T>;

  /// 결과가 성공인지 확인
  bool get isSuccess => this is ApiSuccess<T>;

  /// 결과가 실패인지 확인
  bool get isFailure => this is ApiFailure<T>;

  /// 성공 시 데이터 반환, 실패 시 null
  T? get dataOrNull => switch (this) {
    ApiSuccess<T>(:var data) => data,
    ApiFailure<T>() => null,
  };

  /// 결과에 따라 콜백 실행
  R when<R>({
    required R Function(T data) success,
    required R Function(NetworkException exception) failure,
  }) {
    return switch (this) {
      ApiSuccess<T>(:var data) => success(data),
      ApiFailure<T>(:var exception) => failure(exception),
    };
  }
}
