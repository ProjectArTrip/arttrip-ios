import 'package:arttrip/core/app_consts.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_filter_model.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_model.dart';
import 'package:arttrip/features/map/data/map_repository.dart';
import 'package:arttrip/features/map/data/models/map_marker_model.dart';
import 'package:arttrip/features/map/data/models/map_markers_response.dart';
import 'package:arttrip/shared/models/region_model.dart';

class MapRepositoryMockImpl implements MapRepository {
  MapRepositoryMockImpl();

  static final _mockMarkers = [
    // 서울
    MapMarkerModel(id: 1, lat: 37.5796, lng: 126.9770),
    MapMarkerModel(id: 2, lat: 37.5662, lng: 126.9784),
    MapMarkerModel(id: 3, lat: 37.5233, lng: 127.0228),
    MapMarkerModel(id: 4, lat: 37.5791, lng: 126.9799),
    MapMarkerModel(id: 5, lat: 37.5400, lng: 127.0056),
    // 파리
    MapMarkerModel(id: 6, lat: 48.8606, lng: 2.3376),
    MapMarkerModel(id: 7, lat: 48.8600, lng: 2.3266),
    MapMarkerModel(id: 8, lat: 48.8611, lng: 2.3364),
    MapMarkerModel(id: 9, lat: 48.8566, lng: 2.3522),
    MapMarkerModel(id: 10, lat: 48.8649, lng: 2.3210),
    MapMarkerModel(id: 11, lat: 48.8738, lng: 2.2950),
    MapMarkerModel(id: 12, lat: 48.8530, lng: 2.3499),
    // 도쿄
    MapMarkerModel(id: 13, lat: 35.7191, lng: 139.7745),
    MapMarkerModel(id: 14, lat: 35.6654, lng: 139.7707),
    MapMarkerModel(id: 15, lat: 35.6718, lng: 139.7636),
    MapMarkerModel(id: 16, lat: 35.6586, lng: 139.7454),
    // 뉴욕
    MapMarkerModel(id: 17, lat: 40.7794, lng: -73.9632),
    MapMarkerModel(id: 18, lat: 40.7614, lng: -73.9776),
    MapMarkerModel(id: 19, lat: 40.7484, lng: -73.9856),
    // 런던
    MapMarkerModel(id: 20, lat: 51.5089, lng: -0.0762),
    MapMarkerModel(id: 21, lat: 51.5076, lng: -0.0994),
  ];

  static final _mockExhibits = <int, ExhibitModel>{
    1: ExhibitModel(
      exhibitId: 1,
      title: '국립중앙박물관 특별전',
      posterUrl: 'https://picsum.photos/200/300?random=1',
      status: 'ONGOING',
      exhibitPeriod: '2025.06.01 - 2025.09.30',
      hallName: '국립중앙박물관',
      countryName: '한국',
      regionName: '서울',
    ),
    2: ExhibitModel(
      exhibitId: 2,
      title: '경복궁 미디어아트',
      posterUrl: 'https://picsum.photos/200/300?random=2',
      status: 'ONGOING',
      exhibitPeriod: '2025.07.01 - 2025.08.31',
      hallName: '경복궁',
      countryName: '한국',
      regionName: '서울',
    ),
    6: ExhibitModel(
      exhibitId: 6,
      title: 'Louvre Museum Exhibition',
      posterUrl: 'https://picsum.photos/200/300?random=6',
      status: 'ONGOING',
      exhibitPeriod: '2025.06.07 - 2025.09.14',
      hallName: '루브르 박물관',
      countryName: '프랑스',
      regionName: '파리',
    ),
    7: ExhibitModel(
      exhibitId: 7,
      title: 'Imagination in Bloom',
      posterUrl: 'https://picsum.photos/200/300?random=7',
      status: 'ONGOING',
      exhibitPeriod: '2025.07.29 - 2025.08.10',
      hallName: '오르세 미술관',
      countryName: '프랑스',
      regionName: '파리',
    ),
    13: ExhibitModel(
      exhibitId: 13,
      title: '도쿄 국립근대미술관전',
      posterUrl: 'https://picsum.photos/200/300?random=13',
      status: 'UPCOMING',
      exhibitPeriod: '2025.08.01 - 2025.10.31',
      hallName: '도쿄 국립근대미술관',
      countryName: '일본',
      regionName: '도쿄',
    ),
  };

  @override
  Future<MapMarkersResponse?> fetchMarkers({String? etag}) async {
    await Future.delayed(
      const Duration(milliseconds: AppConsts.mockLoadingDelayMs),
    );
    return MapMarkersResponse(markers: _mockMarkers);
  }

  @override
  Future<ExhibitFilterModel?> fetchClusterExhibits({
    required List<int> ids,
    int? cursor,
    int? size,
  }) async {
    await Future.delayed(
      const Duration(milliseconds: AppConsts.mockLoadingDelayMs),
    );
    final exhibits = ids
        .map(
          (id) =>
              _mockExhibits[id] ??
              ExhibitModel(
                exhibitId: id,
                title: '전시 #$id',
                posterUrl: 'https://picsum.photos/200/300?random=$id',
                status: 'ONGOING',
                exhibitPeriod: '2025.06.01 - 2025.09.30',
                hallName: '전시관 #$id',
                countryName: '한국',
                regionName: '서울',
              ),
        )
        .toList();
    return ExhibitFilterModel(
      exhibits: exhibits,
      hasNext: false,
      exhibitTotalCount: exhibits.length,
    );
  }

  @override
  Future<List<String>> fetchCountries() async {
    await Future.delayed(
      const Duration(milliseconds: AppConsts.mockLoadingDelayMs),
    );
    return ['프랑스', '독일', '일본', '이탈리아', '미국', '오스트리아', '영국', '스페인'];
  }

  @override
  Future<List<RegionModel>> fetchDomesticRegions() async {
    await Future.delayed(
      const Duration(milliseconds: AppConsts.mockLoadingDelayMs),
    );
    return [
      RegionModel(region: '서울'),
      RegionModel(region: '경기'),
      RegionModel(region: '부산'),
      RegionModel(region: '대구'),
      RegionModel(region: '제주'),
    ];
  }
}
