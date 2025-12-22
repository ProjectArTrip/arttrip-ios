import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_model.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TodayExhibitWidget extends StatelessWidget {
  const TodayExhibitWidget({
    super.key,
    required this.item,
    this.isLiked = false,
    this.location,
    this.onTap,
    this.likeOnTap,
  });

  final ExhibitModel item;
  final bool isLiked;
  final String? location;
  final Function()? onTap;
  final Function()? likeOnTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Stack(
          children: [
            /// 백그라운드 이미지
            item.posterUrl?.isNotEmpty == true
                ? CachedNetworkImage(
                  imageUrl: item.posterUrl!,
                  width: 180.w,
                  height: 240.h,
                  fit: BoxFit.cover,
                )
                : const SizedBox.shrink(),

            /// 테두리
            Container(
              width: 180.w,
              height: 240.h,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.gray50),
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),

            /// 그라데이션 오버레이
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 180.w,
                height: 100.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.0),
                      Colors.black.withValues(alpha: 0.25),
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ),

            /// 국가
            location?.isNotEmpty == true
                ? Container(
                  padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
                  margin: EdgeInsets.only(left: 10.w, top: 16.h),
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: ArtTripText.pretendard()
                      .body02Bold()
                      .color(AppColors.textWhite)
                      .build()
                      .text(location!),
                )
                : const SizedBox.shrink(),

            /// 즐겨찾기
            // TODO: 즐겨찾기 상태에 따른 아이콘 변경 필요
            Positioned(
              top: 16.h,
              right: 16.w,
              child: GestureDetector(
                onTap: likeOnTap,
                child: SvgPicture.asset(
                  AppAssets.icLikeCircle(isLiked: isLiked),
                  width: 24.w,
                  height: 24.w,
                ),
              ),
            ),

            /// 전시 정보
            Container(
              width: 180.w,
              padding: EdgeInsets.all(10.w),
              alignment: Alignment.bottomLeft,
              child: Wrap(
                runSpacing: 4.h,
                children: [
                  ArtTripText.pretendard()
                      .title02Bold()
                      .color(AppColors.textWhite)
                      .build()
                      .text(item.title ?? ''),
                  ArtTripText.pretendard()
                      .body02Regular()
                      .color(AppColors.textWhite)
                      .build()
                      .text(item.hallName ?? ''),
                  ArtTripText.pretendard()
                      .body02Regular()
                      .color(AppColors.textWhite)
                      .build()
                      .text(item.exhibitPeriod ?? ''),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
