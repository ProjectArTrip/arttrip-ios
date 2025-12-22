import 'package:freezed_annotation/freezed_annotation.dart';

part 'exhibit_model.freezed.dart';
part 'exhibit_model.g.dart';

@freezed
abstract class ExhibitModel with _$ExhibitModel {
  const ExhibitModel._();

  factory ExhibitModel({
    @JsonKey(name: 'exhibit_id') int? exhibitId,
    String? title,
    String? posterUrl,
    String? status,
    String? exhibitPeriod,
    String? hallName,
    String? countryName,
    String? regionName,
    @Default(false) bool isFavorite, // TODO: 컬럼명 확인 필요
  }) = _ExhibitModel;

  factory ExhibitModel.fromJson(Map<String, dynamic> json) =>
      _$ExhibitModelFromJson(json);
}
