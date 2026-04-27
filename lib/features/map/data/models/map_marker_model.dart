import 'package:freezed_annotation/freezed_annotation.dart';

part 'map_marker_model.freezed.dart';
part 'map_marker_model.g.dart';

@freezed
abstract class MapMarkerModel with _$MapMarkerModel {
  const MapMarkerModel._();

  factory MapMarkerModel({
    required int id,
    required double lat,
    required double lng,
  }) = _MapMarkerModel;

  factory MapMarkerModel.fromJson(Map<String, dynamic> json) =>
      _$MapMarkerModelFromJson(json);
}
