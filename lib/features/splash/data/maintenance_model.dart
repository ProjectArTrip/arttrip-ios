import 'package:freezed_annotation/freezed_annotation.dart';

part 'maintenance_model.freezed.dart';
part 'maintenance_model.g.dart';

@freezed
abstract class MaintenanceModel with _$MaintenanceModel {
  const factory MaintenanceModel({
    required bool configured,
    required bool active,
    String? state,
    String? title,
    String? message,
    String? startAt,
    String? endAt,
    String? buttonText,
    bool? forceExit,
    int? refreshAfterSeconds,
    int? version,
  }) = _MaintenanceModel;

  factory MaintenanceModel.fromJson(Map<String, dynamic> json) =>
      _$MaintenanceModelFromJson(json);
}
