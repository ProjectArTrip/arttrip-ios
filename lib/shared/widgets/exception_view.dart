import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class ExceptionView extends StatelessWidget {
  const ExceptionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(AppAssets.icException, width: 96.w, height: 96.w),
          SizedBox(height: 4.h),
          ArtTripText.pretendard()
              .body01Regular()
              .textAlign(TextAlign.center)
              .build()
              .text(
                context.l10n.exceptionTitle,
              ),
          SizedBox(height: 8.h),
          ArtTripText.pretendard()
              .body02Regular()
              .textAlign(TextAlign.center)
              .color(AppColors.textTertiary)
              .build()
              .text(
                context.l10n.exceptionDesc,
              ),
        ],
      ),
    );
  }
}
