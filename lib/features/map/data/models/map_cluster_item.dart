import 'package:arttrip/features/map/data/models/map_marker_model.dart';
import 'package:google_maps_cluster_manager_2/google_maps_cluster_manager_2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapClusterItem with ClusterItem {
  MapClusterItem(this.marker);

  final MapMarkerModel marker;

  @override
  LatLng get location => LatLng(marker.lat, marker.lng);
}
