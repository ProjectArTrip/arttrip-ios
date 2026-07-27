import 'package:arttrip/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 공용 토스트 스낵바
///
/// 화면 하단에 떠오르는 토스트 형태의 알림
class AppToast {
  AppToast._();

  static void show(
    BuildContext context, {
    required String message,
    Color backgroundColor = AppColors.textTertiary,
    Color textColor = AppColors.textWhite,
    Duration duration = const Duration(seconds: 2),
    double bottomMargin = 108,
  }) {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final adjustedBottom = (bottomMargin - safeBottom).clamp(
      0.0,
      double.infinity,
    );

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            height: 16 / 14,
            letterSpacing: -0.28.sp,
            color: textColor,
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        duration: duration,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 24.h),
        margin: EdgeInsets.only(
          left: 24.w,
          right: 24.w,
          bottom: adjustedBottom,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }
}
