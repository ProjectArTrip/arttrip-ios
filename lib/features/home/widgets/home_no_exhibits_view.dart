import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

/// 홈 화면에서 전시가 없을 때 보여주는 위젯
class HomeNoExhibitsView extends StatelessWidget {
  const HomeNoExhibitsView({
    super.key,
    required this.title,
    this.margin,
    this.padding,
  });

  final String title;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin ?? EdgeInsets.symmetric(horizontal: 24.w),
      padding: padding ?? EdgeInsets.only(
        left: 28.w,
        top: 24.h,
        right: 27.w,
        bottom: 28.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.subLightGray,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        spacing: 8.h,
        children: [
          SvgPicture.asset(AppAssets.icNotFound, width: 40.w, height: 40.w),
          ArtTripText.pretendard()
              .body01Regular()
              .color(AppColors.textTertiary)
              .textAlign(TextAlign.center)
              .build()
              .text(title),
        ],
      ),
    );
  }
}
