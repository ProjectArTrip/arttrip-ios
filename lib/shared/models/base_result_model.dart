import 'package:freezed_annotation/freezed_annotation.dart';

part 'base_result_model.freezed.dart';
part 'base_result_model.g.dart';

@freezed
abstract class BaseResultModel with _$BaseResultModel {
  const BaseResultModel._();

  factory BaseResultModel({
    @Default('') String httpStatus,
    @Default(false) bool isSuccess,
    @Default('') String code,
    @Default('') String message,
    result, // List, Map, Nullable 등의 타입을 받습니다.
  }) = _BaseResultModel;

  factory BaseResultModel.fromJson(Map<String, dynamic> json) => _$BaseResultModelFromJson(json);
}
