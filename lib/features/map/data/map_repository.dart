import 'package:arttrip/core/api_endpoints.dart';
import 'package:arttrip/core/app_utils.dart';
import 'package:arttrip/core/network/dio_client.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_filter_model.dart';
import 'package:arttrip/features/map/data/models/map_markers_response.dart';
import 'package:arttrip/shared/models/region_model.dart';
import 'package:dio/dio.dart';

abstract class MapRepository {
  /// 전체 마커 좌표 일괄 조회
  Future<MapMarkersResponse?> fetchMarkers({String? etag});

  /// 클러스터/마커 탭 시 전시 상세 리스트 조회
  Future<ExhibitFilterModel?> fetchClusterExhibits({
    required List<int> ids,
    int? cursor,
    int? size,
  });

  /// 해외 국가 리스트 조회
  Future<List<String>> fetchCountries();

  /// 국내 지역 리스트 조회
  Future<List<RegionModel>> fetchDomesticRegions();
}

class MapRepositoryImpl implements MapRepository {
  MapRepositoryImpl(this._dio);
  final DioClient _dio;

  @override
  Future<MapMarkersResponse?> fetchMarkers({String? etag}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.mapMarkers,
        options: etag != null
            ? Options(headers: {'If-None-Match': etag})
            : null,
      );
      final data = response.dataOrNull;
      if (data == null) return null;
      final map = data as Map<String, dynamic>;
      // result 래퍼가 있으면 언래핑, 없으면 바로 파싱
      final target = map.containsKey('result')
          ? map['result'] as Map<String, dynamic>
          : map;
      return MapMarkersResponse.fromJson(target);
    } catch (e) {
      AppUtil.debugLog('fetchMarkers: $e');
    }
    return null;
  }

  @override
  Future<ExhibitFilterModel?> fetchClusterExhibits({
    required List<int> ids,
    int? cursor,
    int? size,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'ids': ids,
      };
      if (cursor != null) queryParams['cursor'] = cursor;
      if (size != null) queryParams['size'] = size;

      final response = await _dio.get(
        ApiEndpoints.mapCluster,
        queryParameters: queryParams,
      );
      final data = response.dataOrNull;
      if (data == null) return null;
      final map = data as Map<String, dynamic>;
      // result 래퍼가 있으면 언래핑, 없으면 바로 파싱
      final target = map.containsKey('result')
          ? map['result'] as Map<String, dynamic>
          : map;
      return ExhibitFilterModel.fromJson(target);
    } catch (e) {
      AppUtil.debugLog('fetchClusterExhibits: $e');
    }
    return null;
  }

  @override
  Future<List<String>> fetchCountries() async {
    try {
      final response = await _dio.get(ApiEndpoints.exhibitsOverseas);
      final data = response.dataOrNull;
      if (data == null) return [];
      final map = data as Map<String, dynamic>;
      final result = map['result'] as Map<String, dynamic>?;
      final countries = result?['countries'] as List?;
      if (countries == null) return [];
      return countries
          .map<String>((e) => (e as Map<String, dynamic>)['label'].toString())
          .toList();
    } catch (e) {
      AppUtil.debugLog('fetchCountries: $e');
    }
    return [];
  }

  @override
  Future<List<RegionModel>> fetchDomesticRegions() async {
    try {
      final response = await _dio.get(ApiEndpoints.exhibitsDomestic);
      final data = response.dataOrNull;
      if (data == null) return [];
      final map = data as Map<String, dynamic>;
      final result = map['result'] as Map<String, dynamic>?;
      final regions = result?['regions'] as List?;
      if (regions == null) return [];
      return regions
          .map<RegionModel>(
            (e) => RegionModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      AppUtil.debugLog('fetchDomesticRegions: $e');
    }
    return [];
  }
}
