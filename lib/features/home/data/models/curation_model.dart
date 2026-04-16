import 'package:arttrip/features/exhibit/data/models/exhibit_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'curation_model.freezed.dart';
part 'curation_model.g.dart';

@freezed
abstract class CurationModel with _$CurationModel {
  const CurationModel._();

  factory CurationModel({
    @Default([]) List<ExhibitModel> curations,
    @Default('') String title,
  }) = _CurationModel;

  factory CurationModel.fromJson(Map<String, dynamic> json) =>
      _$CurationModelFromJson(json);
}
