import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CommonAppBar({
    super.key,
    this.title,
    this.showBackButton = true,
    this.actions,
    this.backgroundColor = AppColors.gray0,
    this.surfaceTintColor = AppColors.gray0,
    this.elevation = 0.0,
  });
  final String? title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Color backgroundColor;
  final Color surfaceTintColor;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      surfaceTintColor: surfaceTintColor,
      elevation: elevation,
      centerTitle: true,
      title: ArtTripText.pretendard().headline().build().text(title ?? ''),
      toolbarHeight: 52.h,
      leadingWidth: 24.w + 24.w,
      leading:
          showBackButton
              ? Padding(
                padding: EdgeInsets.only(left: 24.w),
                child: GestureDetector(
                  onTap: () => GoRouter.of(context).pop(),
                  child: SvgPicture.asset(
                    AppAssets.icNoArrowLeft,
                    width: 24.w,
                    height: 24.w,
                  ),
                ),
              )
              : null,
      actionsPadding: EdgeInsets.only(right: 24.w),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(52.h);
}
