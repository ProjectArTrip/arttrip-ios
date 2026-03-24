import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/app_consts.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_model.dart';
import 'package:arttrip/features/exhibit/viewmodels/exhibit_viewmodel.dart';
import 'package:arttrip/features/home/home_viewmodel.dart';
import 'package:arttrip/routes/app_routes.dart';
import 'package:arttrip/routes/routes.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:arttrip/shared/widgets/app_cached_image.dart';
import 'package:arttrip/shared/widgets/async_view.dart';
import 'package:arttrip/shared/widgets/shimmer_skeleton_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class PersonalizedExhibitsView extends StatefulWidget {
  const PersonalizedExhibitsView({super.key});

  @override
  State<PersonalizedExhibitsView> createState() =>
      _PersonalizedExhibitsViewState();
}

class _PersonalizedExhibitsViewState extends State<PersonalizedExhibitsView> {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Selector<HomeViewModel, AsyncState<List<ExhibitModel>>>(
        selector:
            (_, vm) =>
                vm.personalizedExhibits[vm.locationType] ??
                const AsyncState.error(),
        builder: (context, state, _) {
          return AsyncView(
            state: state,
            onData: (data) {
              if (data.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12.h,
                children: [
                  // TODO: 유저 이름 동적으로 바꾸기
                  Padding(
                    padding: EdgeInsets.only(
                      left: 24.w,
                      top: 32.h,
                      right: 24.w,
                    ),
                    child: ArtTripText.pretendard().title01Bold().build().text(
                      context.l10n.personalizedRecommendationTitle('김미미'),
                    ),
                  ),
                  SizedBox(
                    height: 190.h,
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: data.length,
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      separatorBuilder:
                          (context, index) => SizedBox(width: 8.w),
                      itemBuilder: (_, index) {
                        final item = data[index];
                        final location = item.countryName ?? item.regionName;
                        return GestureDetector(
                          onTap:
                              () => Routes.push(
                                context,
                                AppRoutes.exhibitPath(item.exhibitId),
                              ),
                          child: SizedBox(
                            width: 120.w,
                            child: Column(
                              spacing: 8.h,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// 전시 이미지
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.r),
                                  child: Stack(
                                    children: [
                                      item.posterUrl?.isNotEmpty == true
                                          ? AppCachedImage(
                                            imageUrl: item.posterUrl!,
                                            width: 120.w,
                                            height: 150.h,
                                            fit: BoxFit.cover,
                                          )
                                          : Container(
                                            width: 120.w,
                                            height: 150.h,
                                            color: AppColors.gray100,
                                            child: const Center(
                                              child: Icon(
                                                Icons.image_not_supported,
                                                color: AppColors.textTertiary,
                                              ),
                                            ),
                                          ),
                                      location?.isNotEmpty == true
                                          ? Container(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 4.h,
                                              horizontal: 8.w,
                                            ),
                                            margin: EdgeInsets.only(
                                              left: 8.w,
                                              top: 9.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.textPrimary
                                                  .withValues(alpha: 0.6),
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                            ),
                                            child: ArtTripText.pretendard()
                                                .body02Bold()
                                                .color(AppColors.textWhite)
                                                .build()
                                                .text(location!),
                                          )
                                          : const SizedBox.shrink(),
                                      Selector<ExhibitViewModel, bool>(
                                        selector:
                                            (_, vm) =>
                                                vm.isFavorite(item.exhibitId),
                                        builder: (context, isFavorite, _) {
                                          return Positioned(
                                            top: 8.h,
                                            right: 8.w,
                                            child: GestureDetector(
                                              onTap: () {
                                                final exhibitViewModel =
                                                    Provider.of<
                                                      ExhibitViewModel
                                                    >(context, listen: false);
                                                exhibitViewModel
                                                    .updateFavoriteExhibit(
                                                      item.exhibitId,
                                                      !isFavorite,
                                                    );
                                              },
                                              child: SvgPicture.asset(
                                                AppAssets.icLikeCircle(
                                                  isLiked: isFavorite,
                                                ),
                                                width: 24.w,
                                                height: 24.w,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),

                                /// 전시 제목
                                Expanded(
                                  child: ArtTripText.pretendard()
                                      .body01Bold()
                                      .ellipsis(2)
                                      .build()
                                      .text(item.title ?? ''),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
            onLoading: () {
              return Shimmer(
                duration: const Duration(
                  milliseconds: AppConsts.shimmerDurationMs,
                ),
                interval: const Duration(
                  milliseconds: AppConsts.shimmerIntervalMs,
                ),
                child: Padding(
                  padding: EdgeInsets.only(top: 32.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 12.h,
                    children: [
                      ShimmerSkeletonItem(
                        width: 160,
                        height: 20,
                        margin: EdgeInsets.symmetric(horizontal: 24.w),
                      ),
                      SizedBox(
                        height: 190.h,
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          scrollDirection: Axis.horizontal,
                          itemCount: 3,
                          separatorBuilder:
                              (context, index) => SizedBox(width: 8.w),
                          itemBuilder: (context, index) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const ShimmerSkeletonItem(
                                  width: 120,
                                  height: 150,
                                  radius: 8,
                                ),
                                SizedBox(height: 8.h),
                                const ShimmerSkeletonItem(
                                  width: 120,
                                  height: 14,
                                  radius: 8,
                                ),
                                SizedBox(height: 4.h),
                                const ShimmerSkeletonItem(
                                  width: 120,
                                  height: 14,
                                  radius: 8,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
