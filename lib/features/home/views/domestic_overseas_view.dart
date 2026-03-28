import 'package:arttrip/core/app_colors.dart';
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

class DomesticOverseasView extends StatefulWidget {
  const DomesticOverseasView({super.key});

  @override
  State<DomesticOverseasView> createState() => _DomesticOverseasViewState();
}

class _DomesticOverseasViewState extends State<DomesticOverseasView> {
  List<GlobalKey>? _itemKeys;

  void _updateSelectedLocation(int index, String location) {
    final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
    homeViewModel.updateSelectedLocation(location);
    if (_itemKeys![index].currentContext != null) {
      Scrollable.ensureVisible(
        _itemKeys![index].currentContext!,
        alignment: 0.5,
        duration: const Duration(milliseconds: 500),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 64.h,
        child: Selector<HomeViewModel, AsyncState<List<String>>>(
          selector: (_, vm) => vm.overseasCountries,
          builder: (context, state, _) {
            return AsyncView(
              state: state,
              onData: (data) {
                if (data.isEmpty) return const SizedBox.shrink();

                final itemCount = data.length;
                _itemKeys = List.generate(itemCount, (_) => GlobalKey());

                return ListView.separated(
                  shrinkWrap: true,
                  itemCount: itemCount,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.only(
                    left: 24.w,
                    top: 8.h,
                    right: 24.w,
                    bottom: 16.h,
                  ),
                  separatorBuilder: (context, index) => SizedBox(width: 8.w),
                  itemBuilder: (context, index) {
                    return _buildLocationItem(
                      _itemKeys![index],
                      index,
                      data[index],
                    );
                  },
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
                    height: 64.h,
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 16.h,
                      ),
                      itemCount: 5,
                      separatorBuilder:
                          (context, index) => SizedBox(width: 8.w),
                      itemBuilder: (context, index) {
                        return const ShimmerSkeletonItem(width: 76, height: 32);
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  GestureDetector _buildLocationItem(
    GlobalKey key,
    int index,
    String location,
  ) {
    return GestureDetector(
      onTap: () {
        final homeViewModel = Provider.of<HomeViewModel>(
          context,
          listen: false,
        );
        if (homeViewModel.area != location) {
          _updateSelectedLocation(index, location);
        }
      },
      child: Selector<HomeViewModel, String>(
        selector: (_, vm) => vm.area ?? context.l10n.allItems,
        builder: (context, selectedArea, _) {
          final isSelected = location == selectedArea;
          return Container(
            key: key,
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 20.w),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: isSelected ? AppColors.primary300 : AppColors.gray0,
              border: Border.all(
                color: isSelected ? AppColors.primary300 : AppColors.gray100,
                width: 1.w,
              ),
            ),
            child: ArtTripText.pretendard()
                .body01Bold()
                .color(isSelected ? AppColors.textWhite : AppColors.textPrimary)
                .build()
                .text(location),
          );
        },
      ),
    );
  }
}
