import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 전시 상세 정보의 개별 정보 행 위젯
class ExhibitInfoRow extends StatelessWidget {
  const ExhibitInfoRow({
    super.key,
    required this.iconPath,
    required this.label,
    required this.value,
    this.extraWidget,
  });

  final String iconPath;
  final String label;
  final String value;
  final Widget? extraWidget;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(iconPath, width: 20.w, height: 20.w),
        SizedBox(width: 4.w),
        SizedBox(
          width: 66.w,
          child: ArtTripText.pretendard()
              .body02Bold()
              .color(AppColors.textPrimary)
              .build()
              .text(label),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ArtTripText.pretendard()
                  .body02Light()
                  .color(AppColors.textPrimary)
                  .build()
                  .text(value),
              if (extraWidget != null) ...[SizedBox(height: 4.h), extraWidget!],
            ],
          ),
        ),
      ],
    );
  }
}
