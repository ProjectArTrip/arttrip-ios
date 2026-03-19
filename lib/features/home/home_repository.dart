import 'package:arttrip/core/app_utils.dart';
import 'package:arttrip/core/network/dio_client.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_model.dart';
import 'package:arttrip/shared/models/region_model.dart';

abstract class HomeRepository {
  /// 해외 국가 리스트 조회
  Future<List<String>> fetchOverseasCountries();

  /// 국내 지역 리스트 조회
  Future<List<RegionModel>> fetchDomesticRegions();

  /// 오늘의 전시 추천 조회
  Future<List<ExhibitModel>> fetchTodayExhibitRecommendations({
    required bool isDomestic,
    String? country,
    String? region,
  });

  /// 장르 리스트 조회
  Future<List<String>> fetchGenres();

  /// 장르별 전시 조회
  Future<List<ExhibitModel>> fetchExhibitsByGenre({
    required bool isDomestic,
    String? country,
    String? region,
    required String genre,
  });

  /// 사용자 맞춤 전시 조회
  Future<List<ExhibitModel>> fetchPersonalizedExhibits({
    required bool isDomestic,
    String? country,
    String? region,
  });

  /// 선택한 날짜 기준 주간 전시 조회
  Future<List<ExhibitModel>> fetchWeeklyExhibitsBySelectedDate({
    required bool isDomestic,
    String? country,
    String? region,
    required String date,
  });
}

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(this._dio);
  final DioClient _dio;

  @override
  Future<List<String>> fetchOverseasCountries() async {
    try {
      final response = await _dio.get('/exhibits/overseas');
      final data = response.dataOrNull;
      if (data == null) throw Exception('No data in response');
      final map = data as Map<String, dynamic>;
      final result = map['result'] as Map<String, dynamic>?;
      final countries = result?['countries'] as List?;
      if (countries == null) throw Exception('No countries found');
      return countries
          .map<String>((e) => (e as Map<String, dynamic>)['label'].toString())
          .toList();
    } catch (e) {
      AppUtil.debugLog('fetchOverseasCountries error: $e');
      rethrow;
    }
  }

  @override
  Future<List<RegionModel>> fetchDomesticRegions() async {
    try {
      final response = await _dio.get('/exhibits/domestic');
      final data = response.dataOrNull;
      if (data == null) throw Exception('No data in response');
      final map = data as Map<String, dynamic>;
      final result = map['result'] as Map<String, dynamic>?;
      final regions = result?['regions'] as List?;
      if (regions == null) throw Exception('No regions found');
      return regions
          .map<RegionModel>(
            (e) => RegionModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      AppUtil.debugLog('fetchDomesticRegions error: $e');
      rethrow;
    }
  }

  @override
  Future<List<ExhibitModel>> fetchTodayExhibitRecommendations({
    required bool isDomestic,
    String? country,
    String? region,
  }) async {
    try {
      final queryParams = {
        'isDomestic': isDomestic,
        if (!isDomestic) 'country': country,
        if (isDomestic) 'region': region,
      };
      final response = await _dio.get(
        '/home/exhibits/today',
        queryParameters: queryParams,
      );
      final data = response.dataOrNull;
      if (data == null) throw Exception('No data in response');
      final map = data as Map<String, dynamic>;
      final exhibits = map['exhibits'] as List?;
      if (exhibits == null) throw Exception('No exhibits found');
      return exhibits
          .map<ExhibitModel>(
            (e) => ExhibitModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      AppUtil.debugLog('fetchTodayExhibitRecommendations error: $e');
      rethrow;
    }
  }

  @override
  Future<List<String>> fetchGenres() async {
    try {
      final response = await _dio.get('/exhibits/genre');
      final data = response.dataOrNull;
      if (data == null) throw Exception('No data in response');
      final map = data as Map<String, dynamic>;
      final result = map['result'] as Map<String, dynamic>?;
      final genres = result?['genres'] as List?;
      if (genres == null) throw Exception('No genres found');
      return genres
          .map<String>((e) => (e as Map<String, dynamic>)['name'].toString())
          .toList();
    } catch (e) {
      AppUtil.debugLog('fetchGenres error: $e');
      rethrow;
    }
  }

  @override
  Future<List<ExhibitModel>> fetchExhibitsByGenre({
    required bool isDomestic,
    String? country,
    String? region,
    required String genre,
  }) async {
    try {
      final queryParams = {
        'isDomestic': isDomestic,
        if (!isDomestic) 'country': country,
        if (isDomestic) 'region': region,
        'singleGenre': genre,
      };
      final response = await _dio.get(
        '/home/exhibits/genres',
        queryParameters: queryParams,
      );
      final data = response.dataOrNull;
      if (data == null) throw Exception('No data in response');
      final map = data as Map<String, dynamic>;
      final exhibits = map['exhibits'] as List?;
      if (exhibits == null) throw Exception('No exhibits found');
      return exhibits
          .map<ExhibitModel>(
            (e) => ExhibitModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      AppUtil.debugLog('fetchExhibitsByGenre error: $e');
      rethrow;
    }
  }

  @override
  Future<List<ExhibitModel>> fetchPersonalizedExhibits({
    required bool isDomestic,
    String? country,
    String? region,
  }) async {
    try {
      final queryParams = {
        'isDomestic': isDomestic,
        if (!isDomestic) 'country': country,
        if (isDomestic) 'region': region,
      };
      final response = await _dio.get(
        '/home/exhibits/personalized',
        queryParameters: queryParams,
      );
      final data = response.dataOrNull;
      if (data == null) throw Exception('No data in response');
      final map = data as Map<String, dynamic>;
      final exhibits = map['exhibits'] as List?;
      if (exhibits == null) throw Exception('No exhibits found');
      return exhibits
          .map<ExhibitModel>(
            (e) => ExhibitModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      AppUtil.debugLog('fetchPersonalizedExhibits error: $e');
      rethrow;
    }
  }

  @override
  Future<List<ExhibitModel>> fetchWeeklyExhibitsBySelectedDate({
    required bool isDomestic,
    String? country,
    String? region,
    required String date,
  }) async {
    try {
      final queryParams = {
        'isDomestic': isDomestic,
        if (!isDomestic) 'country': country,
        if (isDomestic) 'region': region,
        'date': date,
      };
      final response = await _dio.get(
        '/home/exhibits/schedule',
        queryParameters: queryParams,
      );
      final data = response.dataOrNull;
      if (data == null) throw Exception('No data in response');
      final map = data as Map<String, dynamic>;
      final exhibits = map['exhibits'] as List?;
      if (exhibits == null) throw Exception('No exhibits found');
      return exhibits
          .map<ExhibitModel>(
            (e) => ExhibitModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      AppUtil.debugLog('fetchWeeklyExhibitsBySelectedDate error: $e');
      rethrow;
    }
  }
}
