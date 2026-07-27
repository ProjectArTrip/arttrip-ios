import 'package:freezed_annotation/freezed_annotation.dart';

part 'review_create_result.freezed.dart';
part 'review_create_result.g.dart';

/// 리뷰 등록 응답 모델
///
/// POST /reviews/{exhibitId} 응답
@freezed
abstract class ReviewCreateResult with _$ReviewCreateResult {
  const factory ReviewCreateResult({
    required int reviewId,
    required String content,
    @JsonKey(name: 'date') required String visitDate,
    @Default([]) List<ReviewImage> images,
  }) = _ReviewCreateResult;

  factory ReviewCreateResult.fromJson(Map<String, dynamic> json) =>
      _$ReviewCreateResultFromJson(json);
}

/// 리뷰 이미지 모델
@freezed
abstract class ReviewImage with _$ReviewImage {
  const factory ReviewImage({
    required int reviewImageId,
    required String imageUrl,
  }) = _ReviewImage;

  factory ReviewImage.fromJson(Map<String, dynamic> json) =>
      _$ReviewImageFromJson(json);
}
