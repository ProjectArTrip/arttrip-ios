import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

/// 전시가 비어있는 경우 보여주는 위젯
class NoExhibitsView extends StatelessWidget {
  const NoExhibitsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Column(
        spacing: 8.h,
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(AppAssets.icNoExhibits, width: 96.w, height: 96.w),
          ArtTripText.pretendard()
              .body01Regular()
              .textAlign(TextAlign.center)
              .color(AppColors.textTertiary)
              .build()
              .text(context.l10n.noExhibitsTitle),
        ],
      ),
    );
  }
}
