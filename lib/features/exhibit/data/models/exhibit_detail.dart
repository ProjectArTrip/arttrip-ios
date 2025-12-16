import 'package:freezed_annotation/freezed_annotation.dart';

part 'exhibit_detail.freezed.dart';
part 'exhibit_detail.g.dart';

/// 전시 상세 모델
///
/// /home/{id} 응답의 result 필드
@freezed
abstract class ExhibitDetail with _$ExhibitDetail {
  const ExhibitDetail._();

  factory ExhibitDetail({
    required int exhibitId,
    required String title,
    required String description,
    required String posterUrl,
    required String ticketUrl,
    required String exhibitPeriod,
    required String status, // "ONGOING", "CLOSED", "UPCOMING"
    required String hallName,
    required String hallAddress,
    required String hallOpeningHours,
    required String hallPhone,
  }) = _ExhibitDetail;

  factory ExhibitDetail.fromJson(Map<String, dynamic> json) =>
      _$ExhibitDetailFromJson(json);

  /// 진행 중 여부
  bool get isOngoing => status == 'ONGOING';

  /// 종료 여부
  bool get isClosed => status == 'CLOSED';

  /// 예정 여부
  bool get isUpcoming => status == 'UPCOMING';
}
