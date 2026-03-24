import 'package:arttrip/features/exhibit/data/models/write_review_params.dart';
import 'package:arttrip/features/exhibit/views/exhibit_detail_page.dart';
import 'package:arttrip/features/exhibit/views/write_review_page.dart';
import 'package:arttrip/features/home/regional_exhibits_page.dart';
import 'package:arttrip/features/login/login_page.dart';
import 'package:arttrip/features/my/data/models/user_profile_model.dart';
import 'package:arttrip/features/my/views/edit_profile_page.dart';
import 'package:arttrip/features/my/views/my_reviews_page.dart';
import 'package:arttrip/features/my/views/recent_exhibits_page.dart';
import 'package:arttrip/features/my/views/settings_page.dart';
import 'package:arttrip/features/onboarding/views/keywords_page.dart';
import 'package:arttrip/features/search/views/search_page.dart';
import 'package:arttrip/features/splash/views/splash_view.dart';
import 'package:arttrip/routes/app_routes.dart';
import 'package:arttrip/routes/main_shell_route.dart';
import 'package:arttrip/routes/route_builder.dart';
import 'package:arttrip/routes/route_params.dart';
import 'package:arttrip/shared/pages/alerts_page.dart';
import 'package:arttrip/shared/pages/webview_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 앱 라우터 정의
///
/// 모든 라우트를 조합하여 GoRouter 인스턴스 생성

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: kDebugMode,
  extraCodec: const ExtraCodec(),
  routes: [
    // 메인 GNB 탭 라우트 (/, /map, /stamp, /storage, /my)
    mainShellRoute,

    // 스플래시 화면 (인증 상태 체크)
    GoRoute(
      path: AppRoutes.splash,
      pageBuilder: (context, state) {
        return buildPage(context, state, child: const SplashView());
      },
    ),

    // 로그인 화면
    GoRoute(
      path: AppRoutes.login,
      pageBuilder: (context, state) {
        return buildPage(context, state, child: const LoginPage());
      },
    ),

    // 온보딩 - 관심 키워드 선택
    GoRoute(
      path: AppRoutes.onboardingKeywords,
      pageBuilder: (context, state) {
        return buildPage(context, state, child: const KeywordModelsPage());
      },
    ),

    // 리뷰 작성 페이지 (모달)
    GoRoute(
      path: AppRoutes.exhibitWriteReview,
      pageBuilder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        final params = state.extra as WriteReviewParams;
        return buildPage(
          context,
          state,
          child: WriteReviewPage(exhibitId: id, params: params),
        );
      },
    ),

    // 리뷰 수정 페이지 (모달)
    GoRoute(
      path: AppRoutes.reviewEdit,
      pageBuilder: (context, state) {
        final params = state.extra as WriteReviewParams;
        return buildPage(
          context,
          state,
          child: WriteReviewPage(params: params),
        );
      },
    ),

    // 전시 상세 페이지
    GoRoute(
      path: AppRoutes.exhibit,
      pageBuilder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return buildPage(
          context,
          state,
          child: ExhibitDetailModelPage(exhibitId: id),
        );
      },
    ),

    // 홈 > 국내전시 > 지역별 전체 화면
    GoRoute(
      path: AppRoutes.homeRegion,
      pageBuilder: (context, state) {
        final regionName = state.pathParameters['regionName']!;
        return buildPage(
          context,
          state,
          child: RegionalExhibitsPage(regionName),
        );
      },
    ),

    // 검색 페이지
    GoRoute(
      path: AppRoutes.search,
      pageBuilder: (context, state) {
        return buildPage(context, state, child: const SearchPage());
      },
    ),

    // 알림 리스트 화면
    GoRoute(
      path: AppRoutes.alerts,
      pageBuilder: (context, state) {
        return buildPage(context, state, child: const AlertsPage());
      },
    ),

    // 내 정보 수정 페이지
    GoRoute(
      path: AppRoutes.myEditProfile,
      pageBuilder: (context, state) {
        final profile = state.extra as UserProfileModel;
        return buildPage(
          context,
          state,
          child: EditProfilePage(profile: profile),
        );
      },
    ),

    // 설정 페이지
    GoRoute(
      path: AppRoutes.mySettings,
      pageBuilder: (context, state) {
        return buildPage(context, state, child: const SettingsPage());
      },
    ),

    // 나의 취향 분석 페이지
    GoRoute(
      path: AppRoutes.myTasteAnalysis,
      pageBuilder: (context, state) {
        return buildPage(
          context,
          state,
          child: const KeywordModelsPage(isEditMode: true),
        );
      },
    ),

    // 최근 본 전시 페이지
    GoRoute(
      path: AppRoutes.myRecentExhibits,
      pageBuilder: (context, state) {
        return buildPage(context, state, child: const RecentExhibitsPage());
      },
    ),

    // 나의 리뷰 페이지
    GoRoute(
      path: AppRoutes.myReviews,
      pageBuilder: (context, state) {
        return buildPage(context, state, child: const MyReviewsPage());
      },
    ),

    // WebView 페이지 (개인정보 처리방침, 서비스 이용약관 등)
    GoRoute(
      path: AppRoutes.webview,
      pageBuilder: (context, state) {
        final params = state.extra as WebViewParams;
        return buildPage(
          context,
          state,
          child: WebViewPage(title: params.title, url: params.url),
        );
      },
    ),
  ],
);

extension GoRouterX on BuildContext {
  String get currentUri => GoRouter.of(this).state.uri.toString();
}
