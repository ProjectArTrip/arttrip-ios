import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

/// API 공통 응답 래퍼
///
/// 서버의 모든 응답이 이 형식을 따름:
/// - isSuccess: 성공 여부
/// - code: 응답 코드 (에러 코드 포함)
/// - message: 응답 메시지
/// - result: 실제 데이터 (nullable)
@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  const ApiResponse({
    required this.isSuccess,
    required this.code,
    required this.message,
    this.result,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$ApiResponseFromJson(json, fromJsonT);

  final bool isSuccess;
  final String code;
  final String message;
  final T? result;

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);
}
