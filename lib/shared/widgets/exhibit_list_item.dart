import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_model.dart';
import 'package:arttrip/features/exhibit/viewmodels/exhibit_viewmodel.dart';
import 'package:arttrip/routes/app_routes.dart';
import 'package:arttrip/routes/routes.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:arttrip/shared/widgets/app_cached_image.dart';
import 'package:arttrip/shared/widgets/exhibit_status_badge.dart';
import 'package:arttrip/shared/widgets/image_empty_medium_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class ExhibitListItem extends StatelessWidget {
  const ExhibitListItem({
    super.key,
    required this.item,
    required this.isDomestic,
    this.showArea = false,
    this.forceFavorite = false,
  });

  final ExhibitModel item;
  final bool showArea;
  final bool isDomestic;

  /// 즐겨찾기 여부를 강제로 보여줄지 여부 (ex. 즐겨찾기 페이지에서는 항상 true)
  final bool forceFavorite;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Routes.push(context, AppRoutes.exhibitPath(item.exhibitId)),
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
                      ? AppCachedImage(
                          imageUrl: item.posterUrl!,
                          width: 100.w,
                          height: 100.w,
                          fit: BoxFit.cover,
                          errorWidget: (p0, p1, p2) => ImageEmptyMediumWidget(
                            width: 100.w,
                            height: 100.w,
                          ),
                        )
                      : ImageEmptyMediumWidget(width: 100.w, height: 100.w),

                  /// 전시 상태
                  item.status != null
                      ? Positioned(
                          right: 0,
                          bottom: 0,
                          child: ExhibitStatusBadge(item.status!),
                        )
                      : const SizedBox.shrink(),

                  /// 즐겨찾기
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: Selector<ExhibitViewModel, bool>(
                      selector: (_, vm) => vm.isFavorite(item.exhibitId),
                      builder: (context, isFavorite, _) {
                        return GestureDetector(
                          onTap: () {
                            final exhibitViewModel =
                                Provider.of<ExhibitViewModel>(
                                  context,
                                  listen: false,
                                );
                            exhibitViewModel.updateFavoriteExhibit(
                              item.exhibitId,
                              forceFavorite ? false : !isFavorite,
                            );
                          },
                          child: SvgPicture.asset(
                            AppAssets.icLikeCircle(
                              isLiked: forceFavorite ? true : isFavorite,
                            ),
                            width: 24.w,
                            height: 24.w,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            /// 전시 정보
            Expanded(
              child: Column(
                spacing: 8.h,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showArea &&
                      (item.countryName != null || item.regionName != null))
                    ArtTripText.pretendard()
                        .body01Regular()
                        .color(const Color(0xFF7859FF))
                        .build()
                        .text(
                          !isDomestic
                              ? (item.countryName ?? item.regionName) ?? ''
                              : item.regionName ?? '',
                        ),
                  if (item.title?.isNotEmpty == true)
                    ArtTripText.pretendard()
                        .body01Bold()
                        .ellipsis(2)
                        .build()
                        .text(item.title!),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2.h,
                    children: [
                      if (item.hallName?.isNotEmpty == true)
                        ArtTripText.pretendard()
                            .body02Regular()
                            .color(AppColors.textTertiary)
                            .build()
                            .text(item.hallName!),
                      if (item.exhibitPeriod?.isNotEmpty == true)
                        ArtTripText.pretendard()
                            .body02Regular()
                            .color(AppColors.textTertiary)
                            .build()
                            .text(item.exhibitPeriod!),
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
