import 'package:arttrip/features/my/data/models/my_review_model.dart';
import 'package:arttrip/features/my/data/models/user_profile_model.dart';
import 'package:arttrip/features/my/data/my_repository.dart';
import 'package:image_picker/image_picker.dart';

class MyRepositoryMockImpl implements MyRepository {
  @override
  Future<UserProfileModel?> fetchUserProfile({
    int width = 100,
    int height = 100,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const UserProfileModel(
      nickName: '이유지',
      profileImage: null,
      email: 'test@example.com',
    );
  }

  @override
  Future<bool> uploadProfileImage(XFile image) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  @override
  Future<bool> deleteProfileImage() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  @override
  Future<String?> updateNickname(String nickname) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return null; // 성공
  }

  @override
  Future<MyReviewListResponseModel?> fetchMyReviews({
    String? cursor,
    int size = 10,
    int width = 72,
    int height = 72,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const MyReviewListResponseModel(
      reviews: [
        MyReviewModel(
          reviewId: 1,
          reviewTitle: 'Imagination in Bloom',
          visitDate: '2025-12-05',
          content: '가볍게 보기 좋아요!',
          thumbnailUrl: null,
          createdAt: '2025-12-05T10:00:00',
        ),
        MyReviewModel(
          reviewId: 2,
          reviewTitle: 'Imagination in Bloom',
          visitDate: '2025-07-29',
          content: '리뷰 내용입니다.',
          thumbnailUrl: null,
          createdAt: '2025-07-29T10:00:00',
        ),
        MyReviewModel(
          reviewId: 3,
          reviewTitle: 'Imagination in Bloom',
          visitDate: '2025-07-29',
          content: '리뷰 내용입니다.',
          thumbnailUrl: null,
          createdAt: '2025-07-29T10:00:00',
        ),
      ],
      nextCursor: null,
      hasNext: false,
      totalCount: 25,
    );
  }

  @override
  Future<bool> deleteReview(int reviewId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }
}
