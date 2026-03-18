import 'package:arttrip/features/onboarding/data/models/keyword_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'keyword_list_response_model.freezed.dart';
part 'keyword_list_response_model.g.dart';

@freezed
abstract class KeywordListResponseModel with _$KeywordListResponseModel {
  const factory KeywordListResponseModel({
    @Default([]) List<KeywordModel> keywords,
  }) = _KeywordListResponseModel;

  factory KeywordListResponseModel.fromJson(Map<String, dynamic> json) =>
      _$KeywordListResponseModelFromJson(json);
}
