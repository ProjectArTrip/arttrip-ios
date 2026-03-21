import 'package:arttrip/core/app_utils.dart';
import 'package:arttrip/core/network/dio_client.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_model.dart';
import 'package:arttrip/shared/models/region_model.dart';

abstract class HomeRepository {
  Future<List<String>?> fetchOverseasCountries();
  Future<List<RegionModel>?> fetchDomesticRegions();
  Future<List<ExhibitModel>?> fetchTodayExhibitRecommendations({
    required bool isDomestic,
    String? country,
    String? region,
  });
  Future<List<String>?> fetchGenres();
  Future<List<ExhibitModel>?> fetchExhibitsByGenre({
    required bool isDomestic,
    String? country,
    String? region,
    required String genre,
  });
  Future<List<ExhibitModel>?> fetchPersonalizedExhibits({
    required bool isDomestic,
    String? country,
    String? region,
  });
  Future<List<ExhibitModel>?> fetchWeeklyExhibitsBySelectedDate({
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
  Future<List<String>?> fetchOverseasCountries() async {
    try {
      final response = await _dio.get('/exhibits/overseas');
      final data = response.dataOrNull;
      if (data == null) return null;
      final map = data as Map<String, dynamic>;
      final result = map['result'] as Map<String, dynamic>?;
      final countries = result?['countries'] as List?;
      if (countries == null) return null;
      return countries
          .map<String>((e) => (e as Map<String, dynamic>)['label'].toString())
          .toList();
    } catch (e) {
      AppUtil.debugLog('fetchOverseasCountries: $e');
    }
    return null;
  }

  @override
  Future<List<RegionModel>?> fetchDomesticRegions() async {
    try {
      final response = await _dio.get('/exhibits/domestic');
      final data = response.dataOrNull;
      if (data == null) return null;
      final map = data as Map<String, dynamic>;
      final result = map['result'] as Map<String, dynamic>?;
      final regions = result?['regions'] as List?;
      if (regions == null) return null;
      return regions
          .map<RegionModel>(
            (e) => RegionModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      AppUtil.debugLog('fetchDomesticRegions: $e');
    }
    return null;
  }

  @override
  Future<List<ExhibitModel>?> fetchTodayExhibitRecommendations({
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
      if (data == null) return null;
      final map = data as Map<String, dynamic>;
      final exhibits = map['exhibits'] as List?;
      if (exhibits == null) return null;
      return exhibits
          .map<ExhibitModel>(
            (e) => ExhibitModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      AppUtil.debugLog('fetchTodayExhibitRecommendations: $e');
    }
    return null;
  }

  @override
  Future<List<String>?> fetchGenres() async {
    try {
      final response = await _dio.get('/exhibits/genre');
      final data = response.dataOrNull;
      if (data == null) return null;
      final map = data as Map<String, dynamic>;
      final result = map['result'] as Map<String, dynamic>?;
      final genres = result?['genres'] as List?;
      if (genres == null) return null;
      return genres
          .map<String>((e) => (e as Map<String, dynamic>)['name'].toString())
          .toList();
    } catch (e) {
      AppUtil.debugLog('fetchGenres: $e');
    }
    return null;
  }

  @override
  Future<List<ExhibitModel>?> fetchExhibitsByGenre({
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
      if (data == null) return null;
      final map = data as Map<String, dynamic>;
      final exhibits = map['exhibits'] as List?;
      if (exhibits == null) return null;
      return exhibits
          .map<ExhibitModel>(
            (e) => ExhibitModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      AppUtil.debugLog('fetchExhibitsByGenre: $e');
    }
    return null;
  }

  @override
  Future<List<ExhibitModel>?> fetchPersonalizedExhibits({
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
      if (data == null) return null;
      final map = data as Map<String, dynamic>;
      final exhibits = map['exhibits'] as List?;
      if (exhibits == null) return null;
      return exhibits
          .map<ExhibitModel>(
            (e) => ExhibitModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      AppUtil.debugLog('fetchPersonalizedExhibits: $e');
    }
    return null;
  }

  @override
  Future<List<ExhibitModel>?> fetchWeeklyExhibitsBySelectedDate({
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
      if (data == null) return null;
      final map = data as Map<String, dynamic>;
      final exhibits = map['exhibits'] as List?;
      if (exhibits == null) return null;
      return exhibits
          .map<ExhibitModel>(
            (e) => ExhibitModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      AppUtil.debugLog('fetchWeeklyExhibitsBySelectedDate: $e');
    }
    return null;
  }
}
