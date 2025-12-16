import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 트랜지션 타입
enum TransitionType {
  none,
  fade,
  slideUp,
  slideDown,
}

/// 네비게이션 래퍼 클래스
///
/// go_router의 context extension을 래핑하여 일관된 API 제공
class Routes {
  Routes._();

  /// Push 형식으로 navigate
  ///
  /// [path] 이동할 경로
  /// [params] 쿼리 파라미터 (URL에 포함)
  /// [extra] 복잡한 객체 전달 (메모리 참조)
  /// [replace] true면 현재 화면 교체
  /// [transition] 화면 전환 애니메이션
  static Future<T?> push<T>(
    BuildContext context,
    String path, {
    Map<String, String>? params,
    Object? extra,
    bool replace = false,
    TransitionType transition = TransitionType.none,
  }) {
    var uri = Uri.parse(path);
    var allParams = <String, String>{...uri.queryParameters, ...?params};

    if (transition != TransitionType.none) {
      allParams['trans'] = transition.name;
    }

    var fullPath = allParams.isEmpty
        ? uri.path
        : uri.replace(queryParameters: allParams).toString();

    if (replace) {
      context.pushReplacement(fullPath, extra: extra);
      return Future.value(null);
    }
    return context.push<T>(fullPath, extra: extra);
  }

  /// Modal 형식으로 navigate (하단에서 위로 슬라이드)
  ///
  /// [path] 이동할 경로
  /// [params] 쿼리 파라미터
  /// [extra] 복잡한 객체 전달
  /// [replace] true면 현재 화면 교체
  static Future<T?> modal<T>(
    BuildContext context,
    String path, {
    Map<String, String>? params,
    Object? extra,
    bool replace = false,
  }) {
    var uri = Uri.parse(path);
    var allParams = <String, String>{
      ...uri.queryParameters,
      ...?params,
      'modal': 'true',
    };

    var fullPath = uri.replace(queryParameters: allParams).toString();

    if (replace) {
      context.pushReplacement(fullPath, extra: extra);
      return Future.value(null);
    }
    return context.push<T>(fullPath, extra: extra);
  }

  /// Fade 형식으로 replace
  static Future<void> replace(
    BuildContext context,
    String path, {
    Map<String, String>? params,
    Object? extra,
    bool isModal = false,
  }) {
    var uri = Uri.parse(path);
    var allParams = <String, String>{
      ...uri.queryParameters,
      ...?params,
      'trans': TransitionType.fade.name,
      if (isModal) 'modal': 'true',
    };

    var fullPath = uri.replace(queryParameters: allParams).toString();
    context.pushReplacement(fullPath, extra: extra);
    return Future.value();
  }

  /// 모든 스택을 제거하고 새 경로로 이동 (로그아웃, 초기화 등)
  ///
  /// Navigator 1.0의 pushNamedAndRemoveUntil과 동일한 동작:
  /// - 스택에 있는 모든 라우트를 제거
  static void go(
    BuildContext context,
    String path, {
    Map<String, String>? params,
    Object? extra,
  }) {
    var uri = Uri.parse(path);
    var allParams = <String, String>{...uri.queryParameters, ...?params};
    var fullPath = allParams.isEmpty
        ? uri.path
        : uri.replace(queryParameters: allParams).toString();

    context.go(fullPath, extra: extra);
  }
}
