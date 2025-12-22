/// 리뷰 작성 페이지 파라미터
///
/// Routes.modal로 리뷰 작성 페이지 호출 시 extra로 전달
/// exhibitId는 path parameter로 전달
class WriteReviewParams {
  const WriteReviewParams({
    required this.posterUrl,
    required this.title,
    required this.hallName,
  });

  final String posterUrl;
  final String title;
  final String hallName;
}
