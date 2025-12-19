import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/shared/models/exhibit_model.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:arttrip/shared/widgets/exhibition_status_badge.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class ExhibitionListItem extends StatelessWidget {
  const ExhibitionListItem({
    super.key,
    required this.item,
    this.isLiked = false,
    this.onTap,
    this.likeOnTap,
  });

  final ExhibitModel item;
  final bool isLiked;
  final Function()? onTap;
  final Function()? likeOnTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ColoredBox(
        color: Colors.transparent,
        child: Row(
          spacing: 12.w,
          children: [
            ClipRRect(
              borderRadius: BorderRadiusGeometry.circular(8.r),
              child: Stack(
                children: [
                  /// 전시 이미지
                  item.posterUrl?.isNotEmpty == true
                      ? CachedNetworkImage(
                        imageUrl: item.posterUrl!,
                        width: 100.w,
                        height: 100.w,
                        fit: BoxFit.cover,
                      )
                      : const SizedBox.shrink(),

                  /// 전시 상태
                  item.status != null
                      ? Positioned(
                        right: 0,
                        bottom: 0,
                        child: ExhibitionStatusBadge(item.status!),
                      )
                      : const SizedBox.shrink(),

                  /// 즐겨찾기
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: GestureDetector(
                      onTap: likeOnTap,
                      child: SvgPicture.asset(
                        AppAssets.icLikeCircle(isLiked: isLiked),
                        width: 24.w,
                        height: 24.w,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// 전시 정보
            Expanded(
              child: Column(
                spacing: 4.h,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '공예',
                    style: TextStyle(
                      color: AppColors.primary300,
                      fontSize: 14.sp,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                      height: 20 / 14,
                      letterSpacing: 14 * (-2 / 100),
                    ),
                  ),
                  ArtTripText.pretendard().body01Bold().build().text(
                    item.title ?? '',
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2.h,
                    children: [
                      // TODO: 미술관명 수정 예정
                      ArtTripText.pretendard()
                          .body02Regular()
                          .color(AppColors.textTertiary)
                          .build()
                          .text('미술관명'),
                      ArtTripText.pretendard()
                          .body02Regular()
                          .color(AppColors.textTertiary)
                          .build()
                          .text(item.exhibitPeriod ?? ''),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
