class AppRoutes {
  AppRoutes._();

  static const splash = '/splash';

  static const login = '/login';

  static const onboarding = '/onboarding';

  static const onboardingKeywords = '$onboarding/keywords';
  static const onboardingProfile = '$onboarding/profile';

  /// 전시 리뷰 작성 페이지 (모달)
  static const exhibitWriteReview = '/exhibit/write-review/:id';
  static String exhibitWriteReviewPath(int id) => '/exhibit/write-review/$id';

  /// 리뷰 수정 페이지 (모달)
  static const reviewEdit = '/review/edit/:reviewId';
  static String reviewEditPath(String reviewId) => '/review/edit/$reviewId';

  /// 전시 상세 페이지
  static const exhibit = '/exhibit/:id';
  static String exhibitPath(int? id) => '/exhibit/$id';

  /// 홈 > 국내전시 > 지역별 전체 화면
  static const homeRegion = '/home/:regionName';
  static String homeRegionPath(String regionName) => '/home/$regionName';

  /// 검색 페이지
  static const search = '/search';

  /// 알림 리스트 화면
  static const alerts = '/alerts';

  /// 내 정보 수정 페이지
  static const myEditProfile = '/my/edit-profile';

  /// 설정 페이지
  static const mySettings = '/my/settings';

  /// 나의 취향 분석 페이지
  static const myTasteAnalysis = '/my/taste-analysis';

  /// 최근 본 전시 페이지
  static const myRecentExhibits = '/my/recent-exhibits';

  /// 나의 리뷰 페이지
  static const myReviews = '/my/reviews';

  /// WebView 페이지 (개인정보 처리방침, 서비스 이용약관 등)
  static const webview = '/webview';
}
