import 'package:arttrip/features/onboarding/data/keywords_repository.dart';
import 'package:arttrip/features/onboarding/data/models/keyword.dart';

class KeywordsRepositoryMockImpl implements KeywordsRepository {
  KeywordsRepositoryMockImpl();

  @override
  Future<List<Keyword>?> fetchAllKeywords() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return [
      // GENRE
      Keyword(keywordId: 1, name: '현대미술', type: 'GENRE'),
      Keyword(keywordId: 2, name: '근대미술', type: 'GENRE'),
      Keyword(keywordId: 3, name: '사진', type: 'GENRE'),
      Keyword(keywordId: 4, name: '설치미술', type: 'GENRE'),
      Keyword(keywordId: 5, name: '조각', type: 'GENRE'),
      Keyword(keywordId: 6, name: '회화', type: 'GENRE'),
      // STYLE
      Keyword(keywordId: 7, name: '감성적인', type: 'STYLE'),
      Keyword(keywordId: 8, name: '역동적인', type: 'STYLE'),
      Keyword(keywordId: 9, name: '몽환적인', type: 'STYLE'),
      Keyword(keywordId: 10, name: '고요한', type: 'STYLE'),
      Keyword(keywordId: 11, name: '실험적인', type: 'STYLE'),
    ];
  }

  @override
  Future<bool> saveKeywords(List<int> keywordIds) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return true;
  }
}
