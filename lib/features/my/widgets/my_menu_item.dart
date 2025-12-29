import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MyMenuItem extends StatelessWidget {
  const MyMenuItem({
    super.key,
    required this.title,
    required this.onTap,
    this.textColor,
    this.showArrow = true,
    this.trailing,
  });

  final String title;
  final VoidCallback onTap;
  final Color? textColor;
  final bool showArrow;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 11.h),
        color: AppColors.gray0,
        child: Row(
          children: [
            Expanded(
              child: ArtTripText.pretendard()
                  .title02Light()
                  .color(textColor ?? AppColors.textPrimary)
                  .build()
                  .text(title),
            ),
            if (trailing != null)
              ArtTripText.pretendard()
                  .body01Bold()
                  .color(AppColors.textPrimary)
                  .build()
                  .text(trailing!),
            if (showArrow)
              SvgPicture.asset(
                AppAssets.icNoArrowRight,
                width: 20.w,
                height: 20.w,
              ),
          ],
        ),
      ),
    );
  }
}
