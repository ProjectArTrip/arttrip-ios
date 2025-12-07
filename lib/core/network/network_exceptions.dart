// ignore_for_file: sort_constructors_first

import 'dart:io';

import 'package:dio/dio.dart';

/// 네트워크 예외를 나타내는 sealed class
/// 모든 네트워크 관련 에러를 타입 안전하게 처리
sealed class NetworkException implements Exception {
  const NetworkException({
    required this.message,
    this.statusCode,
    this.data,
  });

  final String message;
  final int? statusCode;
  final Object? data;

  /// DioException을 NetworkException으로 변환
  factory NetworkException.fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return NetworkException.connectionTimeout(
          message: '서버 연결 시간이 초과되었습니다',
        );

      case DioExceptionType.sendTimeout:
        return NetworkException.sendTimeout(
          message: '요청 전송 시간이 초과되었습니다',
        );

      case DioExceptionType.receiveTimeout:
        return NetworkException.receiveTimeout(
          message: '응답 수신 시간이 초과되었습니다',
        );

      case DioExceptionType.badCertificate:
        return NetworkException.badCertificate(
          message: '보안 인증서가 유효하지 않습니다',
        );

      case DioExceptionType.badResponse:
        return NetworkException.fromStatusCode(
          statusCode: error.response?.statusCode,
          data: error.response?.data,
        );

      case DioExceptionType.cancel:
        return NetworkException.requestCancelled(
          message: '요청이 취소되었습니다',
        );

      case DioExceptionType.connectionError:
        return NetworkException.noInternetConnection(
          message: '인터넷 연결을 확인해주세요',
        );

      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return NetworkException.noInternetConnection(
            message: '인터넷 연결을 확인해주세요',
          );
        }
        return NetworkException.unexpected(
          message: error.message ?? '알 수 없는 오류가 발생했습니다',
        );
    }
  }

  /// HTTP 상태 코드에 따른 예외 생성
  factory NetworkException.fromStatusCode({
    int? statusCode,
    Object? data,
  }) {
    var serverMessage = _extractServerMessage(data);

    switch (statusCode) {
      case 400:
        return NetworkException.badRequest(
          message: serverMessage ?? '잘못된 요청입니다',
          statusCode: statusCode,
          data: data,
        );

      case 401:
        return NetworkException.unauthorized(
          message: serverMessage ?? '인증이 필요합니다',
          statusCode: statusCode,
          data: data,
        );

      case 403:
        return NetworkException.forbidden(
          message: serverMessage ?? '접근 권한이 없습니다',
          statusCode: statusCode,
          data: data,
        );

      case 404:
        return NetworkException.notFound(
          message: serverMessage ?? '요청한 리소스를 찾을 수 없습니다',
          statusCode: statusCode,
          data: data,
        );

      case 405:
        return NetworkException.methodNotAllowed(
          message: serverMessage ?? '허용되지 않은 요청 방식입니다',
          statusCode: statusCode,
          data: data,
        );

      case 408:
        return NetworkException.requestTimeout(
          message: serverMessage ?? '요청 시간이 초과되었습니다',
          statusCode: statusCode,
          data: data,
        );

      case 409:
        return NetworkException.conflict(
          message: serverMessage ?? '요청이 충돌했습니다',
          statusCode: statusCode,
          data: data,
        );

      case 422:
        return NetworkException.unprocessableEntity(
          message: serverMessage ?? '처리할 수 없는 요청입니다',
          statusCode: statusCode,
          data: data,
        );

      case 429:
        return NetworkException.tooManyRequests(
          message: serverMessage ?? '너무 많은 요청이 발생했습니다. 잠시 후 다시 시도해주세요',
          statusCode: statusCode,
          data: data,
        );

      case 500:
        return NetworkException.internalServerError(
          message: serverMessage ?? '서버 내부 오류가 발생했습니다',
          statusCode: statusCode,
          data: data,
        );

      case 502:
        return NetworkException.badGateway(
          message: serverMessage ?? '게이트웨이 오류가 발생했습니다',
          statusCode: statusCode,
          data: data,
        );

      case 503:
        return NetworkException.serviceUnavailable(
          message: serverMessage ?? '서비스를 일시적으로 사용할 수 없습니다',
          statusCode: statusCode,
          data: data,
        );

      case 504:
        return NetworkException.gatewayTimeout(
          message: serverMessage ?? '게이트웨이 시간이 초과되었습니다',
          statusCode: statusCode,
          data: data,
        );

      default:
        return NetworkException.unexpected(
          message: serverMessage ?? '알 수 없는 오류가 발생했습니다 (코드: $statusCode)',
          statusCode: statusCode,
          data: data,
        );
    }
  }

  /// 서버 응답에서 에러 메시지 추출
  static String? _extractServerMessage(Object? data) {
    if (data == null) return null;

    if (data is Map<String, dynamic>) {
      // 일반적인 에러 응답 형식들을 처리
      return data['message'] as String? ??
          data['error'] as String? ??
          data['errorMessage'] as String? ??
          data['msg'] as String?;
    }

    if (data is String && data.isNotEmpty) {
      return data;
    }

    return null;
  }

  // === Timeout Exceptions ===

  factory NetworkException.connectionTimeout({required String message}) = ConnectionTimeoutException;

  factory NetworkException.sendTimeout({required String message}) = SendTimeoutException;

  factory NetworkException.receiveTimeout({required String message}) = ReceiveTimeoutException;

  factory NetworkException.requestTimeout({
    required String message,
    int? statusCode,
    Object? data,
  }) = RequestTimeoutException;

  // === Connection Exceptions ===

  factory NetworkException.noInternetConnection({required String message}) = NoInternetConnectionException;

  factory NetworkException.badCertificate({required String message}) = BadCertificateException;

  // === Client Error Exceptions (4xx) ===

  factory NetworkException.badRequest({
    required String message,
    int? statusCode,
    Object? data,
  }) = BadRequestException;

  factory NetworkException.unauthorized({
    required String message,
    int? statusCode,
    Object? data,
  }) = UnauthorizedException;

  factory NetworkException.forbidden({
    required String message,
    int? statusCode,
    Object? data,
  }) = ForbiddenException;

  factory NetworkException.notFound({
    required String message,
    int? statusCode,
    Object? data,
  }) = NotFoundException;

  factory NetworkException.methodNotAllowed({
    required String message,
    int? statusCode,
    Object? data,
  }) = MethodNotAllowedException;

  factory NetworkException.conflict({
    required String message,
    int? statusCode,
    Object? data,
  }) = ConflictException;

  factory NetworkException.unprocessableEntity({
    required String message,
    int? statusCode,
    Object? data,
  }) = UnprocessableEntityException;

  factory NetworkException.tooManyRequests({
    required String message,
    int? statusCode,
    Object? data,
  }) = TooManyRequestsException;

  // === Server Error Exceptions (5xx) ===

  factory NetworkException.internalServerError({
    required String message,
    int? statusCode,
    Object? data,
  }) = InternalServerErrorException;

  factory NetworkException.badGateway({
    required String message,
    int? statusCode,
    Object? data,
  }) = BadGatewayException;

  factory NetworkException.serviceUnavailable({
    required String message,
    int? statusCode,
    Object? data,
  }) = ServiceUnavailableException;

  factory NetworkException.gatewayTimeout({
    required String message,
    int? statusCode,
    Object? data,
  }) = GatewayTimeoutException;

  // === Other Exceptions ===

  factory NetworkException.requestCancelled({required String message}) = RequestCancelledException;

  factory NetworkException.unexpected({
    required String message,
    int? statusCode,
    Object? data,
  }) = UnexpectedException;

  @override
  String toString() => 'NetworkException: $message (statusCode: $statusCode)';
}

// === Timeout Exception Classes ===

final class ConnectionTimeoutException extends NetworkException {
  const ConnectionTimeoutException({required super.message}) : super(statusCode: null, data: null);
}

final class SendTimeoutException extends NetworkException {
  const SendTimeoutException({required super.message}) : super(statusCode: null, data: null);
}

final class ReceiveTimeoutException extends NetworkException {
  const ReceiveTimeoutException({required super.message}) : super(statusCode: null, data: null);
}

final class RequestTimeoutException extends NetworkException {
  const RequestTimeoutException({
    required super.message,
    super.statusCode,
    super.data,
  });
}

// === Connection Exception Classes ===

final class NoInternetConnectionException extends NetworkException {
  const NoInternetConnectionException({required super.message}) : super(statusCode: null, data: null);
}

final class BadCertificateException extends NetworkException {
  const BadCertificateException({required super.message}) : super(statusCode: null, data: null);
}

// === Client Error Exception Classes (4xx) ===

final class BadRequestException extends NetworkException {
  const BadRequestException({
    required super.message,
    super.statusCode,
    super.data,
  });
}

final class UnauthorizedException extends NetworkException {
  const UnauthorizedException({
    required super.message,
    super.statusCode,
    super.data,
  });
}

final class ForbiddenException extends NetworkException {
  const ForbiddenException({
    required super.message,
    super.statusCode,
    super.data,
  });
}

final class NotFoundException extends NetworkException {
  const NotFoundException({
    required super.message,
    super.statusCode,
    super.data,
  });
}

final class MethodNotAllowedException extends NetworkException {
  const MethodNotAllowedException({
    required super.message,
    super.statusCode,
    super.data,
  });
}

final class ConflictException extends NetworkException {
  const ConflictException({
    required super.message,
    super.statusCode,
    super.data,
  });
}

final class UnprocessableEntityException extends NetworkException {
  const UnprocessableEntityException({
    required super.message,
    super.statusCode,
    super.data,
  });
}

final class TooManyRequestsException extends NetworkException {
  const TooManyRequestsException({
    required super.message,
    super.statusCode,
    super.data,
  });
}

// === Server Error Exception Classes (5xx) ===

final class InternalServerErrorException extends NetworkException {
  const InternalServerErrorException({
    required super.message,
    super.statusCode,
    super.data,
  });
}

final class BadGatewayException extends NetworkException {
  const BadGatewayException({
    required super.message,
    super.statusCode,
    super.data,
  });
}

final class ServiceUnavailableException extends NetworkException {
  const ServiceUnavailableException({
    required super.message,
    super.statusCode,
    super.data,
  });
}

final class GatewayTimeoutException extends NetworkException {
  const GatewayTimeoutException({
    required super.message,
    super.statusCode,
    super.data,
  });
}

// === Other Exception Classes ===

final class RequestCancelledException extends NetworkException {
  const RequestCancelledException({required super.message}) : super(statusCode: null, data: null);
}

final class UnexpectedException extends NetworkException {
  const UnexpectedException({
    required super.message,
    super.statusCode,
    super.data,
  });
}
