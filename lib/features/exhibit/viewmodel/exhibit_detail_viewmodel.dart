import 'package:arttrip/features/exhibit/data/exhibit_repository.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_detail.dart';
import 'package:arttrip/shared/widgets/async_view.dart';
import 'package:flutter/foundation.dart';

class ExhibitDetailViewModel with ChangeNotifier {
  ExhibitDetailViewModel(this._repository);
  final ExhibitRepository _repository;

  AsyncState<ExhibitDetail> _exhibitState = const AsyncState.loading();

  AsyncState<ExhibitDetail> get exhibitState => _exhibitState;

  /// 전시 상세 정보 로드
  Future<void> fetchExhibitDetail(int exhibitId) async {
    _exhibitState = const AsyncState.loading();
    notifyListeners();

    var exhibit = await _repository.fetchExhibitDetail(exhibitId);
    if (exhibit != null) {
      _exhibitState = AsyncState.success(exhibit);
    } else {
      _exhibitState = const AsyncState.error(
        error: '전시 정보를 불러올 수 없습니다.',
      );
    }

    notifyListeners();
  }
}
