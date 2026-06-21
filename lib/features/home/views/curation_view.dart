import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_consts.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/exhibit/viewmodels/exhibit_viewmodel.dart';
import 'package:arttrip/features/home/data/models/curation_model.dart';
import 'package:arttrip/features/home/home_viewmodel.dart';
import 'package:arttrip/features/home/widgets/home_no_exhibits_view.dart';
import 'package:arttrip/features/home/widgets/today_exhibit_widget.dart';
import 'package:arttrip/routes/app_routes.dart';
import 'package:arttrip/routes/routes.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:arttrip/shared/widgets/async_view.dart';
import 'package:arttrip/shared/widgets/shimmer_skeleton_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class CurationView extends StatefulWidget {
  const CurationView(this.isDomestic, {super.key});

  final bool isDomestic;

  @override
  State<CurationView> createState() => _CurationViewState();
}

class _CurationViewState extends State<CurationView> {
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.only(top: 32.h),
      sliver: SliverToBoxAdapter(
        child: Selector<HomeViewModel, String>(
          selector: (_, vm) =>
              vm.area[vm.locationType] ?? context.l10n.allItems,
          builder: (context, area, _) {
            return Selector<HomeViewModel, AsyncState<CurationModel>>(
              selector: (_, vm) =>
                  vm.curations[vm.locationType]?[vm.area[vm.locationType]!] ??
                  const AsyncState.error(),
              builder: (context, state, _) {
                return AsyncView(
                  state: state,
                  onData: (data) {
                    if (data.exhibits.isEmpty) {
                      return _buildEmptyView(
                        data.title,
                        data.subtitle,
                        data.curationId.toString(),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 12.h,
                      children: [
                        /// 제목
                        _buildHeader(
                          data.title,
                          data.subtitle,
                          data.curationId.toString(),
                        ),

                        /// 큐레이션
                        SizedBox(
                          height: 240.h,
                          child: ListView.separated(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: data.exhibits.length,
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            separatorBuilder: (context, index) =>
                                SizedBox(width: 8.w),
                            itemBuilder: (context, index) {
                              final item = data.exhibits[index];
                              return Selector<ExhibitViewModel, bool>(
                                selector: (_, vm) =>
                                    vm.isFavorite(item.exhibitId),
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
                                    onTap: () => Routes.push(
                                      context,
                                      AppRoutes.exhibitPath(item.exhibitId),
                                    ),
                                    favoriteOnTap: () {
                                      final exhibitVM = context
                                          .read<ExhibitViewModel>();
                                      exhibitVM.updateFavoriteExhibit(
                                        item.exhibitId,
                                        !isFavorite,
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                  onLoading: () => _buildCurationLoadingView(),
                  onError: ({error}) => _buildEmptyView('', '', '0'),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(String title, String subtitle, String curationId) {
    return GestureDetector(
      onTap: () {
        final homeVM = context.read<HomeViewModel>();
        final String? title = homeVM
            .curations[homeVM.locationType]?[homeVM.area[homeVM.locationType]!]
            ?.data
            ?.title;
        Routes.push(
          context,
          AppRoutes.homeCurationPath(
            curationTitle: title?.isNotEmpty == true
                ? title!
                : context.l10n.curationTitle,
            curationId: curationId,
            isDomestic: homeVM.isDomestic ? 'true' : 'false',
            country: homeVM.isDomestic
                ? null
                : homeVM.area[homeVM.locationType],
            region: homeVM.isDomestic ? homeVM.area[homeVM.locationType] : null,
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.only(left: 24.w, right: 24.w, bottom: 2.h),
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4.h,
          children: [
            Row(
              children: [
                ArtTripText.pretendard().title01Bold().build().text(title),
                const Expanded(child: SizedBox.shrink()),
                SvgPicture.asset(
                  AppAssets.icNoArrowRight,
                  width: 24.w,
                  height: 24.w,
                ),
              ],
            ),
            if (subtitle.isNotEmpty)
              ArtTripText.pretendard().body01Regular().build().text(subtitle),
          ],
        ),
      ),
    );
  }

  Widget _buildCurationLoadingView() {
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
          /// header
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
        ],
      ),
    );
  }

  Widget _buildEmptyView(String title, String subtitle, String curationId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12.h,
      children: [
        /// 제목
        _buildHeader(
          title.isEmpty ? context.l10n.curationTitle : title,
          subtitle,
          curationId,
        ),
        HomeNoExhibitsView(title: context.l10n.noCurationExhibitsTitle),
      ],
    );
  }
}
