import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/shared/models/exhibit_model.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
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
    return Row(
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
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      bottomRight: Radius.circular(16.r),
                    ),
                    border: const Border(
                      right: BorderSide(color: AppColors.gray50),
                      bottom: BorderSide(color: AppColors.gray50),
                    ),
                    color:
                        item.status == 'ONGOING'
                            ? AppColors.subLime
                            : item.status == 'CLOSING_SOON'
                            ? AppColors.gray0
                            : AppColors.subRed, // TODO: 색상 확인 필요
                  ),
                  child: ArtTripText.pretendard().body02Bold().build().text(
                    item.status == 'ONGOING'
                        ? context.l10n.ongoing
                        : item.status == 'CLOSING_SOON'
                        ? context.l10n.closingSoon
                        : context.l10n.upcoming,
                  ),
                ),
              ),

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
    );
  }
}
