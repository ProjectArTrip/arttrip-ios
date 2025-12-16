import 'package:arttrip/features/home/home_repository.dart';

class HomeRepositoryMockImpl implements HomeRepository {
  HomeRepositoryMockImpl();

  @override
  Future<List<String>?> fetchOverseasCountries() async {
    await Future.delayed(const Duration(milliseconds: 100)); // 실제 딜레이 흉내
    return [
      '프랑스',
      '오스트리아',
      '중국',
      '일본',
      '독일',
      '대한민국',
    ];
  }

  @override
  Future<List<String>?> fetchDomesticRegions() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return [
      '서울',
      '경기',
      '충청',
      '강원',
      '전라',
      '경상',
      '제주',
    ];
  }
}
