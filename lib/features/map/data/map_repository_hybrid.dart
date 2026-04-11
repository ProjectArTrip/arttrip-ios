import 'package:arttrip/core/app_consts.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_filter_model.dart';
import 'package:arttrip/features/map/data/map_repository.dart';
import 'package:arttrip/features/map/data/models/map_markers_response.dart';
import 'package:arttrip/shared/models/region_model.dart';

class MapRepositoryHybrid implements MapRepository {
  MapRepositoryHybrid({required this.mock, required this.api});

  final MapRepository mock;
  final MapRepositoryImpl api;

  @override
  Future<MapMarkersResponse?> fetchMarkers({String? etag}) {
    if (AppConsts.useMock) return mock.fetchMarkers(etag: etag);
    return api.fetchMarkers(etag: etag);
  }

  @override
  Future<ExhibitFilterModel?> fetchClusterExhibits({
    required List<int> ids,
    int? cursor,
    int? size,
  }) {
    if (AppConsts.useMock) {
      return mock.fetchClusterExhibits(ids: ids, cursor: cursor, size: size);
    }
    return api.fetchClusterExhibits(ids: ids, cursor: cursor, size: size);
  }

  @override
  Future<List<String>> fetchCountries() {
    if (AppConsts.useMock) return mock.fetchCountries();
    return api.fetchCountries();
  }

  @override
  Future<List<RegionModel>> fetchDomesticRegions() {
    if (AppConsts.useMock) return mock.fetchDomesticRegions();
    return api.fetchDomesticRegions();
  }
}
