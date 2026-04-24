import 'package:arttrip/core/app_utils.dart';
import 'package:arttrip/core/network/dio_client.dart';
import 'package:arttrip/features/my/data/models/my_review_model.dart';
import 'package:arttrip/features/my/data/models/recent_exhibit_model.dart';
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

  /// 닉네임 변경 - 성공 시 null, 실패 시 에러 메시지 반환
  Future<String?> updateNickname(String nickname);

  /// 나의 리뷰 목록 조회
  Future<MyReviewListResponseModel?> fetchMyReviews({
    int? cursor,
    int size = 10,
    int width = 72,
    int height = 72,
  });

  /// 리뷰 삭제
  Future<bool> deleteReview(int reviewId);

  /// 최근 본 전시 목록 조회
  Future<RecentExhibitListResponseModel?> fetchRecentExhibits();

  /// fcm token 등록
  Future<void> registerFcmToken(String token);
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
      final response = await _dio.get(
        '/me',
        queryParameters: {'w': width, 'h': height},
      );
      final data = response.dataOrNull;
      if (data == null) return null;
      return UserProfileModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      AppUtil.debugLog('fetchUserProfile: $e');
    }
    return null;
  }

  @override
  Future<bool> uploadProfileImage(XFile image) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(image.path, filename: image.name),
      });
      final response = await _dio.patch('/me/image', data: formData);
      return response.isSuccess;
    } catch (e) {
      AppUtil.debugLog('uploadProfileImage: $e');
    }
    return false;
  }

  @override
  Future<bool> deleteProfileImage() async {
    try {
      final response = await _dio.delete('/me/image');
      return response.isSuccess;
    } catch (e) {
      AppUtil.debugLog('deleteProfileImage: $e');
    }
    return false;
  }

  @override
  Future<String?> updateNickname(String nickname) async {
    try {
      final response = await _dio.patch('/me', data: {'nickName': nickname});
      if (response.isSuccess) {
        return null; // 성공
      }
      return '닉네임 변경에 실패했습니다.';
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        return data['message'] as String? ?? '닉네임 변경에 실패했습니다.';
      }
      AppUtil.debugLog('updateNickname: $e');
    } catch (e) {
      AppUtil.debugLog('updateNickname: $e');
    }
    return '닉네임 변경에 실패했습니다.';
  }

  @override
  Future<MyReviewListResponseModel?> fetchMyReviews({
    int? cursor,
    int size = 10,
    int width = 72,
    int height = 72,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'size': size,
        'w': width,
        'h': height,
      };
      if (cursor != null) {
        queryParams['cursor'] = cursor;
      }
      final response = await _dio.get(
        '/reviews/all',
        queryParameters: queryParams,
      );
      final data = response.dataOrNull;
      if (data == null) return null;
      return MyReviewListResponseModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      AppUtil.debugLog('fetchMyReviews: $e');
    }
    return null;
  }

  @override
  Future<bool> deleteReview(int reviewId) async {
    try {
      final response = await _dio.delete('/reviews/$reviewId');
      return response.isSuccess;
    } catch (e) {
      AppUtil.debugLog('deleteReview: $e');
    }
    return false;
  }

  @override
  Future<RecentExhibitListResponseModel?> fetchRecentExhibits() async {
    try {
      final response = await _dio.get('/me/recent-exhibits');
      final data = response.dataOrNull;
      if (data == null) return null;
      return RecentExhibitListResponseModel.fromJson(
        data as Map<String, dynamic>,
      );
    } catch (e) {
      AppUtil.debugLog('fetchRecentExhibits: $e');
    }
    return null;
  }

  @override
  Future<void> registerFcmToken(String token) async {
    try {
      await _dio.post('/me/fcm-token', data: {'token': token});
      AppUtil.debugLog('registerFcmToken success: $token');
    } catch (e) {
      AppUtil.debugLog('registerFcmToken failed: $e');
    }
  }
}
