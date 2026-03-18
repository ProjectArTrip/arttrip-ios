import 'package:arttrip/features/exhibit/data/exhibit_repository.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_model.dart';
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
}
