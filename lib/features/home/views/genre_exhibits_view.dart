import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/app_consts.dart';
import 'package:arttrip/core/enum.dart';
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

class GenreExhibitsView extends StatefulWidget {
  const GenreExhibitsView({super.key});

  @override
  State<GenreExhibitsView> createState() => _GenreExhibitsViewState();
}

class _GenreExhibitsViewState extends State<GenreExhibitsView> {
  List<GlobalKey>? _itemKeys;

  void _updateSelectedGenre(int index, String genre) {
    var homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
    homeViewModel.selectedGenre = genre;
    homeViewModel.fetchExhibitsByGenre();
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
      child: Selector<HomeViewModel, AsyncState<List<String>>>(
        selector:
            (_, vm) =>
                vm.genres[vm.isDomestic
                    ? LocationType.domestic.name
                    : LocationType.overseas.name]!,
        builder: (context, state, _) {
          return AsyncView(
            state: state,
            onData: (genres) {
              if (genres.isEmpty) return const SizedBox.shrink();

              var itemCount = genres.length;
              _itemKeys = List.generate(itemCount, (_) => GlobalKey());

              return Padding(
                padding: EdgeInsetsGeometry.only(top: 32.h),
                child: Column(
                  children: [
                    _buildHeader(),

                    /// 장르 리스트
                    SizedBox(
                      height: 64.h,
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: itemCount,
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(
                          vertical: 16.h,
                          horizontal: 24.w,
                        ),
                        separatorBuilder:
                            (context, index) => SizedBox(width: 8.w),
                        itemBuilder: (context, index) {
                          return _buildGenreItem(
                            _itemKeys![index],
                            index,
                            genres[index],
                          );
                        },
                      ),
                    ),

                    /// 장르별 랜덤 전시
                    Selector<HomeViewModel, AsyncState<List<ExhibitModel>>>(
                      selector:
                          (_, vm) =>
                              vm.exhibitsByGenre[vm.isDomestic
                                  ? LocationType.domestic.name
                                  : LocationType.overseas.name]!,
                      builder: (context, state, _) {
                        return AsyncView(
                          state: state,
                          onData: (data) {
                            if (data.isEmpty) {
                              var selectedGenre =
                                  Provider.of<HomeViewModel>(
                                    context,
                                    listen: false,
                                  ).selectedGenre;
                              return _buildNoExhibitions(selectedGenre);
                            }
                            return ListView.separated(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: data.length,
                              padding: EdgeInsets.symmetric(horizontal: 24.w),
                              separatorBuilder:
                                  (context, index) => SizedBox(height: 8.h),
                              itemBuilder: (context, index) {
                                var item = data[index];
                                return ExhibitListItem(item: item);
                              },
                            );
                          },
                          onLoading:
                              () => Shimmer(
                                duration: const Duration(
                                  milliseconds: AppConsts.shimmerDurationMs,
                                ),
                                interval: const Duration(
                                  milliseconds: AppConsts.shimmerIntervalMs,
                                ),
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24.w,
                                  ),
                                  itemCount: 2,
                                  separatorBuilder:
                                      (context, index) => SizedBox(height: 8.h),
                                  itemBuilder: (context, index) {
                                    return const ExhibitListItemSkeleton();
                                  },
                                ),
                              ),
                        );
                      },
                    ),
                  ],
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
                child: Padding(
                  padding: EdgeInsets.only(top: 28.h),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Row(
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
                      ),
                      SizedBox(
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
                            return const ShimmerSkeletonItem(
                              width: 76,
                              height: 32,
                            );
                          },
                        ),
                      ),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        itemCount: 2,
                        separatorBuilder:
                            (context, index) => SizedBox(height: 8.h),
                        itemBuilder: (context, index) {
                          return const ExhibitListItemSkeleton();
                        },
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

  GestureDetector _buildHeader() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.only(left: 24.w, right: 24.w, bottom: 2.h),
        color: Colors.transparent,
        child: Row(
          children: [
            ArtTripText.pretendard().title01Bold().build().text(
              context.l10n.recommendedGenreExhibition,
            ),
            const Expanded(child: SizedBox.shrink()),
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

  GestureDetector _buildGenreItem(GlobalKey key, int index, String genre) {
    return GestureDetector(
      onTap: () {
        var homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
        if (homeViewModel.selectedGenre != genre) {
          _updateSelectedGenre(index, genre);
        }
      },
      child: Selector<HomeViewModel, String>(
        selector: (_, vm) => vm.selectedGenre,
        builder: (context, selectedGenreIndex, _) {
          var isSelected = genre == selectedGenreIndex;
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
                .text(genre),
          );
        },
      ),
    );
  }

  Container _buildNoExhibitions(String genre) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 24.w),
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
              .text(context.l10n.noExhibitionsInGenre(genre)),
        ],
      ),
    );
  }
}
