import 'package:arttrip/core/app_consts.dart';
import 'package:arttrip/core/app_urls.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_filter_model.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_model.dart';
import 'package:arttrip/features/home/data/models/curation_model.dart';
import 'package:arttrip/features/home/home_repository.dart';
import 'package:arttrip/shared/models/region_model.dart';

class HomeRepositoryMockImpl implements HomeRepository {
  @override
  Future<List<String>> fetchOverseasCountries() async {
    await Future.delayed(
      const Duration(milliseconds: AppConsts.mockLoadingDelayMs),
    ); // 실제 딜레이 흉내
    return ['프랑스', '오스트리아', '중국', '일본', '독일', '대한민국'];
  }

  @override
  Future<List<RegionModel>> fetchDomesticRegions() async {
    await Future.delayed(
      const Duration(milliseconds: AppConsts.mockLoadingDelayMs),
    );
    return [
      RegionModel(region: '서울', imageUrl: AppUrls.posterUrlMock),
      RegionModel(region: '경기', imageUrl: AppUrls.posterUrlMock),
      RegionModel(region: '전라', imageUrl: AppUrls.posterUrlMock),
      RegionModel(region: '제주', imageUrl: AppUrls.posterUrlMock),
      RegionModel(region: '경상', imageUrl: AppUrls.posterUrlMock),
      RegionModel(region: '강원', imageUrl: AppUrls.posterUrlMock),
    ];
  }

  @override
  Future<List<ExhibitModel>> fetchTodayExhibitRecommendations({
    required bool isDomestic,
    String? country,
    String? region,
  }) async {
    await Future.delayed(
      const Duration(milliseconds: AppConsts.mockLoadingDelayMs),
    );
    return [
      ExhibitModel(
        exhibitId: 13,
        title: '릴리킴 개인전 《 Ego Travla - between the Seen and the Unseen 》',
        posterUrl: AppUrls.posterUrlMock,
        status: 'ONGOING',
        exhibitPeriod: '2025.12.14 - 2025.12.27',
        hallName: '프리미엄 월넛홀',
        countryName: '프랑스',
      ),
      ExhibitModel(
        exhibitId: 12,
        title: '눈이 타오르는 비탈',
        posterUrl: AppUrls.posterUrlMock,
        status: 'ENDING_SOON',
        exhibitPeriod: '2025.12.14 - 2025.12.27',
        hallName: '프리미엄 월넛홀',
        countryName: '일본',
      ),
    ];
  }

  @override
  Future<List<String>> fetchGenres() async {
    await Future.delayed(
      const Duration(milliseconds: AppConsts.mockLoadingDelayMs),
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
  Future<List<ExhibitModel>> fetchExhibitsByGenre({
    required bool isDomestic,
    String? country,
    String? region,
    required String genre,
  }) async {
    await Future.delayed(
      const Duration(milliseconds: AppConsts.mockLoadingDelayMs),
    );
    return [
      ExhibitModel(
        exhibitId: 13,
        title: '릴리킴 개인전 《 Ego Travla - between the Seen and the Unseen 》',
        posterUrl: AppUrls.posterUrlMock,
        status: 'ONGOING',
        exhibitPeriod: '2025.12.14 - 2025.12.27',
        hallName: '프리미엄 월넛홀',
      ),
      ExhibitModel(
        exhibitId: 12,
        title: '눈이 타오르는 비탈',
        posterUrl: AppUrls.posterUrlMock,
        status: 'ENDING_SOON',
        exhibitPeriod: '2025.12.14 - 2025.12.27',
        hallName: '프리미엄 월넛홀',
      ),
    ];
  }

  @override
  Future<List<ExhibitModel>> fetchPersonalizedExhibits({
    required bool isDomestic,
    String? country,
    String? region,
  }) async {
    await Future.delayed(
      const Duration(milliseconds: AppConsts.mockLoadingDelayMs),
    );
    return [
      ExhibitModel(
        exhibitId: 13,
        title: '릴리킴 개인전 《 Ego Travla - between the Seen and the Unseen 》',
        posterUrl: AppUrls.posterUrlMock,
        status: 'ONGOING',
        exhibitPeriod: '2025.12.14 - 2025.12.27',
        hallName: '프리미엄 월넛홀',
        countryName: '프랑스',
      ),
      ExhibitModel(
        exhibitId: 12,
        title: '눈이 타오르는 비탈',
        posterUrl: AppUrls.posterUrlMock,
        status: 'ENDING_SOON',
        exhibitPeriod: '2025.12.14 - 2025.12.27',
        hallName: '프리미엄 월넛홀',
        countryName: '일본',
      ),
    ];
  }

  @override
  Future<List<ExhibitModel>> fetchWeeklyExhibitsBySelectedDate({
    required bool isDomestic,
    String? country,
    String? region,
    required String date,
  }) async {
    await Future.delayed(
      const Duration(milliseconds: AppConsts.mockLoadingDelayMs),
    );
    return [
      ExhibitModel(
        exhibitId: 13,
        title: '릴리킴 개인전 《 Ego Travla - between the Seen and the Unseen 》',
        posterUrl: AppUrls.posterUrlMock,
        status: 'ONGOING',
        exhibitPeriod: '2025.12.14 - 2025.12.27',
        hallName: '프리미엄 월넛홀',
      ),
      ExhibitModel(
        exhibitId: 12,
        title: '눈이 타오르는 비탈',
        posterUrl: AppUrls.posterUrlMock,
        status: 'UPCOMING',
        exhibitPeriod: '2025.12.14 - 2025.12.27',
        hallName: '프리미엄 월넛홀',
      ),
    ];
  }

  @override
  Future<CurationModel> fetchCurations({
    required bool isDomestic,
    String? country,
    String? region,
  }) async {
    await Future.delayed(
      const Duration(milliseconds: AppConsts.mockLoadingDelayMs),
    );
    return CurationModel(
      curationId: 0,
      title: '추천 전시',
      subtitle: '당신을 위한 맞춤 전시 큐레이션',
      exhibits: [
        ExhibitModel(
          exhibitId: 13,
          title: '릴리킴 개인전 《 Ego Travla - between the Seen and the Unseen 》',
          posterUrl: AppUrls.posterUrlMock,
          status: 'ONGOING',
          exhibitPeriod: '2025.12.14 - 2025.12.27',
          hallName: '프리미엄 월넛홀',
          countryName: '프랑스',
        ),
        ExhibitModel(
          exhibitId: 12,
          title: '눈이 타오르는 비탈',
          posterUrl: AppUrls.posterUrlMock,
          status: 'UPCOMING',
          exhibitPeriod: '2025.12.14 - 2025.12.27',
          hallName: '프리미엄 월넛홀',
          countryName: '일본',
        ),
      ],
    );
  }

  @override
  Future<ExhibitFilterModel> fetchCurationDetail({
    required String curationId,
    required int cursor,
    required int size,
  }) async {
    await Future.delayed(
      const Duration(milliseconds: AppConsts.mockLoadingDelayMs),
    );
    return ExhibitFilterModel(
      hasNext: true,
      nextCursor: 0,
      exhibitTotalCount: 2,
      title: '추천 전시',
      exhibits: [
        ExhibitModel(
          exhibitId: 13,
          title: '릴리킴 개인전 《 Ego Travla - between the Seen and the Unseen 》',
          posterUrl: AppUrls.posterUrlMock,
          status: 'ONGOING',
          exhibitPeriod: '2025.12.14 - 2025.12.27',
          hallName: '프리미엄 월넛홀',
          countryName: '프랑스',
        ),
        ExhibitModel(
          exhibitId: 12,
          title: '눈이 타오르는 비탈',
          posterUrl: AppUrls.posterUrlMock,
          status: 'UPCOMING',
          exhibitPeriod: '2025.12.14 - 2025.12.27',
          hallName: '프리미엄 월넛홀',
          countryName: '일본',
        ),
      ],
    );
  }
}
