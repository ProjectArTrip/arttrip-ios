import 'package:arttrip/core/app_utils.dart';
import 'package:arttrip/core/network/dio_client.dart';
import 'package:arttrip/shared/models/base_result_model.dart';
import 'package:arttrip/shared/models/exhibit_model.dart';

abstract class HomeRepository {
  Future<List<String>?> fetchOverseasCountries();
  Future<List<String>?> fetchDomesticRegions();
  Future<List<ExhibitModel>?> fetchTodayExhibitRecommendations({
    required bool isDomestic,
    String? country,
    String? region,
  });
  Future<List<String>?> fetchGenres();
  Future<List<ExhibitModel>?> fetchExhibitionsByGenre({
    required bool isDomestic,
    String? country,
    String? region,
    required String genre,
  });
  Future<List<ExhibitModel>?> fetchPersonalizedExhibitions({
    required bool isDomestic,
    String? country,
    String? region,
  });
  Future<List<ExhibitModel>?> fetchWeeklyExhibitionsBySelectedDate({
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
      var response = await _dio.get('/exhibit/overseas');
      var model = BaseResultModel.fromJson(response.dataOrNull);
      if (model.result is! List) {
        AppUtil.debugLog(
          'fetchOverseasCountries type inconsistency: ${model.result.runtimeType}',
        );
        return null;
      }

      return model.result.map<String>((e) => e.toString()).toList();
    } catch (e) {
      AppUtil.debugLog('fetchOverseasCountries: $e');
    }
    return null;
  }

  @override
  Future<List<String>?> fetchDomesticRegions() async {
    try {
      var response = await _dio.get('/exhibit/domestic');
      var model = BaseResultModel.fromJson(response.dataOrNull);
      if (model.result is! List) {
        AppUtil.debugLog(
          'fetchDomesticRegions type inconsistency: ${model.result.runtimeType}',
        );
        return null;
      }

      return model.result.map<String>((e) => e.toString()).toList();
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
      var body = {
        'isDomestic': isDomestic,
        if (!isDomestic) 'country': country,
        if (isDomestic) 'region': region,
      };
      var response = await _dio.post('/home/recommend/today', data: body);
      var model = BaseResultModel.fromJson(response.dataOrNull);
      if (model.result is! List) {
        AppUtil.debugLog(
          'fetchTodayExhibitRecommendations type inconsistency: ${model.result.runtimeType}',
        );
        return null;
      }
      return model.result
          .map<ExhibitModel>((e) => ExhibitModel.fromJson(e))
          .toList();
    } catch (e) {
      AppUtil.debugLog('fetchTodayExhibitRecommendations: $e');
    }
    return null;
  }

  @override
  Future<List<String>?> fetchGenres() async {
    try {
      var response = await _dio.get('/exhibit/genre');
      var model = BaseResultModel.fromJson(response.dataOrNull);
      if (model.result is! List) {
        AppUtil.debugLog(
          'fetchGenres type inconsistency: ${model.result.runtimeType}',
        );
        return null;
      }
      return model.result.map<String>((e) => e.toString()).toList();
    } catch (e) {
      AppUtil.debugLog('fetchGenres: $e');
    }
    return null;
  }

  @override
  Future<List<ExhibitModel>?> fetchExhibitionsByGenre({
    required bool isDomestic,
    String? country,
    String? region,
    required String genre,
  }) async {
    try {
      var body = {
        'isDomestic': isDomestic,
        if (!isDomestic) 'country': country,
        if (isDomestic) 'region': region,
        'singleGenre': genre,
      };
      var response = await _dio.post('/home/genre/random', data: body);
      var model = BaseResultModel.fromJson(response.dataOrNull);
      if (model.result is! List) {
        AppUtil.debugLog(
          'fetchExhibitionsByGenre type inconsistency: ${model.result.runtimeType}',
        );
        return null;
      }
      return model.result
          .map<ExhibitModel>((e) => ExhibitModel.fromJson(e))
          .toList();
    } catch (e) {
      AppUtil.debugLog('fetchExhibitionsByGenre: $e');
    }
    return null;
  }

  @override
  Future<List<ExhibitModel>?> fetchPersonalizedExhibitions({
    required bool isDomestic,
    String? country,
    String? region,
  }) async {
    try {
      var body = {
        'isDomestic': isDomestic,
        if (!isDomestic) 'country': country,
        if (isDomestic) 'region': region,
      };
      var response = await _dio.post('/home/personalized/random', data: body);
      var model = BaseResultModel.fromJson(response.dataOrNull);
      if (model.result is! List) {
        AppUtil.debugLog(
          'fetchPersonalizedExhibitions type inconsistency: ${model.result.runtimeType}',
        );
        return null;
      }
      return model.result
          .map<ExhibitModel>((e) => ExhibitModel.fromJson(e))
          .toList();
    } catch (e) {
      AppUtil.debugLog('fetchPersonalizedExhibitions: $e');
    }
    return null;
  }

  @override
  Future<List<ExhibitModel>?> fetchWeeklyExhibitionsBySelectedDate({
    required bool isDomestic,
    String? country,
    String? region,
    required String date,
  }) async {
    try {
      var body = {
        'isDomestic': isDomestic,
        if (!isDomestic) 'country': country,
        if (isDomestic) 'region': region,
        'date': date,
      };
      var response = await _dio.post('/home/personalized/random', data: body);
      var model = BaseResultModel.fromJson(response.dataOrNull);
      if (model.result is! List) {
        AppUtil.debugLog(
          'fetchWeeklyExhibitionsBySelectedDate type inconsistency: ${model.result.runtimeType}',
        );
        return null;
      }
      return model.result
          .map<ExhibitModel>((e) => ExhibitModel.fromJson(e))
          .toList();
    } catch (e) {
      AppUtil.debugLog('fetchWeeklyExhibitionsBySelectedDate: $e');
    }
    return null;
  }
}
