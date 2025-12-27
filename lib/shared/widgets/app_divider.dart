import 'package:arttrip/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppDivider extends StatelessWidget {
  const AppDivider({
    super.key,
    this.height = 1,
    this.color = AppColors.gray100,
    this.horizontalPadding = 24,
  });

  final double height;
  final Color color;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding.w),
      child: Container(height: height.h, color: color),
    );
  }
}
