import 'package:freezed_annotation/freezed_annotation.dart';

part 'keyword.freezed.dart';
part 'keyword.g.dart';

/// 키워드 모델
///
/// 전시 장르(GENRE) 또는 전시 스타일(STYLE)
@freezed
abstract class Keyword with _$Keyword {
  const Keyword._();

  factory Keyword({
    required int keywordId,
    required String name,
    required String type, // "GENRE" | "STYLE"
  }) = _Keyword;

  factory Keyword.fromJson(Map<String, dynamic> json) => _$KeywordFromJson(json);

  bool get isGenre => type == 'GENRE';
  bool get isStyle => type == 'STYLE';
}
