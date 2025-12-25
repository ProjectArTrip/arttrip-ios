import 'package:freezed_annotation/freezed_annotation.dart';

part 'exhibit_review_model.freezed.dart';
part 'exhibit_review_model.g.dart';

/// 전시 리뷰 모델
@freezed
abstract class ExhibitReviewModel with _$ExhibitReviewModel {
  const ExhibitReviewModel._();

  factory ExhibitReviewModel({
    required int reviewId,
    required String visitDate,
    required String content,
    String? thumbnailUrl,
    String? nickname,
  }) = _ExhibitReviewModel;

  factory ExhibitReviewModel.fromJson(Map<String, dynamic> json) =>
      _$ExhibitReviewModelFromJson(json);
}

/// 전시 리뷰 목록 응답 모델
///
/// /reviews/{exhibitId}/detail 응답의 result 필드
@freezed
abstract class ExhibitReviewListResponseModel with _$ExhibitReviewListResponseModel {
  const ExhibitReviewListResponseModel._();

  factory ExhibitReviewListResponseModel({
    required List<ExhibitReviewModel> reviews,
    String? nextCursor,
    required bool hasNext,
    required int reviewTotalCount,
  }) = _ExhibitReviewListResponseModel;

  factory ExhibitReviewListResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ExhibitReviewListResponseModelFromJson(json);
}
