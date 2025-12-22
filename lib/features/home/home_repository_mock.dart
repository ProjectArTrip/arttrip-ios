import 'package:arttrip/core/app_consts.dart';
import 'package:arttrip/core/app_urls.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_model.dart';
import 'package:arttrip/features/home/home_repository.dart';

class HomeRepositoryMockImpl implements HomeRepository {
  @override
  Future<List<String>?> fetchOverseasCountries() async {
    await Future.delayed(
      const Duration(milliseconds: AppConsts.mockLoadingDelayMs),
    ); // 실제 딜레이 흉내
    return ['프랑스', '오스트리아', '중국', '일본', '독일', '대한민국'];
  }

  @override
  Future<List<String>?> fetchDomesticRegions() async {
    await Future.delayed(
      const Duration(milliseconds: AppConsts.mockLoadingDelayMs),
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
  Future<List<String>?> fetchGenres() async {
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
  Future<List<ExhibitModel>?> fetchExhibitsByGenre({
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
  Future<List<ExhibitModel>?> fetchPersonalizedExhibits({
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
  Future<List<ExhibitModel>?> fetchWeeklyExhibitsBySelectedDate({
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
}
