import 'dart:convert';

import 'package:arttrip/core/app_utils.dart';
import 'package:arttrip/core/network/api_result.dart';
import 'package:arttrip/core/network/dio_client.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_detail_model.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_filter_model.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_review_model.dart';
import 'package:arttrip/features/exhibit/data/models/favorite_filter_model.dart';
import 'package:arttrip/features/exhibit/data/models/review_create_result.dart';
import 'package:arttrip/shared/models/base_result_model.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

abstract class ExhibitRepository {
  Future<ExhibitDetailModel?> fetchExhibitDetailModel(int exhibitId);
  Future<ExhibitReviewListResponseModel?> fetchExhibitReviewModels(
    int exhibitId, {
    int? cursor,
    int size = 10,
  });
  Future<ReviewCreateResult?> createReview({
    required int exhibitId,
    required List<XFile> images,
    required String date,
    required String content,
  });
  Future<ReviewCreateResult?> fetchReviewDetail(int reviewId);
  Future<bool> updateReview({
    required int reviewId,
    required List<XFile> newImages,
    required String date,
    required String content,
    required List<int> deleteImageIds,
  });
  Future<bool> addFavorite(int exhibitId);
  Future<bool> removeFavorite(int exhibitId);
  Future<void> updateFavoriteExhibit(int exhibitId, bool isFavorite);

  /// 전시 조건 필터 전체 조회
  Future<ExhibitFilterModel> fetchExhibitFilters({
    required bool isDomestic,
    int? cursor,
    int? size,
    String? country,
    String? region,
    String? startDate,
    String? endDate,
    String? genres,
    String? styles,
    String? sortType,
  });

  /// 즐겨찾기 목록 조회
  Future<FavoriteFilterModel> fetchFavoriteFilters({
    required int cursor,
    required int size,
    String? country,
    String? region,
    required String sortType,
  });
}

class ExhibitRepositoryImpl implements ExhibitRepository {
  ExhibitRepositoryImpl(this._dio);
  final DioClient _dio;

  @override
  Future<ExhibitDetailModel?> fetchExhibitDetailModel(int exhibitId) async {
    try {
      final response = await _dio.get('/exhibits/$exhibitId');
      final data = response.dataOrNull;
      if (data == null) return null;
      return ExhibitDetailModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      AppUtil.debugLog('fetchExhibitDetailModel: $e');
    }
    return null;
  }

  @override
  Future<ExhibitReviewListResponseModel?> fetchExhibitReviewModels(
    int exhibitId, {
    int? cursor,
    int size = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{'size': size};
      if (cursor != null) {
        queryParams['cursor'] = cursor;
      }

      final response = await _dio.get(
        '/reviews/exhibit/$exhibitId',
        queryParameters: queryParams,
      );
      final data = response.dataOrNull;
      if (data == null) return null;
      return ExhibitReviewListResponseModel.fromJson(
        data as Map<String, dynamic>,
      );
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
      final requestJson = jsonEncode({'date': date, 'content': content});
      final formData = FormData.fromMap({
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

      final response = await _dio.post(
        '/reviews/$exhibitId',
        data: formData,
        options: Options(extra: {'requestJson': requestJson}),
      );
      final data = response.dataOrNull;
      if (data == null) return null;
      return ReviewCreateResult.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      AppUtil.debugLog('createReview: $e');
    }
    return null;
  }

  @override
  Future<ReviewCreateResult?> fetchReviewDetail(int reviewId) async {
    try {
      final response = await _dio.get('/reviews/$reviewId');
      final data = response.dataOrNull;
      if (data == null) return null;
      return ReviewCreateResult.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      AppUtil.debugLog('fetchReviewDetail: $e');
    }
    return null;
  }

  @override
  Future<bool> updateReview({
    required int reviewId,
    required List<XFile> newImages,
    required String date,
    required String content,
    required List<int> deleteImageIds,
  }) async {
    try {
      final requestJson = jsonEncode({
        'date': date,
        'content': content,
        'deleteImageIds': deleteImageIds,
      });
      final formData = FormData.fromMap({
        'request': MultipartFile.fromString(
          requestJson,
          contentType: DioMediaType.parse('application/json'),
        ),
      });

      for (var file in newImages) {
        formData.files.add(
          MapEntry(
            'images',
            await MultipartFile.fromFile(file.path, filename: file.name),
          ),
        );
      }

      final response = await _dio.patch(
        '/reviews/$reviewId',
        data: formData,
        options: Options(extra: {'requestJson': requestJson}),
      );
      return response.isSuccess;
    } catch (e) {
      AppUtil.debugLog('updateReview: $e');
    }
    return false;
  }

  @override
  Future<bool> addFavorite(int exhibitId) async {
    try {
      final response = await _dio.post('/favorites/$exhibitId');
      return response.isSuccess;
    } catch (e) {
      AppUtil.debugLog('addFavorite: $e');
    }
    return false;
  }

  @override
  Future<bool> removeFavorite(int exhibitId) async {
    try {
      final response = await _dio.delete('/favorites/$exhibitId');
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
      final data = response.dataOrNull;
      if (data == null) return;
      final model = BaseResultModel.fromJson(data);
      AppUtil.debugLog('updateFavoriteExhibit get message: ${model.message}');
    } catch (e) {
      AppUtil.debugLog('updateFavoriteExhibit: $e');
    }
  }

  @override
  Future<ExhibitFilterModel> fetchExhibitFilters({
    required bool isDomestic,
    int? cursor,
    int? size,
    String? country,
    String? region,
    String? startDate,
    String? endDate,
    String? genres,
    String? styles,
    String? sortType,
  }) async {
    try {
      final queryParams = {
        if (!isDomestic) 'country': country,
        if (isDomestic) 'region': region,
        'startDate': ?startDate,
        'endDate': ?endDate,
        'isDomestic': isDomestic,
        'genres': ?genres,
        'styles': ?styles,
        'sortType': ?sortType,
        'cursor': ?cursor,
        'size': ?size,
      };

      final response = await _dio.get(
        '/exhibits',
        queryParameters: queryParams,
      );

      final data = response.dataOrNull;
      if (data == null) throw Exception('No data in response');

      return ExhibitFilterModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      AppUtil.debugLog('fetchExhibitFilters: $e');
      rethrow;
    }
  }

  @override
  Future<FavoriteFilterModel> fetchFavoriteFilters({
    required int cursor,
    required int size,
    String? country,
    String? region,
    required String sortType,
  }) async {
    try {
      final queryParams = {
        'country': country,
        'region': region,
        'sortType': sortType,
        'cursor': cursor,
        'size': size,
      };

      final response = await _dio.get(
        '/favorites',
        queryParameters: queryParams,
      );

      final data = response.dataOrNull;
      if (data == null) throw Exception('No data in response');

      return FavoriteFilterModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      AppUtil.debugLog('fetchFavoriteFilters: $e');
      rethrow;
    }
  }
}
