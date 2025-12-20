class AppAssets {
  AppAssets._();

  // SVG Icons
  static const String icHome = 'assets/svg/ic_home.svg';
  static const String icLocation = 'assets/svg/ic_location.svg';
  static const String icLocation2 = 'assets/svg/ic_location2.svg';
  static const String icStamp = 'assets/svg/ic_stamp.svg';
  static const String icSave = 'assets/svg/ic_save.svg';
  static const String icMy = 'assets/svg/ic_my.svg';
  static const String icKakao = 'assets/svg/ic_kakao.svg';
  static const String icApple = 'assets/svg/ic_apple.svg';
  static const String icGoogle = 'assets/svg/ic_google.svg';
  static const String icNotification = 'assets/svg/ic_notification.svg';
  static const String icCalendar = 'assets/svg/ic_calendar.svg';
  static const String icSearch = 'assets/svg/ic_search.svg';
  static const String icPhone = 'assets/svg/ic_phone.svg';
  static const String icTime = 'assets/svg/ic_time.svg';
  static String icLikeCircle({required bool isLiked}) =>
      isLiked
          ? 'assets/svg/ic_like_circle_selected.svg'
          : 'assets/svg/ic_like_circle_default.svg';
  static const String icNoArrowRight = 'assets/svg/ic_no_arrow_right.svg';

  // Logo
  static const String icLogoWhite = 'assets/svg/ic_logo_white.svg';
  static const String icLogoBlack = 'assets/svg/ic_logo_black.svg';
}
