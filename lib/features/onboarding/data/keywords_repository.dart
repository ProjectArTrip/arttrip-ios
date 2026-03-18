import 'package:arttrip/core/app_utils.dart';
import 'package:arttrip/core/network/dio_client.dart';
import 'package:arttrip/features/onboarding/data/models/keyword_list_response_model.dart';
import 'package:arttrip/features/onboarding/data/models/keyword_model.dart';

abstract class KeywordModelsRepository {
  Future<List<KeywordModel>?> fetchAllKeywordModels();
  Future<List<KeywordModel>?> fetchUserKeywords();
  Future<bool> saveKeywordModels(List<String> keywords);
}

class KeywordModelsRepositoryImpl implements KeywordModelsRepository {
  KeywordModelsRepositoryImpl(this._dio);
  final DioClient _dio;

  @override
  Future<List<KeywordModel>?> fetchAllKeywordModels() async {
    try {
      var response = await _dio.get('/keyword/all');
      var data = response.dataOrNull;
      if (data == null) return null;
      var result = KeywordListResponseModel.fromJson(
        data as Map<String, dynamic>,
      );
      return result.keywords;
    } catch (e) {
      AppUtil.debugLog('fetchAllKeywordModels: $e');
    }
    return null;
  }

  @override
  Future<List<KeywordModel>?> fetchUserKeywords() async {
    try {
      var response = await _dio.get('/keyword');
      var data = response.dataOrNull;
      if (data == null) return null;
      var result = KeywordListResponseModel.fromJson(
        data as Map<String, dynamic>,
      );
      return result.keywords;
    } catch (e) {
      AppUtil.debugLog('fetchUserKeywords: $e');
    }
    return null;
  }

  @override
  Future<bool> saveKeywordModels(List<String> keywords) async {
    try {
      var response = await _dio.post('/keyword', data: {'keywords': keywords});
      return response.isSuccess;
    } catch (e) {
      AppUtil.debugLog('saveKeywordModels: $e');
    }
    return false;
  }
}
