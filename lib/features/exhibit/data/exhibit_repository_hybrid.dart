import 'package:arttrip/core/app_consts.dart';
import 'package:arttrip/features/exhibit/data/exhibit_repository.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_detail_model.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_review_model.dart';
import 'package:arttrip/features/exhibit/data/models/favorite_check_result.dart';
import 'package:arttrip/features/exhibit/data/models/review_create_result.dart';
import 'package:image_picker/image_picker.dart';

class ExhibitRepositoryHybrid implements ExhibitRepository {
  ExhibitRepositoryHybrid({required this.mock, required this.api});

  final ExhibitRepository mock;
  final ExhibitRepositoryImpl api;

  @override
  Future<ExhibitDetailModel?> fetchExhibitDetailModel(int exhibitId) {
    if (AppConsts.useMock) {
      return mock.fetchExhibitDetailModel(exhibitId);
    }
    return api.fetchExhibitDetailModel(exhibitId);
  }

  @override
  Future<ExhibitReviewListResponseModel?> fetchExhibitReviewModels(
    int exhibitId, {
    String? cursor,
    int size = 10,
  }) {
    if (AppConsts.useMock) {
      return mock.fetchExhibitReviewModels(exhibitId, cursor: cursor, size: size);
    }
    return api.fetchExhibitReviewModels(exhibitId, cursor: cursor, size: size);
  }

  @override
  Future<ReviewCreateResult?> createReview({
    required int exhibitId,
    required List<XFile> images,
    required String date,
    required String content,
  }) {
    if (AppConsts.useMock) {
      return mock.createReview(
        exhibitId: exhibitId,
        images: images,
        date: date,
        content: content,
      );
    }
    return api.createReview(
      exhibitId: exhibitId,
      images: images,
      date: date,
      content: content,
    );
  }

  @override
  Future<FavoriteCheckResult?> checkFavorite(int exhibitId) {
    if (AppConsts.useMock) {
      return mock.checkFavorite(exhibitId);
    }
    return api.checkFavorite(exhibitId);
  }

  @override
  Future<bool> addFavorite(int exhibitId) {
    if (AppConsts.useMock) {
      return mock.addFavorite(exhibitId);
    }
    return api.addFavorite(exhibitId);
  }

  @override
  Future<bool> removeFavorite(int exhibitId) {
    if (AppConsts.useMock) {
      return mock.removeFavorite(exhibitId);
    }
    return api.removeFavorite(exhibitId);
  }

  @override
  Future<void> updateFavoriteExhibit(int exhibitId, bool isFavorite) {
    if (AppConsts.useMock) {
      return mock.updateFavoriteExhibit(exhibitId, isFavorite);
    }
    return api.updateFavoriteExhibit(exhibitId, isFavorite);
  }
}
