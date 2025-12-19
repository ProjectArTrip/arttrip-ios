import 'package:arttrip/core/app_consts.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/home/home_viewmodel.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:arttrip/shared/widgets/async_view.dart';
import 'package:arttrip/shared/widgets/shimmer_skeleton_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class RegionalExhibitionView extends StatefulWidget {
  const RegionalExhibitionView({super.key});

  @override
  State<RegionalExhibitionView> createState() => _RegionalExhibitionViewState();
}

class _RegionalExhibitionViewState extends State<RegionalExhibitionView> {
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsetsGeometry.only(top: 32.h),
      sliver: SliverToBoxAdapter(
        child: Selector<HomeViewModel, AsyncState<List<String>>>(
          selector: (_, vm) => vm.locations,
          builder: (context, state, _) {
            return AsyncView(
              state: state,
              onData: (data) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: 24.w,
                        right: 24.w,
                        bottom: 12.h,
                      ),
                      child: ArtTripText.pretendard()
                          .title01Bold()
                          .build()
                          .text(context.l10n.regionalExhibition),
                    ),
                    SizedBox(
                      height: 90.h,
                      child: ListView.separated(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: data.length,
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        separatorBuilder:
                            (context, index) => SizedBox(width: 8.w),
                        itemBuilder: (context, index) {
                          var item = data[index];
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CircleAvatar(
                                radius: 32.w,
                                backgroundColor: Colors.black,
                              ),
                              ArtTripText.pretendard()
                                  .body02Bold()
                                  .textAlign(TextAlign.center)
                                  .build()
                                  .text(item),
                            ],
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 12.h,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: const ShimmerSkeletonItem(
                          width: 160,
                          height: 20,
                        ),
                      ),
                      SizedBox(
                        height: 90.h,
                        child: ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: 6,
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          separatorBuilder:
                              (context, index) => SizedBox(width: 8.w),
                          itemBuilder: (context, index) {
                            return Column(
                              spacing: 12.h,
                              children: [
                                const ShimmerSkeletonItem(
                                  width: 64,
                                  height: 64,
                                ),
                                const ShimmerSkeletonItem(
                                  width: 21,
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
                );
              },
            );
          },
        ),
      ),
    );
  }
}
