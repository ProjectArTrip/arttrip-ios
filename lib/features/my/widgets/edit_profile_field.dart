import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EditProfileField extends StatelessWidget {
  const EditProfileField({
    super.key,
    required this.label,
    required this.value,
    this.showArrow = false,
    this.onTap,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool showArrow;
  final VoidCallback? onTap;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_buildLabel(), SizedBox(height: 8.h), _buildValueField()],
    );
  }

  Widget _buildLabel() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ArtTripText.pretendard()
            .body01Regular()
            .color(AppColors.textPrimary)
            .build()
            .text(label),
        SizedBox(width: 10.w),
        if (showArrow)
          SvgPicture.asset(AppAssets.icNoArrowRight, width: 24.w, height: 24.w),
      ],
    );
  }

  Widget _buildValueField() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray100),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: ArtTripText.pretendard()
          .body01Regular()
          .color(valueColor ?? AppColors.textPrimary)
          .build()
          .text(value),
    );
  }
}
