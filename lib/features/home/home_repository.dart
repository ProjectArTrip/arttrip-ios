import 'package:arttrip/core/app_utils.dart';
import 'package:arttrip/core/network/dio_client.dart';
import 'package:arttrip/shared/models/base_result_model.dart';

abstract class HomeRepository {
  Future<List<String>?> fetchOverseasCountries();
  Future<List<String>?> fetchDomesticRegions();
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
}
