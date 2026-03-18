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
      var response = await _dio.get('/exhibits/overseas');
      var data = response.dataOrNull;
      if (data == null) return null;
      var map = data as Map<String, dynamic>;
      var result = map['result'] as Map<String, dynamic>?;
      var countries = result?['countries'] as List?;
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
      var response = await _dio.get('/exhibits/domestic');
      var data = response.dataOrNull;
      if (data == null) return null;
      var map = data as Map<String, dynamic>;
      var result = map['result'] as Map<String, dynamic>?;
      var regions = result?['regions'] as List?;
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
      var queryParams = {
        'isDomestic': isDomestic,
        if (!isDomestic) 'country': country,
        if (isDomestic) 'region': region,
      };
      var response = await _dio.get(
        '/home/exhibits/today',
        queryParameters: queryParams,
      );
      var data = response.dataOrNull;
      if (data == null) return null;
      var map = data as Map<String, dynamic>;
      var exhibits = map['exhibits'] as List?;
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
      var response = await _dio.get('/exhibits/genre');
      var data = response.dataOrNull;
      if (data == null) return null;
      var map = data as Map<String, dynamic>;
      var result = map['result'] as Map<String, dynamic>?;
      var genres = result?['genres'] as List?;
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
      var queryParams = {
        'isDomestic': isDomestic,
        if (!isDomestic) 'country': country,
        if (isDomestic) 'region': region,
        'singleGenre': genre,
      };
      var response = await _dio.get(
        '/home/exhibits/genres',
        queryParameters: queryParams,
      );
      var data = response.dataOrNull;
      if (data == null) return null;
      var map = data as Map<String, dynamic>;
      var exhibits = map['exhibits'] as List?;
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
      var queryParams = {
        'isDomestic': isDomestic,
        if (!isDomestic) 'country': country,
        if (isDomestic) 'region': region,
      };
      var response = await _dio.get(
        '/home/exhibits/personalized',
        queryParameters: queryParams,
      );
      var data = response.dataOrNull;
      if (data == null) return null;
      var map = data as Map<String, dynamic>;
      var exhibits = map['exhibits'] as List?;
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
      var queryParams = {
        'isDomestic': isDomestic,
        if (!isDomestic) 'country': country,
        if (isDomestic) 'region': region,
        'date': date,
      };
      var response = await _dio.get(
        '/home/exhibits/schedule',
        queryParameters: queryParams,
      );
      var data = response.dataOrNull;
      if (data == null) return null;
      var map = data as Map<String, dynamic>;
      var exhibits = map['exhibits'] as List?;
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
