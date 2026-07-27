import 'package:arttrip/features/exhibit/data/models/exhibit_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'exhibit_filter_model.freezed.dart';
part 'exhibit_filter_model.g.dart';

@freezed
abstract class ExhibitFilterModel with _$ExhibitFilterModel {
  const ExhibitFilterModel._();

  factory ExhibitFilterModel({
    required List<ExhibitModel> exhibits,
    required bool hasNext,
    int? nextCursor,
    @Default(0) int exhibitTotalCount,
    @Default('') String title,
  }) = _ExhibitFilterModel;

  factory ExhibitFilterModel.fromJson(Map<String, dynamic> json) =>
      _$ExhibitFilterModelFromJson(json);
}
