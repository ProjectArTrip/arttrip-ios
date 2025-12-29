import 'package:freezed_annotation/freezed_annotation.dart';

part 'favorite_check_result.freezed.dart';
part 'favorite_check_result.g.dart';

/// 즐겨찾기 여부 확인 결과 모델
@freezed
abstract class FavoriteCheckResult with _$FavoriteCheckResult {
  const factory FavoriteCheckResult({required bool isFavorite}) =
      _FavoriteCheckResult;

  factory FavoriteCheckResult.fromJson(Map<String, dynamic> json) =>
      _$FavoriteCheckResultFromJson(json);
}
