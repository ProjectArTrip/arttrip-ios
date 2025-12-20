import 'package:arttrip/core/app_consts.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/home/home_viewmodel.dart';
import 'package:arttrip/features/home/widgets/today_exhibition_widget.dart';
import 'package:arttrip/routes/routes.dart';
import 'package:arttrip/shared/models/exhibit_model.dart';
import 'package:arttrip/shared/widgets/async_view.dart';
import 'package:arttrip/shared/widgets/shimmer_skeleton_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class TodayExhibitRecommendationView extends StatefulWidget {
  const TodayExhibitRecommendationView({super.key});

  @override
  State<TodayExhibitRecommendationView> createState() =>
      _TodayExhibitRecommendationViewState();
}

class _TodayExhibitRecommendationViewState
    extends State<TodayExhibitRecommendationView> {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Selector<HomeViewModel, AsyncState<List<ExhibitModel>>>(
        selector: (_, vm) => vm.todayExhibitRecommendations,
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
                  separatorBuilder: (context, index) => SizedBox(width: 8.w),
                  itemBuilder: (context, index) {
                    var item = data[index];
                    return Selector<HomeViewModel, String>(
                      selector: (_, vm) => vm.selectedLocation,
                      builder: (context, selectedLocation, _) {
                        return TodayExhibitionWidget(
                          item: item,
                          isLiked: false,
                          showCountry:
                              selectedLocation == context.l10n.allItems,
                          onTap: () => Routes.push(
                            context,
                            '/exhibit/${item.exhibitId}',
                          ),
                          likeOnTap: () {},
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
                    separatorBuilder: (context, index) => SizedBox(width: 8.w),
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
      ),
    );
  }
}
