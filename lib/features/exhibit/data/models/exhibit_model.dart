import 'package:freezed_annotation/freezed_annotation.dart';

part 'exhibit_model.freezed.dart';
part 'exhibit_model.g.dart';

/// 홈에서 쓰이는 전시 모델
@freezed
abstract class ExhibitModel with _$ExhibitModel {
  const ExhibitModel._();

  factory ExhibitModel({
    int? exhibitId,
    String? title,
    String? posterUrl,
    String? status,
    String? exhibitPeriod,
    String? hallName,
    String? countryName,
    String? regionName,
    @JsonKey(name: 'isFavorite') @Default(false) bool favorite,
  }) = _ExhibitModel;

  factory ExhibitModel.fromJson(Map<String, dynamic> json) =>
      _$ExhibitModelFromJson(json);
}
