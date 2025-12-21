import 'package:arttrip/core/app_utils.dart';
import 'package:arttrip/core/network/dio_client.dart';
import 'package:arttrip/core/network/models/api_response.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_detail.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_review.dart';

abstract class ExhibitRepository {
  Future<ExhibitDetail?> fetchExhibitDetail(int exhibitId);
  Future<ExhibitReviewListResponse?> fetchExhibitReviews(
    int exhibitId, {
    String? cursor,
    int size = 10,
  });
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
  Future<ExhibitReviewListResponse?> fetchExhibitReviews(
    int exhibitId, {
    String? cursor,
    int size = 10,
  }) async {
    try {
      var queryParams = <String, dynamic>{'size': size};
      if (cursor != null) {
        queryParams['cursor'] = cursor;
      }

      var response = await _dio.get(
        '/reviews/$exhibitId/detail',
        queryParameters: queryParams,
      );
      var apiResponse = ApiResponse<ExhibitReviewListResponse>.fromJson(
        response.dataOrNull,
        (obj) =>
            ExhibitReviewListResponse.fromJson(obj as Map<String, dynamic>),
      );
      return apiResponse.result;
    } catch (e) {
      AppUtil.debugLog('fetchExhibitReviews: $e');
    }
    return null;
  }
}
