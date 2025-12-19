import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/enum.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
