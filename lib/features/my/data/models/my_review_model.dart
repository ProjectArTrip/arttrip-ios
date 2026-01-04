import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_review_model.freezed.dart';
part 'my_review_model.g.dart';

@freezed
abstract class MyReviewModel with _$MyReviewModel {
  const MyReviewModel._();

  const factory MyReviewModel({
    required int reviewId,
    required String reviewTitle,
    required String visitDate,
    required String content,
    String? thumbnailUrl,
    required String createdAt,
  }) = _MyReviewModel;

  factory MyReviewModel.fromJson(Map<String, dynamic> json) =>
      _$MyReviewModelFromJson(json);
}

@freezed
abstract class MyReviewListResponseModel with _$MyReviewListResponseModel {
  const MyReviewListResponseModel._();

  const factory MyReviewListResponseModel({
    required List<MyReviewModel> reviews,
    String? nextCursor,
    required bool hasNext,
    @Default(0) int totalCount,
  }) = _MyReviewListResponseModel;

  factory MyReviewListResponseModel.fromJson(Map<String, dynamic> json) =>
      _$MyReviewListResponseModelFromJson(json);
}
