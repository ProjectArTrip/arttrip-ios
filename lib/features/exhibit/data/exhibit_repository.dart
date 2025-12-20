import 'package:arttrip/core/app_utils.dart';
import 'package:arttrip/core/network/dio_client.dart';
import 'package:arttrip/core/network/models/api_response.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_detail.dart';

abstract class ExhibitRepository {
  Future<ExhibitDetail?> fetchExhibitDetail(int exhibitId);
}

class ExhibitRepositoryImpl implements ExhibitRepository {
  ExhibitRepositoryImpl(this._dio);
  final DioClient _dio;

  @override
  Future<ExhibitDetail?> fetchExhibitDetail(int exhibitId) async {
    try {
      var response = await _dio.get('/exhibit/$exhibitId');
      var apiResponse = ApiResponse<ExhibitDetail>.fromJson(
        response.dataOrNull,
        (obj) => ExhibitDetail.fromJson(obj as Map<String, dynamic>),
      );
      return apiResponse.result;
    } catch (e) {
      AppUtil.debugLog('fetchExhibitDetail: $e');
    }
    return null;
  }
}
