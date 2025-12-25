import 'package:arttrip/features/onboarding/data/keywords_repository.dart';
import 'package:arttrip/features/onboarding/data/models/keyword_model.dart';

class KeywordModelsRepositoryMockImpl implements KeywordModelsRepository {
  KeywordModelsRepositoryMockImpl();

  @override
  Future<List<KeywordModel>?> fetchAllKeywordModels() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return [
      // GENRE
      KeywordModel(keywordId: 1, name: '현대미술', type: 'GENRE'),
      KeywordModel(keywordId: 2, name: '근대미술', type: 'GENRE'),
      KeywordModel(keywordId: 3, name: '사진', type: 'GENRE'),
      KeywordModel(keywordId: 4, name: '설치미술', type: 'GENRE'),
      KeywordModel(keywordId: 5, name: '조각', type: 'GENRE'),
      KeywordModel(keywordId: 6, name: '회화', type: 'GENRE'),
      // STYLE
      KeywordModel(keywordId: 7, name: '감성적인', type: 'STYLE'),
      KeywordModel(keywordId: 8, name: '역동적인', type: 'STYLE'),
      KeywordModel(keywordId: 9, name: '몽환적인', type: 'STYLE'),
      KeywordModel(keywordId: 10, name: '고요한', type: 'STYLE'),
      KeywordModel(keywordId: 11, name: '실험적인', type: 'STYLE'),
    ];
  }

  @override
  Future<bool> saveKeywordModels(List<int> keywordIds) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return true;
  }
}
