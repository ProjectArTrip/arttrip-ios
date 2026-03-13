import 'dart:convert';

import 'package:arttrip/core/app_utils.dart';
import 'package:arttrip/core/network/api_result.dart';
import 'package:arttrip/core/network/dio_client.dart';
import 'package:arttrip/core/network/models/api_response.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_detail_model.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_review_model.dart';
import 'package:arttrip/features/exhibit/data/models/favorite_check_result.dart';
import 'package:arttrip/features/exhibit/data/models/review_create_result.dart';
import 'package:arttrip/shared/models/base_result_model.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

abstract class ExhibitRepository {
  Future<ExhibitDetailModel?> fetchExhibitDetailModel(int exhibitId);
  Future<ExhibitReviewListResponseModel?> fetchExhibitReviewModels(
    int exhibitId, {
    String? cursor,
    int size = 10,
  });
  Future<ReviewCreateResult?> createReview({
    required int exhibitId,
    required List<XFile> images,
    required String date,
    required String content,
  });
  Future<FavoriteCheckResult?> checkFavorite(int exhibitId);
  Future<bool> addFavorite(int exhibitId);
  Future<bool> removeFavorite(int exhibitId);
  Future<void> updateFavoriteExhibit(int exhibitId, bool isFavorite);
}

class ExhibitRepositoryImpl implements ExhibitRepository {
  ExhibitRepositoryImpl(this._dio);
  final DioClient _dio;

  @override
  Future<ExhibitDetailModel?> fetchExhibitDetailModel(int exhibitId) async {
    try {
      var response = await _dio.get('/exhibit/$exhibitId');
      var data = response.dataOrNull;
      if (data == null) return null;
      var apiResponse = ApiResponse<ExhibitDetailModel>.fromJson(
        data,
        (obj) => ExhibitDetailModel.fromJson(obj as Map<String, dynamic>),
      );
      return apiResponse.result;
    } catch (e) {
      AppUtil.debugLog('fetchExhibitDetailModel: $e');
    }
    return null;
  }

  @override
  Future<ExhibitReviewListResponseModel?> fetchExhibitReviewModels(
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
      var data = response.dataOrNull;
      if (data == null) return null;
      var apiResponse = ApiResponse<ExhibitReviewListResponseModel>.fromJson(
        data,
        (obj) => ExhibitReviewListResponseModel.fromJson(
          obj as Map<String, dynamic>,
        ),
      );
      return apiResponse.result;
    } catch (e) {
      AppUtil.debugLog('fetchExhibitReviewModels: $e');
    }
    return null;
  }

  @override
  Future<ReviewCreateResult?> createReview({
    required int exhibitId,
    required List<XFile> images,
    required String date,
    required String content,
  }) async {
    try {
      var requestJson = jsonEncode({'date': date, 'content': content});
      var formData = FormData.fromMap({
        'request': MultipartFile.fromString(
          requestJson,
          contentType: DioMediaType.parse('application/json'),
        ),
      });

      for (var file in images) {
        formData.files.add(
          MapEntry(
            'images',
            await MultipartFile.fromFile(file.path, filename: file.name),
          ),
        );
      }

      var response = await _dio.post('/reviews/$exhibitId', data: formData);
      var data = response.dataOrNull;
      if (data == null) return null;
      var apiResponse = ApiResponse<ReviewCreateResult>.fromJson(
        data,
        (obj) => ReviewCreateResult.fromJson(obj as Map<String, dynamic>),
      );
      return apiResponse.result;
    } catch (e) {
      AppUtil.debugLog('createReview: $e');
    }
    return null;
  }

  @override
  Future<FavoriteCheckResult?> checkFavorite(int exhibitId) async {
    try {
      var response = await _dio.get('/favorites/check/$exhibitId');
      var data = response.dataOrNull;
      if (data == null) return null;
      var apiResponse = ApiResponse<FavoriteCheckResult>.fromJson(
        data,
        (obj) => FavoriteCheckResult.fromJson(obj as Map<String, dynamic>),
      );
      return apiResponse.result;
    } catch (e) {
      AppUtil.debugLog('checkFavorite: $e');
    }
    return null;
  }

  @override
  Future<bool> addFavorite(int exhibitId) async {
    try {
      var response = await _dio.post('/favorites/$exhibitId');
      return response.isSuccess;
    } catch (e) {
      AppUtil.debugLog('addFavorite: $e');
    }
    return false;
  }

  @override
  Future<bool> removeFavorite(int exhibitId) async {
    try {
      var response = await _dio.delete('/favorites/$exhibitId');
      return response.isSuccess;
    } catch (e) {
      AppUtil.debugLog('removeFavorite: $e');
    }
    return false;
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
      var data = response.dataOrNull;
      if (data == null) return;
      var model = BaseResultModel.fromJson(data);
      AppUtil.debugLog('updateFavoriteExhibit get message: ${model.message}');
    } catch (e) {
      AppUtil.debugLog('updateFavoriteExhibit: $e');
    }
  }
}
