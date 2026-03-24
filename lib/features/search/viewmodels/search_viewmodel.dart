import 'package:arttrip/features/exhibit/data/models/exhibit_model.dart';
import 'package:arttrip/features/onboarding/data/models/keyword_model.dart';
import 'package:arttrip/features/search/data/models/search_history_model.dart';
import 'package:arttrip/features/search/data/search_repository.dart';
import 'package:arttrip/shared/widgets/async_view.dart';
import 'package:flutter/foundation.dart';

/// 검색 ViewModel
class SearchViewModel extends ChangeNotifier {
  SearchViewModel(this._repository);
  final SearchRepository _repository;

  // === State ===
  List<SearchHistoryModel> _recentSearches = [];
  AsyncState<List<KeywordModel>> _recommendedKeywords =
      const AsyncState.loading();
  AsyncState<List<ExhibitModel>> _searchResults = const AsyncState.success([]);
  String _query = '';
  bool _isSearchMode = false;

  // === Getters ===
  List<SearchHistoryModel> get recentSearches =>
      List.unmodifiable(_recentSearches);
  AsyncState<List<KeywordModel>> get recommendedKeywords =>
      _recommendedKeywords;
  AsyncState<List<ExhibitModel>> get searchResults => _searchResults;
  String get query => _query;
  bool get isSearchMode => _isSearchMode;

  // === Actions ===

  /// 초기 로드 (최근 검색어 + 추천 검색어)
  Future<void> init() async {
    final results = await Future.wait([
      _repository.fetchSearchHistory(),
      _repository.fetchRecommendedKeywords(),
    ]);

    final history = results[0] as List<SearchHistoryModel>?;
    final keywords = results[1] as List<KeywordModel>?;

    _recentSearches = history ?? [];

    if (keywords != null) {
      _recommendedKeywords = AsyncState.success(keywords);
    } else {
      _recommendedKeywords = const AsyncState.error();
    }

    notifyListeners();
  }

  /// 검색 실행
  Future<void> search(String query) async {
    _query = query;
    _isSearchMode = true;
    _searchResults = const AsyncState.loading();
    notifyListeners();

    final results = await _repository.searchExhibits(query);
    if (results != null) {
      _searchResults = AsyncState.success(results);
    } else {
      _searchResults = const AsyncState.error();
    }
    notifyListeners();
  }

  /// 검색 초기화 (초기 화면으로)
  void clearSearch() {
    _query = '';
    _isSearchMode = false;
    _searchResults = const AsyncState.success([]);
    notifyListeners();
  }

  /// 최근 검색어 개별 삭제
  Future<void> removeRecentSearch(int searchHistoryId) async {
    _recentSearches.removeWhere((e) => e.searchHistoryId == searchHistoryId);
    notifyListeners();
    await _repository.deleteSearchHistory(searchHistoryId);
  }

  /// 최근 검색어 전체 삭제
  Future<void> clearAllRecentSearches() async {
    final ids = _recentSearches.map((e) => e.searchHistoryId).toList();
    _recentSearches.clear();
    notifyListeners();
    for (final id in ids) {
      await _repository.deleteSearchHistory(id);
    }
  }

  /// 상태 초기화
  void reset({bool notify = true}) {
    _recentSearches = [];
    _recommendedKeywords = const AsyncState.loading();
    _searchResults = const AsyncState.success([]);
    _query = '';
    _isSearchMode = false;
    if (notify) notifyListeners();
  }
}
