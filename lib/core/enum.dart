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
