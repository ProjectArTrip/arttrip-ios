import 'package:arttrip/features/alert/alert_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'alert_detail_model.freezed.dart';
part 'alert_detail_model.g.dart';

@freezed
abstract class AlertDetailModel with _$AlertDetailModel {
  const AlertDetailModel._();

  factory AlertDetailModel({
    required List<AlertModel> notifications,
    required bool hasNext,
    int? nextCursor,
  }) = _AlertDetailModel;

  factory AlertDetailModel.fromJson(Map<String, dynamic> json) =>
      _$AlertDetailModelFromJson(json);
}
