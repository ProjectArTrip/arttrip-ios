import 'package:arttrip/core/app_utils.dart';
import 'package:arttrip/core/network/dio_client.dart';
import 'package:arttrip/features/onboarding/data/models/keyword_model.dart';
import 'package:arttrip/shared/models/base_result_model.dart';

abstract class KeywordModelsRepository {
  Future<List<KeywordModel>?> fetchAllKeywordModels();
  Future<bool> saveKeywordModels(List<int> keywordIds);
}

class KeywordModelsRepositoryImpl implements KeywordModelsRepository {
  KeywordModelsRepositoryImpl(this._dio);
  final DioClient _dio;

  @override
  Future<List<KeywordModel>?> fetchAllKeywordModels() async {
    try {
      var response = await _dio.get('/auth/allkeywords');
      var model = BaseResultModel.fromJson(response.dataOrNull);
      return model.result
          .map<KeywordModel>((e) => KeywordModel.fromJson(e))
          .toList();
    } catch (e) {
      AppUtil.debugLog('fetchAllKeywordModels: $e');
    }
    return null;
  }

  @override
  Future<bool> saveKeywordModels(List<int> keywordIds) async {
    try {
      var response = await _dio.post(
        '/auth/keywords',
        data: {'keywordIds': keywordIds},
      );
      var model = BaseResultModel.fromJson(response.dataOrNull);
      return model.isSuccess;
    } catch (e) {
      AppUtil.debugLog('saveKeywordModels: $e');
    }
    return false;
  }
}
