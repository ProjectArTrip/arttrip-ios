import 'dart:ui';

import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:arttrip/shared/widgets/alert_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class StampHeader extends SliverPersistentHeaderDelegate {
  const StampHeader({required this.topPadding});

  final double topPadding;

  double get _maxExtent => 230.h + topPadding;

  @override
  double get maxExtent => _maxExtent;

  @override
  double get minExtent => 0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ClipRect(
      child: OverflowBox(
        minHeight: _maxExtent,
        maxHeight: _maxExtent,
        alignment: Alignment.topCenter,
        child: SizedBox(
          height: _maxExtent,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                top: topPadding + 12.h,
                right: 24.w,
                child: const AlertBadge(color: Colors.white),
              ),
              Column(
                children: [
                  SizedBox(height: 26.h + topPadding),
                  _StampCharacterImage(),
                  SizedBox(height: 8.h),
                  // TODO: 추후 API 연동 예정
                  ArtTripText.pretendard()
                      .title01Bold()
                      .color(AppColors.textWhite)
                      .textAlign(TextAlign.center)
                      .build()
                      .text('여행의 시작'),
                  SizedBox(height: 4.h),
                  ArtTripText.pretendard()
                      .body02Regular()
                      .color(AppColors.primary100)
                      .textAlign(TextAlign.center)
                      .build()
                      .text('이번달 스탬프 등급'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant StampHeader oldDelegate) =>
      oldDelegate.topPadding != topPadding;
}

class _StampCharacterImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 120.w,
          height: 120.w,
          child: ClipOval(
            child: Stack(
              fit: StackFit.expand,
              children: [
                SvgPicture.asset(
                  AppAssets.icStampDefault,
                  width: 120.w,
                  height: 120.w,
                  fit: BoxFit.cover,
                ),
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: const ColoredBox(color: Colors.transparent),
                ),
              ],
            ),
          ),
        ),

        /// 스탬프 그림자
        ClipPath(
          clipper: _LensClipper(),
          child: Container(
            width: 60.w,
            height: 12.h,
            color: const Color(0x661F1F1F),
          ),
        ),
      ],
    );
  }
}

class _LensClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) =>
      Path()..addOval(Rect.fromLTWH(0, 0, size.width, size.height));

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
