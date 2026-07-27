import 'package:freezed_annotation/freezed_annotation.dart';

part 'exhibit_detail_model.freezed.dart';
part 'exhibit_detail_model.g.dart';

/// 전시 상세 모델
///
/// /home/{id} 응답의 result 필드
@freezed
abstract class ExhibitDetailModel with _$ExhibitDetailModel {
  const ExhibitDetailModel._();

  factory ExhibitDetailModel({
    required int exhibitId,
    required String title,
    required String description,
    String? posterUrl,
    String? ticketUrl,
    required String exhibitPeriod,
    required String status, // "ONGOING", "CLOSED", "UPCOMING"
    required String hallName,
    required String hallAddress,
    String? hallOpeningHours,
    String? hallPhone,
    double? hallLatitude,
    double? hallLongitude,
    @Default(false) bool isFavorite,
  }) = _ExhibitDetailModel;

  factory ExhibitDetailModel.fromJson(Map<String, dynamic> json) =>
      _$ExhibitDetailModelFromJson(json);

  /// 진행 중 여부
  bool get isOngoing => status == 'ONGOING';

  /// 종료 여부
  bool get isClosed => status == 'CLOSED';

  /// 예정 여부
  bool get isUpcoming => status == 'UPCOMING';
}
