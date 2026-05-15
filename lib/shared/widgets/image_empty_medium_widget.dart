import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class ImageEmptyMediumWidget extends StatelessWidget {
  const ImageEmptyMediumWidget({super.key, this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: AppColors.gray50,
      child: Center(
        child: Column(
          spacing: 8.h,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(AppAssets.icNoImage, width: 63.w, height: 20.h),
            ArtTripText.pretendard()
                .body02Bold()
                .color(AppColors.textTertiary)
                .textAlign(TextAlign.center)
                .build()
                .text(context.l10n.noImageMedium),
          ],
        ),
      ),
    );
  }
}
