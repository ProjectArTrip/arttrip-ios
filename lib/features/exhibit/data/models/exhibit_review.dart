import 'package:freezed_annotation/freezed_annotation.dart';

part 'exhibit_review.freezed.dart';
part 'exhibit_review.g.dart';

/// 전시 리뷰 모델
@freezed
abstract class ExhibitReview with _$ExhibitReview {
  const ExhibitReview._();

  factory ExhibitReview({
    required int reviewId,
    required String visitDate,
    required String content,
    String? thumbnailUrl,
    String? nickname,
  }) = _ExhibitReview;

  factory ExhibitReview.fromJson(Map<String, dynamic> json) =>
      _$ExhibitReviewFromJson(json);
}

/// 전시 리뷰 목록 응답 모델
///
/// /reviews/{exhibitId}/detail 응답의 result 필드
@freezed
abstract class ExhibitReviewListResponse with _$ExhibitReviewListResponse {
  const ExhibitReviewListResponse._();

  factory ExhibitReviewListResponse({
    required List<ExhibitReview> reviews,
    String? nextCursor,
    required bool hasNext,
    required int reviewTotalCount,
  }) = _ExhibitReviewListResponse;

  factory ExhibitReviewListResponse.fromJson(Map<String, dynamic> json) =>
      _$ExhibitReviewListResponseFromJson(json);
}
