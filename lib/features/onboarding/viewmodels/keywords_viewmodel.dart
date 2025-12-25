import 'package:arttrip/features/onboarding/data/keywords_repository.dart';
import 'package:arttrip/features/onboarding/data/models/keyword.dart';
import 'package:flutter/material.dart';

class KeywordsViewModel with ChangeNotifier {
  KeywordsViewModel(this.repository);
  final KeywordsRepository repository;

  List<Keyword> _genres = [];
  List<Keyword> _styles = [];
  final Set<int> _selectedKeywordIds = {};

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  List<Keyword> get genres => _genres;
  List<Keyword> get styles => _styles;
  Set<int> get selectedKeywordIds => _selectedKeywordIds;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  bool get canSubmit => _selectedKeywordIds.isNotEmpty;

  Future<void> fetchKeywords() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    var keywords = await repository.fetchAllKeywords();

    if (keywords != null) {
      _genres = keywords.where((k) => k.isGenre).toList();
      _styles = keywords.where((k) => k.isStyle).toList();
    } else {
      _errorMessage = '키워드를 불러오는데 실패했습니다';
    }

    _isLoading = false;
    notifyListeners();
  }

  void toggleKeyword(int keywordId) {
    if (_selectedKeywordIds.contains(keywordId)) {
      _selectedKeywordIds.remove(keywordId);
    } else {
      _selectedKeywordIds.add(keywordId);
    }
    notifyListeners();
  }

  bool isSelected(int keywordId) {
    return _selectedKeywordIds.contains(keywordId);
  }

  Future<bool> saveKeywords() async {
    if (!canSubmit || _isSaving) return false;

    _isSaving = true;
    notifyListeners();

    var success = await repository.saveKeywords(_selectedKeywordIds.toList());

    _isSaving = false;
    notifyListeners();

    return success;
  }
}
