import 'package:arttrip/core/app_consts.dart';
import 'package:arttrip/features/home/home_repository.dart';
import 'package:arttrip/shared/models/exhibit_model.dart';

class HomeRepositoryMockImpl implements HomeRepository {
  HomeRepositoryMockImpl();

  @override
  Future<List<String>?> fetchOverseasCountries() async {
    await Future.delayed(
      const Duration(milliseconds: AppConsts.mockLoadingDelayMillis),
    ); // 실제 딜레이 흉내
    return ['프랑스', '오스트리아', '중국', '일본', '독일', '대한민국'];
  }

  @override
  Future<List<String>?> fetchDomesticRegions() async {
    await Future.delayed(
      const Duration(milliseconds: AppConsts.mockLoadingDelayMillis),
    );
    return ['서울', '경기', '충청', '강원', '전라', '경상', '제주'];
  }

  @override
  Future<List<ExhibitModel>?> fetchTodayExhibitRecommendations({
    required bool isDomestic,
    String? country,
    String? region,
  }) async {
    await Future.delayed(
      const Duration(milliseconds: AppConsts.mockLoadingDelayMillis),
    );
    return [
      ExhibitModel(
        exhibitId: 7,
        title: 'Koki Tanaka: Provisional Community',
        posterUrl:
            'https://arttrip.s3.ap-northeast-2.amazonaws.com/9dc3a4e7-6_fmi.png',
        status: 'ONGOING',
        exhibitPeriod: '2025-09-27 ~ 2026-01-05',
      ),
      ExhibitModel(
        exhibitId: 8,
        title: 'In Sight! Lovis Corinth',
        posterUrl:
            'https://arttrip.s3.ap-northeast-2.amazonaws.com/01d632f0-4_fmi.png',
        status: 'UPCOMING',
        exhibitPeriod: '2025-07-18 ~ 2026-01-26',
      ),
      ExhibitModel(
        exhibitId: 1,
        title: 'Matisse – Soulages',
        posterUrl:
            'https://arttrip.s3.ap-northeast-2.amazonaws.com/01d632f0-4_fmi.png',
        status: 'ONGOING',
        exhibitPeriod: '2025-10-18 ~ 2026-03-09',
      ),
    ];
  }

  @override
  Future<List<String>?> fetchGenres() async {
    await Future.delayed(
      const Duration(milliseconds: AppConsts.mockLoadingDelayMillis),
    );
    return [
      '공예',
      '근대 미술',
      '디지털/미디어 아트',
      '사진',
      '설치 미술',
      '순수 미술',
      '역사/고전 미술',
      '조각',
      '팝아트',
      '현대 미술',
      '회화',
    ];
  }

  @override
  Future<List<ExhibitModel>?> fetchExhibitionsByGenre({
    required bool isDomestic,
    String? country,
    String? region,
    required String genre,
  }) async {
    await Future.delayed(
      const Duration(milliseconds: AppConsts.mockLoadingDelayMillis),
    );
    // TODO: 실데이터 값으로 변경 예정
    return [
      ExhibitModel(
        exhibitId: 7,
        title: 'Koki Tanaka: Provisional Community',
        posterUrl:
            'https://arttrip.s3.ap-northeast-2.amazonaws.com/9dc3a4e7-6_fmi.png',
        status: 'ONGOING',
        exhibitPeriod: '2025-09-27 ~ 2026-01-05',
      ),
      ExhibitModel(
        exhibitId: 8,
        title: 'In Sight! Lovis Corinth',
        posterUrl:
            'https://arttrip.s3.ap-northeast-2.amazonaws.com/01d632f0-4_fmi.png',
        status: 'UPCOMING',
        exhibitPeriod: '2025-07-18 ~ 2026-01-26',
      ),
      ExhibitModel(
        exhibitId: 1,
        title: 'Matisse – Soulages',
        posterUrl:
            'https://arttrip.s3.ap-northeast-2.amazonaws.com/01d632f0-4_fmi.png',
        status: 'ONGOING',
        exhibitPeriod: '2025-10-18 ~ 2026-03-09',
      ),
    ];
  }
}
