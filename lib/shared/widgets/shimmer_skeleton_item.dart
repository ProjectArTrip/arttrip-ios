import 'package:arttrip/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Title 부분에 사용할 때, width: 160, height:20, radius: 100으로 사용합니다.
class ShimmerSkeletonItem extends StatelessWidget {
  const ShimmerSkeletonItem({
    super.key,
    this.width,
    this.height,
    this.radius,
    this.margin,
  });

  final double? width;
  final double? height;
  final double? radius;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width?.w,
      height: height?.h,
      margin: margin,
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(radius?.r ?? 100),
      ),
    );
  }
}
