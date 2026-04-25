import 'package:arttrip/core/app_utils.dart';
import 'package:arttrip/features/exhibit/data/exhibit_repository.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_filter_model.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_model.dart';
import 'package:arttrip/features/exhibit/data/models/favorite_filter_model.dart';
import 'package:flutter/material.dart';

class ExhibitViewModel with ChangeNotifier {
  ExhibitViewModel(this._exhibitRepository);
  final ExhibitRepository _exhibitRepository;

  final Map<int, bool> _favoriteMap = {};

  /// 즐겨찾기 여부 조회
  bool isFavorite(int? exhibitId) {
    return _favoriteMap[exhibitId] ?? false;
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
  ///
  /// 로딩 처리는 각 화면에서 로딩 변수로 처리합니다.
  ///
  /// null: API 호출 실패
  Future<ExhibitFilterModel?> getExhibitFilters({
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
      return response;
    } catch (e) {
      AppUtil.debugLog('getExhibitFilters error: $e');
      return null;
    }
  }

  /// 즐겨찾기 전체 조회
  ///
  /// 로딩 처리는 각 화면에서 로딩 변수로 처리합니다.
  ///
  /// null: API 호출 실패
  Future<FavoriteFilterModel?> getFavoriteFilters({
    required int cursor,
    required int size,
    String? country,
    String? region,
    required String sortType,
  }) async {
    try {
      final response = await _exhibitRepository.fetchFavoriteFilters(
        cursor: cursor,
        size: size,
        country: country,
        region: region,
        sortType: sortType,
      );
      return response;
    } catch (e) {
      AppUtil.debugLog('getFavoriteFilters error: $e');
      return null;
    }
  }
}
