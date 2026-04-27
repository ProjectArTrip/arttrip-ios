import 'package:arttrip/features/map/data/models/map_marker_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'map_markers_response.freezed.dart';
part 'map_markers_response.g.dart';

@freezed
abstract class MapMarkersResponse with _$MapMarkersResponse {
  const MapMarkersResponse._();

  factory MapMarkersResponse({
    required List<MapMarkerModel> markers,
  }) = _MapMarkersResponse;

  factory MapMarkersResponse.fromJson(Map<String, dynamic> json) =>
      _$MapMarkersResponseFromJson(json);
}
