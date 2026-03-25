import 'package:arttrip/core/app_utils.dart';
import 'package:arttrip/core/network/dio_client.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_model.dart';
import 'package:arttrip/features/onboarding/data/models/keyword_model.dart';
import 'package:arttrip/features/search/data/models/search_history_model.dart';

abstract class SearchRepository {
  Future<List<ExhibitModel>?> searchExhibits(String query);
  Future<List<KeywordModel>?> fetchRecommendedKeywords();
  Future<List<SearchHistoryModel>?> fetchSearchHistory();
  Future<bool> deleteSearchHistory(int searchHistoryId);
}

class SearchRepositoryImpl implements SearchRepository {
  SearchRepositoryImpl(this._dio);
  final DioClient _dio;

  @override
  Future<List<ExhibitModel>?> searchExhibits(String query) async {
    try {
      final response = await _dio.get(
        '/exhibits',
        queryParameters: {'query': query},
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
      AppUtil.debugLog('searchExhibits: $e');
    }
    return null;
  }

  @override
  Future<List<KeywordModel>?> fetchRecommendedKeywords() async {
    try {
      final response = await _dio.get('/keyword/recommand');
      final data = response.dataOrNull;
      if (data == null) return null;
      final map = data as Map<String, dynamic>;
      final keywords = map['keywords'] as List?;
      if (keywords == null) return null;
      return keywords
          .map<KeywordModel>(
            (e) => KeywordModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      AppUtil.debugLog('fetchRecommendedKeywords: $e');
    }
    return null;
  }

  @override
  Future<List<SearchHistoryModel>?> fetchSearchHistory() async {
    try {
      final response = await _dio.get('/search-history');
      final data = response.dataOrNull;
      if (data == null) return null;
      final map = data as Map<String, dynamic>;
      final items = map['items'] as List?;
      if (items == null) return null;
      return items
          .map<SearchHistoryModel>(
            (e) => SearchHistoryModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      AppUtil.debugLog('fetchSearchHistory: $e');
    }
    return null;
  }

  @override
  Future<bool> deleteSearchHistory(int searchHistoryId) async {
    try {
      final response = await _dio.delete('/search-history/$searchHistoryId');
      return response.isSuccess;
    } catch (e) {
      AppUtil.debugLog('deleteSearchHistory: $e');
    }
    return false;
  }
}
