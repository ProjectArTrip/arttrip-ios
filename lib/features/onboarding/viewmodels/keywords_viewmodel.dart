import 'package:arttrip/features/onboarding/data/keywords_repository.dart';
import 'package:arttrip/features/onboarding/data/models/keyword_model.dart';
import 'package:flutter/material.dart';

class KeywordModelsViewModel with ChangeNotifier {
  KeywordModelsViewModel(this.repository);
  final KeywordModelsRepository repository;

  List<KeywordModel> _genres = [];
  List<KeywordModel> _styles = [];
  final Set<int> _selectedKeywordModelIds = {};

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  List<KeywordModel> get genres => _genres;
  List<KeywordModel> get styles => _styles;
  Set<int> get selectedKeywordModelIds => _selectedKeywordModelIds;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  bool get canSubmit => _selectedKeywordModelIds.isNotEmpty;

  Future<void> fetchKeywordModels() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    var keywords = await repository.fetchAllKeywordModels();

    if (keywords != null) {
      _genres = keywords.where((k) => k.isGenre).toList();
      _styles = keywords.where((k) => k.isStyle).toList();
    } else {
      _errorMessage = '키워드를 불러오는데 실패했습니다';
    }

    _isLoading = false;
    notifyListeners();
  }

  void toggleKeywordModel(int keywordId) {
    if (_selectedKeywordModelIds.contains(keywordId)) {
      _selectedKeywordModelIds.remove(keywordId);
    } else {
      _selectedKeywordModelIds.add(keywordId);
    }
    notifyListeners();
  }

  bool isSelected(int keywordId) {
    return _selectedKeywordModelIds.contains(keywordId);
  }

  Future<bool> saveKeywordModels() async {
    if (!canSubmit || _isSaving) return false;

    _isSaving = true;
    notifyListeners();

    var success = await repository.saveKeywordModels(_selectedKeywordModelIds.toList());

    _isSaving = false;
    notifyListeners();

    return success;
  }
}
