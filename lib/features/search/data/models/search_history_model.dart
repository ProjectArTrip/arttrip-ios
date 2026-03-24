import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_history_model.freezed.dart';
part 'search_history_model.g.dart';

/// 최근 검색어 모델
@freezed
abstract class SearchHistoryModel with _$SearchHistoryModel {
  factory SearchHistoryModel({
    required int searchHistoryId,
    required String content,
    required String createdAt,
  }) = _SearchHistoryModel;

  factory SearchHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$SearchHistoryModelFromJson(json);
}
