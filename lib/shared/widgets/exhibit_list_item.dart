import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_model.dart';
import 'package:arttrip/features/exhibit/viewmodels/exhibit_viewmodel.dart';
import 'package:arttrip/routes/app_routes.dart';
import 'package:arttrip/routes/routes.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:arttrip/shared/widgets/app_cached_image.dart';
import 'package:arttrip/shared/widgets/exhibit_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class ExhibitListItem extends StatelessWidget {
  const ExhibitListItem({super.key, required this.item});

  final ExhibitModel item;

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
                        )
                      : Container(
                          width: 100.w,
                          height: 100.w,
                          color: AppColors.gray100,
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),

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
                              !isFavorite,
                            );
                          },
                          child: SvgPicture.asset(
                            AppAssets.icLikeCircle(isLiked: isFavorite),
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
                spacing: 4.h,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ArtTripText.pretendard().body01Bold().build().text(
                    item.title ?? '',
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2.h,
                    children: [
                      ArtTripText.pretendard()
                          .body02Regular()
                          .color(AppColors.textTertiary)
                          .build()
                          .text(item.hallName ?? ''),
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
