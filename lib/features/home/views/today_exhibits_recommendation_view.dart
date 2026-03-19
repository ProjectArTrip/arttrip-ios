import 'package:arttrip/core/app_consts.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_model.dart';
import 'package:arttrip/features/exhibit/viewmodels/exhibit_viewmodel.dart';
import 'package:arttrip/features/home/home_viewmodel.dart';
import 'package:arttrip/features/home/widgets/today_exhibit_widget.dart';
import 'package:arttrip/routes/routes.dart';
import 'package:arttrip/shared/widgets/async_view.dart';
import 'package:arttrip/shared/widgets/shimmer_skeleton_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class TodayExhibitsRecommendationView extends StatefulWidget {
  const TodayExhibitsRecommendationView(this.isDomestic, {super.key});

  final bool isDomestic;

  @override
  State<TodayExhibitsRecommendationView> createState() =>
      _TodayExhibitsRecommendationViewState();
}

class _TodayExhibitsRecommendationViewState
    extends State<TodayExhibitsRecommendationView> {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Selector<HomeViewModel, String>(
        selector: (_, vm) => vm.area ?? context.l10n.allItems,
        builder: (context, area, _) {
          return Selector<HomeViewModel, AsyncState<List<ExhibitModel>>>(
            selector:
                (_, vm) =>
                    vm.todayExhibitRecommendations[vm.locationType]?[area] ??
                    const AsyncState.error(),
            builder: (context, state, _) {
              return AsyncView(
                state: state,
                onData: (data) {
                  if (data.isEmpty) return const SizedBox.shrink();

                  return SizedBox(
                    height: 240.h,
                    child: ListView.separated(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: data.length,
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      separatorBuilder:
                          (context, index) => SizedBox(width: 8.w),
                      itemBuilder: (context, index) {
                        final item = data[index];
                        return Selector<ExhibitViewModel, bool>(
                          selector: (_, vm) => vm.isFavorite(item.exhibitId),
                          builder: (context, isFavorite, _) {
                            return TodayExhibitWidget(
                              item: item,
                              isFavorite: isFavorite,
                              location:
                                  (area == context.l10n.allItems &&
                                          !widget.isDomestic)
                                      ? item.countryName
                                      : widget.isDomestic
                                      ? item.regionName
                                      : null,
                              onTap:
                                  () => Routes.push(
                                    context,
                                    '/exhibit/${item.exhibitId}',
                                  ),
                              favoriteOnTap: () {
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
                            );
                          },
                        );
                      },
                    ),
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
                    child: SizedBox(
                      height: 240.h,
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: 3,
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        separatorBuilder:
                            (context, index) => SizedBox(width: 8.w),
                        itemBuilder: (context, index) {
                          return const ShimmerSkeletonItem(
                            width: 180,
                            height: 240,
                            radius: 8,
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
