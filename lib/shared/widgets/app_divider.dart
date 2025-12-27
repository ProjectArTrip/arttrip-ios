import 'package:arttrip/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppDivider extends StatelessWidget {
  const AppDivider({
    super.key,
    this.height = 1,
    this.color = AppColors.gray100,
  });

  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height.h,
      color: color,
    );
  }
}
