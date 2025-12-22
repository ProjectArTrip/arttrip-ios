import 'package:arttrip/core/app_consts.dart';
import 'package:arttrip/features/exhibit/data/exhibit_repository.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_detail.dart';

class ExhibitRepositoryMockImpl implements ExhibitRepository {
  ExhibitRepositoryMockImpl();

  @override
  Future<ExhibitDetail?> fetchExhibitDetail(int exhibitId) async {
    await Future.delayed(
      const Duration(milliseconds: AppConsts.mockLoadingDelayMs),
    );

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
  Future<String?> updateFavoriteExhibit(int exhibitId, bool isFavorite) async {
    await Future.delayed(
      const Duration(milliseconds: AppConsts.mockLoadingDelayMs),
    );
    return null;
  }
}
