import 'package:freezed_annotation/freezed_annotation.dart';

part 'alert_model.freezed.dart';
part 'alert_model.g.dart';

@freezed
abstract class AlertModel with _$AlertModel {
  const AlertModel._();

  factory AlertModel({
    required int userNoticeId,
    required String action,
    required int referenceId,
    required String title,
    required String body,
    required bool isRead,
    required String createdAt,
  }) = _AlertModel;

  factory AlertModel.fromJson(Map<String, dynamic> json) =>
      _$AlertModelFromJson(json);
}
