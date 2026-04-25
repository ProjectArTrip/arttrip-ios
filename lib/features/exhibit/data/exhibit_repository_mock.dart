import 'package:arttrip/core/app_consts.dart';
import 'package:arttrip/features/exhibit/data/exhibit_repository.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_detail_model.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_filter_model.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_model.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_review_model.dart';
import 'package:arttrip/features/exhibit/data/models/favorite_filter_model.dart';
import 'package:arttrip/features/exhibit/data/models/review_create_result.dart';
import 'package:image_picker/image_picker.dart';

class ExhibitRepositoryMockImpl implements ExhibitRepository {
  ExhibitRepositoryMockImpl();

  // Mock 즐겨찾기 상태 저장
  final Set<int> _favorites = {};

  @override
  Future<ExhibitDetailModel?> fetchExhibitDetailModel(int exhibitId) async {
    await Future.delayed(
      const Duration(milliseconds: AppConsts.mockLoadingDelayMs),
    );

    return ExhibitDetailModel(
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
      hallLatitude: 48.8606, // 루브르 박물관 테스트 좌표
      hallLongitude: 2.3376,
    );
  }

  @override
  Future<ExhibitReviewListResponseModel?> fetchExhibitReviewModels(
    int exhibitId, {
    int? cursor,
    int size = 10,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final startIndex = cursor ?? 0;
    final mockReviews = List.generate(
      size,
      (index) => ExhibitReviewModel(
        reviewId: startIndex + index + 1,
        visitDate: '2025-08-30',
        content: '감성적인거 좋아하는 사람들 추천합니다 :)',
        photoUrls: index % 3 == 0
            ? ['https://picsum.photos/200/200?random=${startIndex + index}']
            : [],
        reviewer: '전시조아${startIndex + index + 1}',
      ),
    );

    final nextIndex = startIndex + size;
    final hasNext = nextIndex < 30;

    return ExhibitReviewListResponseModel(
      reviews: mockReviews,
      nextCursor: hasNext ? nextIndex : null,
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
      visitDate: date,
      content: content,
      images: images
          .asMap()
          .entries
          .map(
            (e) => ReviewImage(
              reviewImageId: e.key,
              imageUrl: 'https://picsum.photos/200/200?random=${e.key}',
            ),
          )
          .toList(),
    );
  }

  @override
  Future<ReviewCreateResult?> fetchReviewDetail(int reviewId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return ReviewCreateResult(
      reviewId: reviewId,
      visitDate: '2025-08-30',
      content: '감성적인거 좋아하는 사람들 추천합니다 :)',
      images: [
        const ReviewImage(
          reviewImageId: 1,
          imageUrl: 'https://picsum.photos/200/200?random=1',
        ),
        const ReviewImage(
          reviewImageId: 2,
          imageUrl: 'https://picsum.photos/200/200?random=2',
        ),
      ],
    );
  }

  @override
  Future<bool> updateReview({
    required int reviewId,
    required List<XFile> newImages,
    required String date,
    required String content,
    required List<int> deleteImageIds,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
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

  @override
  Future<void> updateFavoriteExhibit(int exhibitId, bool isFavorite) async {
    await Future.delayed(
      const Duration(milliseconds: AppConsts.mockLoadingDelayMs),
    );
    if (isFavorite) {
      _favorites.add(exhibitId);
    } else {
      _favorites.remove(exhibitId);
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
    await Future.delayed(const Duration(milliseconds: 500));
    return ExhibitFilterModel(
      exhibits: List.generate(
        size ?? 10,
        (index) => ExhibitModel(
          exhibitId: cursor != null ? cursor + index + 1 : index + 1,
          title: '전시 제목 ${cursor != null ? cursor + index + 1 : index + 1}',
          posterUrl:
              'https://picsum.photos/400/600?random=${cursor != null ? cursor + index + 1 : index + 1}',
          exhibitPeriod: '2025.06.07 - 2025.09.14',
          status: 'ONGOING',
        ),
      ),
      hasNext: (cursor ?? 0) + (size ?? 10) < 30,
      nextCursor: (cursor ?? 0) + (size ?? 10),
      exhibitTotalCount: 30,
    );
  }

  @override
  Future<FavoriteFilterModel> fetchFavoriteFilters({
    required int cursor,
    required int size,
    String? country,
    String? region,
    required String sortType,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return FavoriteFilterModel(
      favorites: [],
      hasNext: false,
    );
  }
}
