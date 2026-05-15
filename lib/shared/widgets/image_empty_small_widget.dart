import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class ImageEmptySmallWidget extends StatelessWidget {
  const ImageEmptySmallWidget({super.key, this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: AppColors.gray50,
      child: Center(
        child: SvgPicture.asset(
          AppAssets.icNoImage,
          width: 37.8.w,
          height: 12.h,
        ),
      ),
    );
  }
}
