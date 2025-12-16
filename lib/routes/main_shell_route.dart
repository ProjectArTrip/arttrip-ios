import 'package:arttrip/features/home/home_page.dart';
import 'package:arttrip/features/map/view/map_view.dart';
import 'package:arttrip/features/my/view/my_view.dart';
import 'package:arttrip/features/stamp/view/stamp_view.dart';
import 'package:arttrip/features/storage/view/storage_view.dart';
import 'package:arttrip/routes/route_builder.dart';
import 'package:arttrip/shared/widgets/main_shell.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 메인 GNB 탭 라우트
///
/// StatefulShellRoute를 사용하여 탭별 상태 유지
/// - /: 홈
/// - /map: 지도
/// - /stamp: 스탬프
/// - /storage: 보관함
/// - /my: 마이페이지
final mainShellRoute = StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) {
    return MainShell(navigationShell: navigationShell);
  },
  branches: [
    // 홈 탭 (index: 0)
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) {
            // Routes.go() 호출 시 extra로 타임스탬프가 전달되면 강제 재생성
            var pageKey =
                state.extra != null ? ValueKey(state.extra) : state.pageKey;
            return MaterialPage<dynamic>(key: pageKey, child: const HomePage());
          },
        ),
      ],
    ),

    // 지도 탭 (index: 1)
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: '/map',
          pageBuilder: (context, state) {
            return buildPage(context, state, child: const MapView());
          },
        ),
      ],
    ),

    // 스탬프 탭 (index: 2)
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: '/stamp',
          pageBuilder: (context, state) {
            return buildPage(context, state, child: const StampView());
          },
        ),
      ],
    ),

    // 보관함 탭 (index: 3)
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: '/storage',
          pageBuilder: (context, state) {
            return buildPage(context, state, child: const StorageView());
          },
        ),
      ],
    ),

    // My 탭 (index: 4)
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: '/my',
          pageBuilder: (context, state) {
            return buildPage(context, state, child: const MyView());
          },
        ),
      ],
    ),
  ],
);
