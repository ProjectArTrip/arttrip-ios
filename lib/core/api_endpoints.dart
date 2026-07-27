/// API 엔드포인트 경로 상수
///
/// 모든 API 경로는 이 클래스에서 관리합니다.
/// 동적 경로 파라미터가 있는 경우 static 메서드로 제공합니다.
class ApiEndpoints {
  const ApiEndpoints._();

  // ─── Auth ───
  static const authSocial = '/auth/social';
  static const authReissue = '/auth/app/reissue';
  static const authLogout = '/auth/app/logout';
  static const authWithdraw = '/auth/withdraw';
  static const authLogin = '/auth/login';
  static const authLoginTest = '/auth/login/test';
  static const authRegister = '/auth/register';
  static const authRefresh = '/auth/refresh';
  static const health = '/health';
  static const maintenance = '/maintenance';

  // ─── Exhibits ───
  static const exhibits = '/exhibits';
  static const exhibitsOverseas = '/exhibits/overseas';
  static const exhibitsDomestic = '/exhibits/domestic';
  static const exhibitsGenre = '/exhibits/genre';
  static String exhibitsDetail(int exhibitId) => '/exhibits/$exhibitId';

  // ─── Home ───
  static const homeExhibitsToday = '/home/exhibits/today';
  static const homeExhibitsGenres = '/home/exhibits/genres';
  static const homeExhibitsPersonalized = '/home/exhibits/personalized';
  static const homeExhibitsSchedule = '/home/exhibits/schedule';

  // ─── Reviews ───
  static const reviewsAll = '/reviews/all';
  static String reviewsByExhibit(int exhibitId) =>
      '/reviews/exhibit/$exhibitId';
  static String reviewsCreate(int exhibitId) => '/reviews/$exhibitId';
  static String reviewsById(int reviewId) => '/reviews/$reviewId';

  // ─── Favorites ───
  static String favorites(int exhibitId) => '/favorites/$exhibitId';

  // ─── Me ───
  static const me = '/me';
  static const meImage = '/me/image';
  static const meRecentExhibits = '/me/recent-exhibits';
  static const mePushEnabled = '/me/push-enabled';

  // ─── Keywords ───
  static const keywordAll = '/keyword/all';
  static const keyword = '/keyword';
  static const keywordRecommand = '/keyword/recommand';

  // ─── Map ───
  static const mapMarkers = '/map/exhibits/markers';
  static const mapCluster = '/map/cluster';

  // ─── Search ───
  static const searchHistory = '/search-history';
  static String searchHistoryById(int id) => '/search-history/$id';
}
