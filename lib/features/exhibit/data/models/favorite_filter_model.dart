import 'package:arttrip/features/exhibit/data/models/exhibit_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'favorite_filter_model.freezed.dart';
part 'favorite_filter_model.g.dart';

@freezed
abstract class FavoriteFilterModel with _$FavoriteFilterModel {
  const FavoriteFilterModel._();

  factory FavoriteFilterModel({
    required List<ExhibitModel> favorites,
    @Default(0) int favoriteTotalCount,
    required bool hasNext,
    int? nextCursor,
  }) = _FavoriteFilterModel;

  factory FavoriteFilterModel.fromJson(Map<String, dynamic> json) =>
      _$FavoriteFilterModelFromJson(json);
}
