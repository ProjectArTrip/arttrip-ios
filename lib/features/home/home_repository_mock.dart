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
        exhibitId: 13,
        title: '릴리킴 개인전 《 Ego Travla - between the Seen and the Unseen 》',
        posterUrl:
            'https://arttrip.s3.ap-northeast-2.amazonaws.com/3b368dcf-7_ego.png',
        status: 'ONGOING',
        exhibitPeriod: '2025-12-14 ~ 2025-12-27',
      ),
      ExhibitModel(
        exhibitId: 12,
        title: '눈이 타오르는 비탈',
        posterUrl:
            'https://arttrip.s3.ap-northeast-2.amazonaws.com/15e68d85-1_1765512462903.jpg',
        status: 'FINISHED',
        exhibitPeriod: '2025-12-13 ~ 2025-12-14',
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
        exhibitId: 13,
        title: '릴리킴 개인전 《 Ego Travla - between the Seen and the Unseen 》',
        posterUrl:
            'https://arttrip.s3.ap-northeast-2.amazonaws.com/3b368dcf-7_ego.png',
        status: 'ONGOING',
        exhibitPeriod: '2025-12-14 ~ 2025-12-27',
      ),
      ExhibitModel(
        exhibitId: 12,
        title: '눈이 타오르는 비탈',
        posterUrl:
            'https://arttrip.s3.ap-northeast-2.amazonaws.com/15e68d85-1_1765512462903.jpg',
        status: 'FINISHED',
        exhibitPeriod: '2025-12-13 ~ 2025-12-14',
      ),
    ];
  }

  @override
  Future<List<ExhibitModel>?> fetchPersonalizedExhibitions({
    required bool isDomestic,
    String? country,
    String? region,
  }) async {
    await Future.delayed(
      const Duration(milliseconds: AppConsts.mockLoadingDelayMillis),
    );
    // TODO: 실데이터 값으로 변경 예정
    return [
      ExhibitModel(
        exhibitId: 13,
        title: '릴리킴 개인전 《 Ego Travla - between the Seen and the Unseen 》',
        posterUrl:
            'https://arttrip.s3.ap-northeast-2.amazonaws.com/3b368dcf-7_ego.png',
        status: 'ONGOING',
        exhibitPeriod: '2025-12-14 ~ 2025-12-27',
      ),
      ExhibitModel(
        exhibitId: 12,
        title: '눈이 타오르는 비탈',
        posterUrl:
            'https://arttrip.s3.ap-northeast-2.amazonaws.com/15e68d85-1_1765512462903.jpg',
        status: 'FINISHED',
        exhibitPeriod: '2025-12-13 ~ 2025-12-14',
      ),
    ];
  }
}
