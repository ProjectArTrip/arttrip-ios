import 'package:arttrip/core/app_utils.dart';
import 'package:arttrip/core/network/dio_client.dart';
import 'package:arttrip/shared/models/base_result_model.dart';
import 'package:arttrip/shared/models/region_model.dart';

abstract class HomeRepository {
  Future<List<RegionModel>?> fetchOverseasCountries();
  Future<List<RegionModel>?> fetchDomesticRegions();
}

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(this._dio);
  final DioClient _dio;

  @override
  Future<List<RegionModel>?> fetchOverseasCountries() async {
    try {
      var response = await _dio.get('/home/overseas');
      var model = BaseResultModel.fromJson(response.dataOrNull);
      return model.result.map<RegionModel>((e) => RegionModel.fromJson(e)).toList();
    } catch (e) {
      AppUtil.debugLog('fetchOverseasCountries: $e');
    }
    return null;
  }

  @override
  Future<List<RegionModel>?> fetchDomesticRegions() async {
    try {
      var response = await _dio.get('/home/domestic');
      var model = BaseResultModel.fromJson(response.dataOrNull);
      return model.result.map<RegionModel>((e) => RegionModel.fromJson(e)).toList();
    } catch (e) {
      AppUtil.debugLog('fetchDomesticRegions: $e');
    }
    return null;
  }
}
