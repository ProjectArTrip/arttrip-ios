import 'package:arttrip/core/app_utils.dart';
import 'package:arttrip/core/network/dio_client.dart';
import 'package:arttrip/core/network/models/api_response.dart';
import 'package:arttrip/features/my/data/models/user_profile_model.dart';

abstract class MyRepository {
  Future<UserProfileModel?> fetchUserProfile({int width = 100, int height = 100});
}

class MyRepositoryImpl implements MyRepository {
  MyRepositoryImpl(this._dio);
  final DioClient _dio;

  @override
  Future<UserProfileModel?> fetchUserProfile({
    int width = 100,
    int height = 100,
  }) async {
    try {
      var response = await _dio.get(
        '/my/mypage',
        queryParameters: {'width': width, 'height': height},
      );
      var apiResponse = ApiResponse<UserProfileModel>.fromJson(
        response.dataOrNull,
        (obj) => UserProfileModel.fromJson(obj as Map<String, dynamic>),
      );
      return apiResponse.result;
    } catch (e) {
      AppUtil.debugLog('fetchUserProfile: $e');
    }
    return null;
  }
}
