import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 리뷰 작성/수정 시 금칙어가 포함된 경우 표시하는 다이얼로그
class BadWordDialog extends StatelessWidget {
  const BadWordDialog({super.key});

  /// 다이얼로그 표시 헬퍼 메서드
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => const BadWordDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.gray0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Padding(
        padding: EdgeInsets.fromLTRB(18.w, 40.h, 18.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ArtTripText.pretendard()
                .title02Bold()
                .color(AppColors.textPrimary)
                .textAlign(TextAlign.center)
                .build()
                .text(context.l10n.badWordDialogTitle),
            SizedBox(height: 12.h),
            ArtTripText.pretendard()
                .body01Regular()
                .color(AppColors.textSecondary)
                .textAlign(TextAlign.center)
                .build()
                .text(context.l10n.badWordDialogContent),
            SizedBox(height: 24.h),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: double.infinity,
                height: 52.h,
                decoration: BoxDecoration(
                  color: AppColors.primary300,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                alignment: Alignment.center,
                child: ArtTripText.pretendard()
                    .title02Bold()
                    .color(AppColors.textWhite)
                    .build()
                    .text(context.l10n.badWordDialogButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
