import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/app_consts.dart';
import 'package:arttrip/core/app_utils.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_model.dart';
import 'package:arttrip/features/home/home_viewmodel.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:arttrip/shared/widgets/async_view.dart';
import 'package:arttrip/shared/widgets/exhibit_list_item.dart';
import 'package:arttrip/shared/widgets/exhibit_list_item_skeleton.dart';
import 'package:arttrip/shared/widgets/shimmer_skeleton_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class WeeklyExhibitsScheduleView extends StatefulWidget {
  const WeeklyExhibitsScheduleView({super.key});

  @override
  State<WeeklyExhibitsScheduleView> createState() =>
      _WeeklyExhibitsScheduleViewState();
}

class _WeeklyExhibitsScheduleViewState
    extends State<WeeklyExhibitsScheduleView> {
  @override
  Widget build(BuildContext context) {
    return Selector<HomeViewModel, AsyncState<List<DateTime>>>(
      selector: (_, vm) => vm.weeklyCalendar,
      builder: (context, state, _) {
        return AsyncView(
          state: state,
          isSliverWidget: true,
          onData: (currentWeek) {
            return SliverPadding(
              padding: EdgeInsets.only(left: 24.w, top: 32.h, right: 24.w),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHeader(),
                  _buildWeeklyCalendar(currentWeek),
                  Selector<HomeViewModel, AsyncState<List<ExhibitModel>>>(
                    selector: (_, vm) => vm.weeklyExhibitsBySelectedDate,
                    builder: (context, state, _) {
                      return AsyncView(
                        state: state,
                        onData: (data) {
                          if (data.isEmpty) {
                            return _buildNoExhibitions();
                          }

                          return Column(
                            spacing: 8.h,
                            children: List.generate(data.length, (index) {
                              var item = data[index];
                              return ExhibitListItem(item: item);
                            }),
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
                              children: [
                                const ExhibitListItemSkeleton(),
                                SizedBox(height: 8.h),
                                const ExhibitListItemSkeleton(),
                              ],
                            ),
                          );
                        },
                        onError: ({error}) => _buildNoExhibitions(),
                      );
                    },
                  ),
                ]),
              ),
            );
          },
          onLoading: () => _buildFullLoading(),
        );
      },
    );
  }

  GestureDetector _buildHeader() {
    return GestureDetector(
      onTap: () {},
      child: ColoredBox(
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ArtTripText.pretendard().title01Bold().build().text(
              context.l10n.weeklyExhibitionSchedule,
            ),
            SvgPicture.asset(
              AppAssets.icNoArrowRight,
              width: 24.w,
              height: 24.w,
            ),
          ],
        ),
      ),
    );
  }

  Padding _buildWeeklyCalendar(List<DateTime> currentWeek) {
    var locale = Localizations.localeOf(context);

    return Padding(
      padding: EdgeInsetsGeometry.only(top: 8.h, bottom: 20.h),
      child: SizedBox(
        height: 50.h,
        child: Selector<HomeViewModel, DateTime>(
          selector: (_, vm) => vm.selectedDateInWeek,
          builder: (context, selectedDateInWeek, _) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(currentWeek.length, (index) {
                var date = currentWeek[index];
                var isToday = DateUtils.isSameDay(date, selectedDateInWeek);
                var weekDay = AppUtil.weekdayLabel(date: date, locale: locale);
                return GestureDetector(
                  onTap: () {
                    var homeViewModel = Provider.of<HomeViewModel>(
                      context,
                      listen: false,
                    );
                    homeViewModel.updateSelectedDateInWeek(date);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 1.w,
                      vertical: 1.h,
                    ),
                    color: Colors.transparent,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 28.w,
                          height: 28.w,
                          alignment: Alignment.center,
                          decoration:
                              isToday
                                  ? const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.textPoint,
                                  )
                                  : null,
                          child:
                              isToday
                                  ? ArtTripText.pretendard()
                                      .body01Bold()
                                      .color(AppColors.textWhite)
                                      .build()
                                      .text(date.day.toString())
                                  : ArtTripText.pretendard()
                                      .body01Regular()
                                      .textAlign(TextAlign.center)
                                      .build()
                                      .text(date.day.toString()),
                        ),
                        isToday
                            ? ArtTripText.pretendard()
                                .body01Bold()
                                .color(AppColors.textPoint)
                                .textAlign(TextAlign.center)
                                .build()
                                .text(weekDay)
                            : ArtTripText.pretendard()
                                .body01Light()
                                .textAlign(TextAlign.center)
                                .build()
                                .text(weekDay),
                      ],
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildFullLoading() {
    return SliverToBoxAdapter(
      child: Shimmer(
        duration: const Duration(milliseconds: AppConsts.shimmerDurationMs),
        interval: const Duration(milliseconds: AppConsts.shimmerIntervalMs),
        child: Padding(
          padding: EdgeInsets.only(left: 24.w, top: 32.h, right: 24.w),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const ShimmerSkeletonItem(width: 160, height: 20),
                  SvgPicture.asset(
                    AppAssets.icNoArrowRight,
                    width: 24.w,
                    height: 24.w,
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (index) {
                  return Column(
                    spacing: 4.h,
                    children: [
                      const ShimmerSkeletonItem(width: 28, height: 28),
                      const ShimmerSkeletonItem(width: 16, height: 16),
                    ],
                  );
                }),
              ),
              SizedBox(height: 20.h),
              const ExhibitListItemSkeleton(),
              SizedBox(height: 8.h),
              const ExhibitListItemSkeleton(),
            ],
          ),
        ),
      ),
    );
  }

  Container _buildNoExhibitions() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: 28.w,
        top: 24.h,
        right: 27.w,
        bottom: 28.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.subLightGray,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        spacing: 8.h,
        children: [
          SvgPicture.asset(AppAssets.icNotFound, width: 40.w, height: 40.w),
          ArtTripText.pretendard()
              .body01Regular()
              .color(AppColors.textTertiary)
              .textAlign(TextAlign.center)
              .build()
              .text(context.l10n.noOngoingExhibitionsOnDate),
        ],
      ),
    );
  }
}
