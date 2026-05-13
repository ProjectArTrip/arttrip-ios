enum AsyncStatus { loading, success, error }

enum FontFamilyType {
  pretendard('Pretendard');

  const FontFamilyType(this.fontName);
  final String fontName;
}

enum ExhibitionStatus {
  upcoming('UPCOMING'), // 예정된 전시
  onGoing('ONGOING'), // 진행 중인 전시
  endingSoon('ENDING_SOON'), // 마감 임박(3일전부터)
  finished('FINISHED'); // 종료된 전시

  const ExhibitionStatus(this.status);
  final String status;
}

enum LocationType { overseas, domestic }

enum SortType {
  latest('LATEST'), // 최신순
  endingSoon('ENDING_SOON'), // 마감순
  popular('POPULAR'), // 인기순
  none('NONE');

  const SortType(this.type);
  final String type;
}

enum OnboardingStep {
  nickname('NICKNAME'),
  keyword('KEYWORD'),
  completed('COMPLETED');

  const OnboardingStep(this.type);
  final String type;

  static OnboardingStep? fromString(String? value) {
    if (value == null) return null;
    return OnboardingStep.values.where((e) => e.type == value).firstOrNull;
  }
}
