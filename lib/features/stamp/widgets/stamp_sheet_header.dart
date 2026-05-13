import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StampSheetHeader extends StatelessWidget {
  const StampSheetHeader({super.key, required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.subLightGray,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8.r,
            offset: Offset(0, -2.h),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(24.w, 25.h, 24.w, 18.h),
      child: Column(
        spacing: 8.h,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 4.w,
            children: [
              // TODO: 추후 API 연동 예정
              ArtTripText.pretendard()
                  .font(16)
                  .height(1.13)
                  .fontWeight(FontWeight.bold)
                  .color(AppColors.textPrimary)
                  .build()
                  .text('다음달 예상 등급'),
              SvgPicture.asset(AppAssets.icHelp, width: 20.w, height: 20.w),
              const Spacer(),
              ArtTripText.pretendard()
                  .font(16)
                  .fontWeight(FontWeight.bold)
                  .color(AppColors.primary300)
                  .build()
                  .text('${(progress * 100).toInt()}%'),
            ],
          ),
          _StampProgressBar(progress: progress),
          ArtTripText.pretendard()
              .body02Regular()
              .color(AppColors.subRed)
              .build()
              .text('스탬프 기능은 현재 준비 중입니다.'),
        ],
      ),
    );
  }
}

class _StampProgressBar extends StatelessWidget {
  const _StampProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          height: 16.h,
          decoration: BoxDecoration(
            color: AppColors.subLightGray,
            border: Border.all(color: AppColors.gray100, width: 1.w),
            borderRadius: BorderRadius.circular(100.r),
          ),
          padding: EdgeInsets.all(4.w),
          child: Align(
            alignment: Alignment.topLeft,
            child: progress > 0
                ? Container(
                    width: constraints.maxWidth * progress,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7859FF),
                      borderRadius: BorderRadius.circular(100.r),
                    ),
                  )
                : Container(
                    width: 2.w,
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(100.r),
                    ),
                  ),
          ),
        );
      },
    );
  }
}
