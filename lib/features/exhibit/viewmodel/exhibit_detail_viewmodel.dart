import 'package:arttrip/features/exhibit/data/exhibit_repository.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_detail.dart';
import 'package:flutter/foundation.dart';

class ExhibitDetailViewModel with ChangeNotifier {
  ExhibitDetailViewModel(this._repository);
  final ExhibitRepository _repository;

  ExhibitDetail? _exhibit;
  bool _isLoading = false;
  String? _errorMessage;

  ExhibitDetail? get exhibit => _exhibit;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// 전시 상세 정보 로드
  Future<void> fetchExhibitDetail(int exhibitId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _exhibit = await _repository.fetchExhibitDetail(exhibitId);
    if (_exhibit == null) {
      _errorMessage = '전시 정보를 불러올 수 없습니다.';
    }

    _isLoading = false;
    notifyListeners();
  }
}
