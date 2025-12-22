import 'package:arttrip/core/app_utils.dart';
import 'package:arttrip/core/network/api_result.dart';
import 'package:arttrip/core/network/dio_client.dart';
import 'package:arttrip/core/network/models/api_response.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_detail.dart';
import 'package:arttrip/shared/models/base_result_model.dart';

abstract class ExhibitRepository {
  Future<ExhibitDetail?> fetchExhibitDetail(int exhibitId);
  Future<void> updateFavoriteExhibit(int exhibitId, bool isFavorite);
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

  @override
  Future<void> updateFavoriteExhibit(int exhibitId, bool isFavorite) async {
    try {
      late ApiResult<dynamic> response;
      if (isFavorite) {
        response = await _dio.post('/favorites/$exhibitId');
      } else {
        response = await _dio.delete('/favorites/$exhibitId');
      }
      var model = BaseResultModel.fromJson(response.dataOrNull);
      AppUtil.debugLog('updateFavoriteExhibit get message: ${model.message}');
    } catch (e) {
      AppUtil.debugLog('updateFavoriteExhibit: $e');
    }
  }
}
