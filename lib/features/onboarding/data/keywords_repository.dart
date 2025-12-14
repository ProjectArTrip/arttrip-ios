import 'package:arttrip/core/app_utils.dart';
import 'package:arttrip/core/network/dio_client.dart';
import 'package:arttrip/features/onboarding/data/models/keyword.dart';
import 'package:arttrip/shared/models/base_result_model.dart';

abstract class KeywordsRepository {
  Future<List<Keyword>?> fetchAllKeywords();
  Future<bool> saveKeywords(List<int> keywordIds);
}

class KeywordsRepositoryImpl implements KeywordsRepository {
  KeywordsRepositoryImpl(this._dio);
  final DioClient _dio;

  @override
  Future<List<Keyword>?> fetchAllKeywords() async {
    try {
      var response = await _dio.get('/auth/allkeywords');
      var model = BaseResultModel.fromJson(response.dataOrNull);
      return model.result.map<Keyword>((e) => Keyword.fromJson(e)).toList();
    } catch (e) {
      AppUtil.debugLog('fetchAllKeywords: $e');
    }
    return null;
  }

  @override
  Future<bool> saveKeywords(List<int> keywordIds) async {
    try {
      var response = await _dio.post(
        '/auth/keywords',
        data: {'keywordIds': keywordIds},
      );
      var model = BaseResultModel.fromJson(response.dataOrNull);
      return model.isSuccess;
    } catch (e) {
      AppUtil.debugLog('saveKeywords: $e');
    }
    return false;
  }
}
