import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// GoRoute의 pageBuilder를 위한 헬퍼 함수
///
/// query parameter에 modal=true가 있으면 fullscreenDialog로 표시
/// query parameter에 trans=fade 등이 있으면 해당 트랜지션 적용
Page<dynamic> buildPage(
  BuildContext context,
  GoRouterState state, {
  required Widget child,
}) {
  var isModal = state.uri.queryParameters['modal'] == 'true';
  var transition = state.uri.queryParameters['trans'];

  // 트랜지션 처리
  if (transition != null) {
    return CustomTransitionPage<dynamic>(
      key: state.pageKey,
      child: child,
      fullscreenDialog: isModal,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        switch (transition) {
          case 'fade':
            return FadeTransition(opacity: animation, child: child);
          case 'slideUp':
            return SlideTransition(
              position:
                  Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                      .animate(animation),
              child: child,
            );
          case 'slideDown':
            return SlideTransition(
              position:
                  Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
                      .animate(animation),
              child: child,
            );
          default:
            return child;
        }
      },
    );
  }

  return MaterialPage<dynamic>(
    key: state.pageKey,
    child: child,
    fullscreenDialog: isModal,
  );
}
