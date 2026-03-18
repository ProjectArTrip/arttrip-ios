import 'package:freezed_annotation/freezed_annotation.dart';

part 'recent_exhibit_model.freezed.dart';
part 'recent_exhibit_model.g.dart';

/// 최근 본 전시 모델
@freezed
abstract class RecentExhibitModel with _$RecentExhibitModel {
  const factory RecentExhibitModel({
    required int exhibitId,
    required String title,
    String? exhibitHallName,
    String? exhibitImage,
  }) = _RecentExhibitModel;

  factory RecentExhibitModel.fromJson(Map<String, dynamic> json) =>
      _$RecentExhibitModelFromJson(json);
}

/// 최근 본 전시 목록 응답 모델
@freezed
abstract class RecentExhibitListResponseModel
    with _$RecentExhibitListResponseModel {
  const factory RecentExhibitListResponseModel({
    @Default([]) List<RecentExhibitModel> exhibits,
  }) = _RecentExhibitListResponseModel;

  factory RecentExhibitListResponseModel.fromJson(Map<String, dynamic> json) =>
      _$RecentExhibitListResponseModelFromJson(json);
}
