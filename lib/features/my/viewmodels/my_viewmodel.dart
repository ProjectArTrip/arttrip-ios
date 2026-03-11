import 'package:arttrip/features/my/data/models/my_review_model.dart';
import 'package:arttrip/features/my/data/models/user_profile_model.dart';
import 'package:arttrip/features/my/data/my_repository.dart';
import 'package:arttrip/shared/widgets/async_view.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class MyViewModel with ChangeNotifier {
  MyViewModel(this._repository);
  final MyRepository _repository;

  // 프로필 상태
  AsyncState<UserProfileModel> _profileState = const AsyncState.loading();
  AsyncState<UserProfileModel> get profileState => _profileState;

  // 리뷰 상태
  AsyncState<List<MyReviewModel>> _reviewsState = const AsyncState.loading();
  String? _reviewNextCursor;
  bool _hasNextReview = true;
  bool _isLoadingMoreReviews = false;
  int _reviewTotalCount = 0;

  AsyncState<List<MyReviewModel>> get reviewsState => _reviewsState;
  bool get hasNextReview => _hasNextReview;
  bool get isLoadingMoreReviews => _isLoadingMoreReviews;
  int get reviewTotalCount => _reviewTotalCount;

  Future<void> fetchUserProfile() async {
    _profileState = const AsyncState.loading();
    notifyListeners();

    var profile = await _repository.fetchUserProfile();
    if (profile != null) {
      _profileState = AsyncState.success(profile);
    } else {
      _profileState = const AsyncState.error(error: '프로필을 불러올 수 없습니다.');
    }
    notifyListeners();
  }

  void reset() {
    _profileState = const AsyncState.loading();
    notifyListeners();
    fetchUserProfile();
  }

  Future<bool> uploadProfileImage(XFile image) async {
    var result = await _repository.uploadProfileImage(image);
    if (result) {
      await fetchUserProfile();
    }
    return result;
  }

  Future<bool> deleteProfileImage() async {
    var result = await _repository.deleteProfileImage();
    if (result) {
      await fetchUserProfile();
    }
    return result;
  }

  /// 닉네임 변경 - 성공 시 null, 실패 시 에러 메시지 반환
  Future<String?> updateNickname(String nickname) async {
    var error = await _repository.updateNickname(nickname);
    if (error == null) {
      await fetchUserProfile();
    }
    return error;
  }

  // ===== 리뷰 관련 메서드 =====

  Future<void> fetchMyReviews() async {
    _reviewsState = const AsyncState.loading();
    _reviewNextCursor = null;
    _hasNextReview = true;
    notifyListeners();

    var response = await _repository.fetchMyReviews();
    if (response != null) {
      _reviewsState = AsyncState.success(response.reviews);
      _reviewNextCursor = response.nextCursor;
      _hasNextReview = response.hasNext;
      _reviewTotalCount = response.totalCount;
    } else {
      _reviewsState = const AsyncState.error(error: '리뷰를 불러올 수 없습니다.');
    }
    notifyListeners();
  }

  Future<void> fetchMoreReviews() async {
    if (_isLoadingMoreReviews || !_hasNextReview) return;

    _isLoadingMoreReviews = true;
    notifyListeners();

    var response = await _repository.fetchMyReviews(cursor: _reviewNextCursor);
    if (response != null) {
      var currentReviews = _reviewsState.data ?? [];
      _reviewsState = AsyncState.success([
        ...currentReviews,
        ...response.reviews,
      ]);
      _reviewNextCursor = response.nextCursor;
      _hasNextReview = response.hasNext;
    }

    _isLoadingMoreReviews = false;
    notifyListeners();
  }

  void resetReviews() {
    _reviewsState = const AsyncState.loading();
    _reviewNextCursor = null;
    _hasNextReview = true;
    _isLoadingMoreReviews = false;
    _reviewTotalCount = 0;
  }

  Future<bool> deleteReview(int reviewId) async {
    var success = await _repository.deleteReview(reviewId);
    if (success) {
      // 삭제 성공 시 리스트에서 제거
      var currentReviews = _reviewsState.data ?? [];
      _reviewsState = AsyncState.success(
        currentReviews.where((r) => r.reviewId != reviewId).toList(),
      );
      _reviewTotalCount = _reviewTotalCount > 0 ? _reviewTotalCount - 1 : 0;
      notifyListeners();
    }
    return success;
  }
}
