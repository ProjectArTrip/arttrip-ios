import 'package:arttrip/features/exhibit/data/models/exhibit_model.dart';
import 'package:arttrip/features/onboarding/data/models/keyword_model.dart';
import 'package:arttrip/features/search/data/models/search_history_model.dart';
import 'package:arttrip/features/search/data/search_repository.dart';

class SearchRepositoryMockImpl implements SearchRepository {
  final List<ExhibitModel> _mockExhibits = [
    ExhibitModel(
      exhibitId: 1,
      title: 'Imagination in Bloom',
      posterUrl: 'https://picsum.photos/200/300',
      status: 'ONGOING',
      exhibitPeriod: '2025.07.29 ~ 2025.08.10',
      hallName: '오르세 미술관',
      countryName: '프랑스',
    ),
    ExhibitModel(
      exhibitId: 2,
      title: '현대미술의 흐름',
      posterUrl: 'https://picsum.photos/200/301',
      status: 'ONGOING',
      exhibitPeriod: '2025.06.07 ~ 2025.09.14',
      hallName: '서울시립미술관',
      regionName: '서울',
    ),
    ExhibitModel(
      exhibitId: 3,
      title: '도자기의 미학',
      posterUrl: 'https://picsum.photos/200/302',
      status: 'UPCOMING',
      exhibitPeriod: '2025.08.01 ~ 2025.10.31',
      hallName: '경기도자미술관',
      regionName: '경기',
    ),
  ];

  final List<SearchHistoryModel> _mockHistory = [
    SearchHistoryModel(
      searchHistoryId: 1,
      content: '독일',
      createdAt: '2026-03-20',
    ),
    SearchHistoryModel(
      searchHistoryId: 2,
      content: '팝아트',
      createdAt: '2026-03-19',
    ),
    SearchHistoryModel(
      searchHistoryId: 3,
      content: '현대 전시',
      createdAt: '2026-03-18',
    ),
    SearchHistoryModel(
      searchHistoryId: 4,
      content: '디지털아트',
      createdAt: '2026-03-17',
    ),
  ];

  @override
  Future<List<ExhibitModel>?> searchExhibits(String query) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final lowerQuery = query.toLowerCase();
    return _mockExhibits.where((e) {
      return (e.title?.toLowerCase().contains(lowerQuery) ?? false) ||
          (e.hallName?.toLowerCase().contains(lowerQuery) ?? false) ||
          (e.countryName?.toLowerCase().contains(lowerQuery) ?? false) ||
          (e.regionName?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  @override
  Future<List<KeywordModel>?> fetchRecommendedKeywords() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      KeywordModel(keywordId: 1, name: '사진', type: 'GENRE'),
      KeywordModel(keywordId: 2, name: '유럽 전시', type: 'STYLE'),
      KeywordModel(keywordId: 3, name: '도자기', type: 'STYLE'),
      KeywordModel(keywordId: 4, name: '현대', type: 'GENRE'),
      KeywordModel(keywordId: 5, name: '아시아', type: 'STYLE'),
    ];
  }

  @override
  Future<List<SearchHistoryModel>?> fetchSearchHistory() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_mockHistory);
  }

  @override
  Future<bool> deleteSearchHistory(int searchHistoryId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _mockHistory.removeWhere((e) => e.searchHistoryId == searchHistoryId);
    return true;
  }
}
