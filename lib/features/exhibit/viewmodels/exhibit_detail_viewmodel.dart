import 'package:arttrip/features/exhibit/data/exhibit_repository.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_detail_model.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_review_model.dart';
import 'package:arttrip/shared/widgets/async_view.dart';
import 'package:flutter/foundation.dart';

class ExhibitDetailModelViewModel with ChangeNotifier {
  ExhibitDetailModelViewModel(this._repository);
  final ExhibitRepository _repository;

  // 전시 상세 상태
  AsyncState<ExhibitDetailModel> _exhibitState = const AsyncState.loading();
  AsyncState<ExhibitDetailModel> get exhibitState => _exhibitState;

  // 리뷰 목록 상태
  AsyncState<List<ExhibitReviewModel>> _reviewsState = const AsyncState.loading();
  AsyncState<List<ExhibitReviewModel>> get reviewsState => _reviewsState;

  // 리뷰 페이지네이션 상태
  String? _nextCursor;
  bool _hasNextReview = true;
  int _reviewTotalCount = 0;
  bool _isLoadingMore = false;

  int get reviewTotalCount => _reviewTotalCount;
  bool get hasMoreReviews => _hasNextReview;
  bool get isLoadingMoreReviews => _isLoadingMore;

  // 즐겨찾기 상태
  bool _isFavorite = false;
  bool _isFavoriteLoading = false;

  bool get isFavorite => _isFavorite;
  bool get isFavoriteLoading => _isFavoriteLoading;

  /// 전시 상세 정보 로드
  Future<void> fetchExhibitDetailModel(int exhibitId) async {
    _exhibitState = const AsyncState.loading();
    // 이전 전시의 리뷰 데이터 초기화
    _reviewsState = const AsyncState.loading();
    _reviewTotalCount = 0;
    notifyListeners();

    var exhibit = await _repository.fetchExhibitDetailModel(exhibitId);
    if (exhibit != null) {
      _exhibitState = AsyncState.success(exhibit);
    } else {
      _exhibitState = const AsyncState.error(error: '전시 정보를 불러올 수 없습니다.');
    }

    notifyListeners();
  }

  /// 리뷰 목록 로드 (초기)
  Future<void> fetchExhibitReviewModels(int exhibitId) async {
    _reviewsState = const AsyncState.loading();
    _nextCursor = null;
    _hasNextReview = true;
    notifyListeners();

    var response = await _repository.fetchExhibitReviewModels(exhibitId);
    if (response != null) {
      _reviewsState = AsyncState.success(response.reviews);
      _nextCursor = response.nextCursor;
      _hasNextReview = response.hasNext;
      _reviewTotalCount = response.reviewTotalCount;
    } else {
      _reviewsState = const AsyncState.error(error: '리뷰를 불러올 수 없습니다.');
    }

    notifyListeners();
  }

  /// 리뷰 추가 로드 (페이지네이션)
  Future<void> fetchMoreReviews(int exhibitId) async {
    if (_isLoadingMore || !_hasNextReview) return;

    _isLoadingMore = true;
    notifyListeners();

    var response = await _repository.fetchExhibitReviewModels(
      exhibitId,
      cursor: _nextCursor,
    );

    if (response != null) {
      var currentReviews = _reviewsState.data ?? [];
      _reviewsState = AsyncState.success([
        ...currentReviews,
        ...response.reviews,
      ]);
      _nextCursor = response.nextCursor;
      _hasNextReview = response.hasNext;
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  /// 즐겨찾기 상태 확인
  Future<void> checkFavorite(int exhibitId) async {
    var result = await _repository.checkFavorite(exhibitId);
    _isFavorite = result?.isFavorite ?? false;
    notifyListeners();
  }

  /// 즐겨찾기 토글
  Future<void> toggleFavorite(int exhibitId) async {
    if (_isFavoriteLoading) return;

    _isFavoriteLoading = true;
    notifyListeners();

    bool success;
    if (_isFavorite) {
      success = await _repository.removeFavorite(exhibitId);
    } else {
      success = await _repository.addFavorite(exhibitId);
    }

    if (success) {
      _isFavorite = !_isFavorite;
    }

    _isFavoriteLoading = false;
    notifyListeners();
  }
}
