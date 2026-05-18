import 'package:arttrip/core/api_endpoints.dart';
import 'package:arttrip/core/app_utils.dart';
import 'package:arttrip/core/network/dio_client.dart';
import 'package:arttrip/core/network/network_exceptions.dart';
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

  /// 푸시 알림 수신 여부 조회
  Future<bool?> fetchPushEnabled();

  /// 푸시 알림 수신 여부 변경
  Future<bool> updatePushEnabled(bool enabled);
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
        ApiEndpoints.me,
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
      final response = await _dio.patch(ApiEndpoints.meImage, data: formData);
      return response.isSuccess;
    } catch (e) {
      AppUtil.debugLog('uploadProfileImage: $e');
    }
    return false;
  }

  @override
  Future<bool> deleteProfileImage() async {
    try {
      final response = await _dio.delete(ApiEndpoints.meImage);
      return response.isSuccess;
    } catch (e) {
      AppUtil.debugLog('deleteProfileImage: $e');
    }
    return false;
  }

  @override
  Future<String?> updateNickname(String nickname) async {
    try {
      final response = await _dio.patch(
        ApiEndpoints.me,
        data: {'nickName': nickname},
      );
      return response.when(
        success: (_) => null,
        failure: (e) => _extractServerMessage(e) ?? '닉네임 변경에 실패했습니다.',
      );
    } catch (e) {
      AppUtil.debugLog('updateNickname: $e');
    }
    return '닉네임 변경에 실패했습니다.';
  }

  /// NetworkException의 응답 본문에서 서버 메시지(`message` 필드) 추출
  String? _extractServerMessage(NetworkException e) {
    final data = e.data;
    if (data is Map<String, dynamic>) {
      return data['message'] as String?;
    }
    return null;
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
        ApiEndpoints.reviewsAll,
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
      final response = await _dio.delete(ApiEndpoints.reviewsById(reviewId));
      return response.isSuccess;
    } catch (e) {
      AppUtil.debugLog('deleteReview: $e');
    }
    return false;
  }

  @override
  Future<RecentExhibitListResponseModel?> fetchRecentExhibits() async {
    try {
      final response = await _dio.get(ApiEndpoints.meRecentExhibits);
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

  @override
  Future<bool?> fetchPushEnabled() async {
    try {
      final response = await _dio.get(ApiEndpoints.mePushEnabled);
      final data = response.dataOrNull;
      if (data == null) return null;
      return (data as Map<String, dynamic>)['enabled'] as bool?;
    } catch (e) {
      AppUtil.debugLog('fetchPushEnabled: $e');
    }
    return null;
  }

  @override
  Future<bool> updatePushEnabled(bool enabled) async {
    try {
      final response = await _dio.patch(
        ApiEndpoints.mePushEnabled,
        data: {'enabled': enabled},
      );
      return response.isSuccess;
    } catch (e) {
      AppUtil.debugLog('updatePushEnabled: $e');
    }
    return false;
  }
}
