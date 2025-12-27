import 'package:arttrip/core/app_utils.dart';
import 'package:arttrip/core/network/dio_client.dart';
import 'package:arttrip/core/network/models/api_response.dart';
import 'package:arttrip/features/my/data/models/user_profile_model.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

abstract class MyRepository {
  Future<UserProfileModel?> fetchUserProfile({
    int width = 100,
    int height = 100,
  });
  Future<bool> uploadProfileImage(XFile image);
  Future<bool> deleteProfileImage();
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
        queryParameters: {'w': width, 'h': height},
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

  @override
  Future<bool> uploadProfileImage(XFile image) async {
    try {
      var formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(image.path, filename: image.name),
      });
      var response = await _dio.post('/my/profile', data: formData);
      var apiResponse = ApiResponse<String>.fromJson(
        response.dataOrNull,
        (obj) => obj as String,
      );
      return apiResponse.isSuccess;
    } catch (e) {
      AppUtil.debugLog('uploadProfileImage: $e');
    }
    return false;
  }

  @override
  Future<bool> deleteProfileImage() async {
    try {
      var response = await _dio.delete('/my/profile');
      var apiResponse = ApiResponse<void>.fromJson(response.dataOrNull, (_) {});
      return apiResponse.isSuccess;
    } catch (e) {
      AppUtil.debugLog('deleteProfileImage: $e');
    }
    return false;
  }
}
