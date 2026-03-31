import 'package:arttrip/core/app_utils.dart';
import 'package:arttrip/features/exhibit/data/exhibit_repository.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_model.dart';
import 'package:arttrip/shared/widgets/async_view.dart';
import 'package:flutter/material.dart';

class ExhibitViewModel with ChangeNotifier {
  ExhibitViewModel(this._exhibitRepository);
  final ExhibitRepository _exhibitRepository;

  final Map<int, bool> _favoriteMap = {};
  AsyncState<List<ExhibitModel>> _exhibitFilters = const AsyncState.loading();

  AsyncState<List<ExhibitModel>> get exhibitFilters => _exhibitFilters;

  /// 즐겨찾기 여부 조회
  bool isFavorite(int? exhibitId) {
    return _favoriteMap[exhibitId] ?? false;
  }

  /// 필터링된 전시 리스트 초기화
  void initExhibitFilters() {
    _exhibitFilters = const AsyncState.loading();
  }

  /// ExhibitModel 리스트로 즐겨찾기 상태 초기화
  /// (이미 존재하는 값은 덮어쓰지 않음)
  void initializeFromExhibits(List<ExhibitModel> exhibits) {
    for (var exhibit in exhibits) {
      final id = exhibit.exhibitId;
      if (id == null) continue;

      _favoriteMap.putIfAbsent(id, () => exhibit.favorite);
    }
  }

  /// 즐겨찾기 상태 업데이트
  void updateFavoriteExhibit(int? exhibitId, bool isFavorite) {
    if (exhibitId == null) return;

    _exhibitRepository.updateFavoriteExhibit(exhibitId, isFavorite);
    _favoriteMap[exhibitId] = isFavorite;
    notifyListeners();
  }

  /// 전시 조건 필터 전체 조회
  Future<void> getExhibitFilters({
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
    try {
      _exhibitFilters = const AsyncState.loading();
      notifyListeners();

      final response = await _exhibitRepository.fetchExhibitFilters(
        isDomestic: isDomestic,
        cursor: cursor,
        size: size,
        country: isDomestic ? null : country,
        region: isDomestic ? region : null,
        startDate: startDate,
        endDate: endDate,
        genres: genres,
        styles: styles,
        sortType: sortType,
      );
      _exhibitFilters = AsyncState.success(response.exhibits);
    } catch (e) {
      AppUtil.debugLog('getExhibitFilters error: $e');
      _exhibitFilters = const AsyncState.error();
    }
    notifyListeners();
  }
}
