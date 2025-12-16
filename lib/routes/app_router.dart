import 'package:arttrip/features/exhibit/view/exhibit_detail_page.dart';
import 'package:arttrip/features/login/login_page.dart';
import 'package:arttrip/features/onboarding/view/keywords_page.dart';
import 'package:arttrip/features/splash/view/splash_view.dart';
import 'package:arttrip/routes/main_shell_route.dart';
import 'package:arttrip/routes/route_builder.dart';
import 'package:arttrip/routes/route_params.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

/// 앱 라우터 정의
///
/// 모든 라우트를 조합하여 GoRouter 인스턴스 생성

final appRouter = GoRouter(
  initialLocation: '/splash',
  debugLogDiagnostics: kDebugMode,
  extraCodec: const ExtraCodec(),
  routes: [
    // 메인 GNB 탭 라우트 (/, /map, /stamp, /storage, /my)
    mainShellRoute,

    // 스플래시 화면 (인증 상태 체크)
    GoRoute(
      path: '/splash',
      pageBuilder: (context, state) {
        return buildPage(context, state, child: const SplashView());
      },
    ),

    // 로그인 화면
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) {
        return buildPage(context, state, child: const LoginPage());
      },
    ),

    // 온보딩 - 관심 키워드 선택
    GoRoute(
      path: '/onboarding/keywords',
      pageBuilder: (context, state) {
        return buildPage(context, state, child: const KeywordsPage());
      },
    ),

    // 전시 상세 페이지
    GoRoute(
      path: '/exhibit/:id',
      pageBuilder: (context, state) {
        var id = int.parse(state.pathParameters['id']!);
        return buildPage(context, state, child: ExhibitDetailPage(exhibitId: id));
      },
    ),
  ],
);
