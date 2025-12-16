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
  }) = _ExhibitModel;

  factory ExhibitModel.fromJson(Map<String, dynamic> json) => _$ExhibitModelFromJson(json);
}
