import 'package:freezed_annotation/freezed_annotation.dart';

part 'keyword_model.freezed.dart';
part 'keyword_model.g.dart';

/// 키워드 모델
///
/// 전시 장르(GENRE) 또는 전시 스타일(STYLE)
@freezed
abstract class KeywordModel with _$KeywordModel {
  const KeywordModel._();

  factory KeywordModel({
    required int keywordId,
    required String name,
    required String type, // "GENRE" | "STYLE"
  }) = _KeywordModel;

  factory KeywordModel.fromJson(Map<String, dynamic> json) =>
      _$KeywordModelFromJson(json);

  bool get isGenre => type == 'GENRE';
  bool get isStyle => type == 'STYLE';
}
