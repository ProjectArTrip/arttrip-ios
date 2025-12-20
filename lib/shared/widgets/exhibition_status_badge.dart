import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/enum.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 리스트 아이템용 전시 상태 배지 (이미지 모서리에 붙는 형태)
class ExhibitionStatusBadge extends StatelessWidget {
  const ExhibitionStatusBadge(this.status, {super.key});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(16.r)),
        border:
            status == ExhibitionStatus.endingSoon.status
                ? const Border(
                  right: BorderSide(color: AppColors.gray50),
                  bottom: BorderSide(color: AppColors.gray50),
                )
                : status == ExhibitionStatus.upcoming.status
                ? const Border(
                  right: BorderSide(color: AppColors.gray100),
                  bottom: BorderSide(color: AppColors.gray100),
                )
                : null,
        color:
            status == ExhibitionStatus.onGoing.status
                ? AppColors.subLime
                : status == ExhibitionStatus.endingSoon.status
                ? AppColors.gray0
                : AppColors.subLightGray,
      ),
      child: ArtTripText.pretendard()
          .body02Bold()
          .color(
            status == ExhibitionStatus.upcoming.status
                ? AppColors.textPoint
                : AppColors.textPrimary,
          )
          .build()
          .text(
            status == ExhibitionStatus.onGoing.status
                ? context.l10n.onGoing
                : status == ExhibitionStatus.endingSoon.status
                ? context.l10n.endingSoon
                : context.l10n.upcoming,
          ),
    );
  }
}

/// 상세 페이지용 전시 상태 배지 (독립적인 칩 형태)
class ExhibitDetailStatusBadge extends StatelessWidget {
  const ExhibitDetailStatusBadge(this.status, {super.key});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.r),
        border: _border,
        color: _backgroundColor,
      ),
      child: ArtTripText.pretendard()
          .body02Bold()
          .color(_textColor)
          .build()
          .text(_label(context)),
    );
  }

  Color get _backgroundColor {
    if (status == ExhibitionStatus.onGoing.status) {
      return AppColors.subLime;
    } else if (status == ExhibitionStatus.endingSoon.status) {
      return AppColors.gray0;
    } else if (status == ExhibitionStatus.upcoming.status) {
      return AppColors.subLightGray;
    }
    return AppColors.subLightGray;
  }

  Color get _textColor {
    if (status == ExhibitionStatus.upcoming.status) {
      return AppColors.textPoint;
    }
    return AppColors.textPrimary;
  }

  Border? get _border {
    if (status == ExhibitionStatus.endingSoon.status) {
      return Border.all(color: AppColors.gray50, width: 1);
    } else if (status == ExhibitionStatus.upcoming.status) {
      return Border.all(color: AppColors.gray100, width: 1);
    }
    return null;
  }

  String _label(BuildContext context) {
    if (status == ExhibitionStatus.onGoing.status) {
      return context.l10n.onGoing;
    } else if (status == ExhibitionStatus.endingSoon.status) {
      return context.l10n.endingSoon;
    } else if (status == ExhibitionStatus.upcoming.status) {
      return context.l10n.upcoming;
    }
    return '';
  }
}
