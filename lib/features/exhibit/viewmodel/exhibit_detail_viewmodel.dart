import 'package:arttrip/features/exhibit/data/exhibit_repository.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_detail.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_review.dart';
import 'package:arttrip/shared/widgets/async_view.dart';
import 'package:flutter/foundation.dart';

class ExhibitDetailViewModel with ChangeNotifier {
  ExhibitDetailViewModel(this._repository);
  final ExhibitRepository _repository;

  // 전시 상세 상태
  AsyncState<ExhibitDetail> _exhibitState = const AsyncState.loading();
  AsyncState<ExhibitDetail> get exhibitState => _exhibitState;

  // 리뷰 목록 상태
  AsyncState<List<ExhibitReview>> _reviewsState = const AsyncState.loading();
  AsyncState<List<ExhibitReview>> get reviewsState => _reviewsState;

  // 리뷰 페이지네이션 상태
  String? _nextCursor;
  bool _hasNextReview = true;
  int _reviewTotalCount = 0;
  bool _isLoadingMore = false;

  int get reviewTotalCount => _reviewTotalCount;
  bool get hasMoreReviews => _hasNextReview;
  bool get isLoadingMoreReviews => _isLoadingMore;

  /// 전시 상세 정보 로드
  Future<void> fetchExhibitDetail(int exhibitId) async {
    _exhibitState = const AsyncState.loading();
    notifyListeners();

    var exhibit = await _repository.fetchExhibitDetail(exhibitId);
    if (exhibit != null) {
      _exhibitState = AsyncState.success(exhibit);
    } else {
      _exhibitState = const AsyncState.error(error: '전시 정보를 불러올 수 없습니다.');
    }

    notifyListeners();
  }

  /// 리뷰 목록 로드 (초기)
  Future<void> fetchExhibitReviews(int exhibitId) async {
    _reviewsState = const AsyncState.loading();
    _nextCursor = null;
    _hasNextReview = true;
    notifyListeners();

    var response = await _repository.fetchExhibitReviews(exhibitId);
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

    var response = await _repository.fetchExhibitReviews(
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
}
