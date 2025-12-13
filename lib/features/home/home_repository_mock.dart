import 'package:arttrip/features/home/home_repository.dart';
import 'package:arttrip/shared/models/region_model.dart';

class HomeRepositoryMockImpl implements HomeRepository {
  HomeRepositoryMockImpl();

  @override
  Future<List<RegionModel>?> fetchOverseasCountries() async {
    await Future.delayed(const Duration(milliseconds: 100)); // 실제 딜레이 흉내
    return [
      RegionModel(id: 1, title: '프랑스'),
      RegionModel(id: 2, title: '독일'),
      RegionModel(id: 3, title: '이탈리아'),
      RegionModel(id: 4, title: '미국'),
      RegionModel(id: 5, title: '오스트리아'),
      RegionModel(id: 6, title: '일본'),
      RegionModel(id: 7, title: '중국'),
    ];
  }

  @override
  Future<List<RegionModel>?> fetchDomesticRegions() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return [
      RegionModel(id: 8, title: '서울'),
      RegionModel(id: 9, title: '경기'),
      RegionModel(id: 10, title: '충청'),
      RegionModel(id: 11, title: '강원'),
      RegionModel(id: 12, title: '전라'),
      RegionModel(id: 13, title: '경상'),
      RegionModel(id: 14, title: '제주'),
    ];
  }
}
