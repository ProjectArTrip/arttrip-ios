import 'package:arttrip/features/exhibit/data/exhibit_repository.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_detail.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_review.dart';
import 'package:arttrip/features/exhibit/data/models/favorite_check_result.dart';
import 'package:arttrip/features/exhibit/data/models/review_create_result.dart';
import 'package:image_picker/image_picker.dart';

class ExhibitRepositoryMockImpl implements ExhibitRepository {
  ExhibitRepositoryMockImpl();

  // Mock 즐겨찾기 상태 저장
  final Set<int> _favorites = {};

  @override
  Future<ExhibitDetail?> fetchExhibitDetail(int exhibitId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return ExhibitDetail(
      exhibitId: exhibitId,
      title: '메이지·다이쇼 시대 예술의 장식적 취향을 통해 본 아르누보와 그 주변 환경',
      description:
          '본 전시는 메이지·다이쇼 시대(1868-1926)의 일본 미술과 유럽 아르누보 운동 사이의 상호 영향을 탐구합니다. '
          '당시 일본의 전통 공예와 서양의 새로운 예술 양식이 어떻게 융합되었는지, '
          '그리고 이러한 교류가 현대 디자인에 미친 영향을 살펴봅니다.',
      posterUrl: 'https://picsum.photos/400/600',
      ticketUrl: 'https://example.com/ticket',
      exhibitPeriod: '2025.06.07 - 2025.09.14',
      status: 'ONGOING',
      hallName: '다케히사 유메지 미술관',
      hallAddress: '서울 강남구 역삼로 000 10층',
      hallOpeningHours: 'AM 10:30 - PM 19:00',
      hallPhone: '000 - 123 - 1234',
    );
  }

  @override
  Future<ExhibitReviewListResponse?> fetchExhibitReviews(
    int exhibitId, {
    String? cursor,
    int size = 10,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    var startIndex = cursor != null ? int.parse(cursor) : 0;
    var mockReviews = List.generate(
      size,
      (index) => ExhibitReview(
        reviewId: startIndex + index + 1,
        visitDate: '2025-08-30',
        content: '감성적인거 좋아하는 사람들 추천합니다 :)',
        thumbnailUrl:
            index % 3 == 0
                ? 'https://picsum.photos/200/200?random=${startIndex + index}'
                : '',
        nickname: '전시조아${startIndex + index + 1}',
      ),
    );

    var nextIndex = startIndex + size;
    var hasNext = nextIndex < 30;

    return ExhibitReviewListResponse(
      reviews: mockReviews,
      nextCursor: hasNext ? nextIndex.toString() : null,
      hasNext: hasNext,
      reviewTotalCount: 30,
    );
  }

  @override
  Future<ReviewCreateResult?> createReview({
    required int exhibitId,
    required List<XFile> images,
    required String date,
    required String content,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return ReviewCreateResult(
      reviewId: DateTime.now().millisecondsSinceEpoch,
      exhibitId: exhibitId,
      visitDate: date,
      content: content,
      images:
          images
              .asMap()
              .entries
              .map(
                (e) => ReviewImage(
                  id: e.key,
                  url: 'https://picsum.photos/200/200?random=${e.key}',
                ),
              )
              .toList(),
      createdAt: DateTime.now().toIso8601String(),
    );
  }

  @override
  Future<FavoriteCheckResult?> checkFavorite(int exhibitId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return FavoriteCheckResult(isFavorite: _favorites.contains(exhibitId));
  }

  @override
  Future<bool> addFavorite(int exhibitId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _favorites.add(exhibitId);
    return true;
  }

  @override
  Future<bool> removeFavorite(int exhibitId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _favorites.remove(exhibitId);
    return true;
  }
}
