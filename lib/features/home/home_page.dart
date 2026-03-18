import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/home/home_viewmodel.dart';
import 'package:arttrip/features/home/views/domestic_overseas_view.dart';
import 'package:arttrip/features/home/views/genre_exhibits_view.dart';
import 'package:arttrip/features/home/views/personalized_exhibits_view.dart';
import 'package:arttrip/features/home/views/regional_exhibits_view.dart';
import 'package:arttrip/features/home/views/today_exhibits_recommendation_view.dart';
import 'package:arttrip/features/home/views/weekly_exhibits_schedule_view.dart';
import 'package:arttrip/features/home/widgets/date_filter_bottom_sheet.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:arttrip/shared/widgets/alert_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
      homeViewModel.selectedLocation = context.l10n.allItems;
      homeViewModel.load(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray0,
      body: SafeArea(
        child: Selector<HomeViewModel, bool>(
          selector: (_, vm) => vm.isDomestic,
          builder: (context, isDomestic, _) {
            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: _scrollController,
              slivers: [
                _buildAppBar(),
                _buildExhibitTabBar(),
                isDomestic
                    ? const SliverToBoxAdapter(child: SizedBox.shrink())
                    : const DomesticOverseasView(),
                SliverPadding(
                  padding: EdgeInsets.only(top: isDomestic ? 16.h : 0),
                  sliver: TodayExhibitsRecommendationView(isDomestic),
                ),
                const PersonalizedExhibitsView(),
                const WeeklyExhibitsScheduleView(),
                isDomestic
                    ? const RegionalExhibitsView()
                    : const SliverToBoxAdapter(child: SizedBox.shrink()),
                const GenreExhibitsView(),
                SliverToBoxAdapter(child: SizedBox(height: 24.h)),
              ],
            );
          },
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildAppBar() {
    return SliverToBoxAdapter(
      child: Container(
        color: AppColors.gray0,
        height: 52.h,
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SvgPicture.asset(AppAssets.icLogoBlack, width: 88.w, height: 28.h),
            Selector<HomeViewModel, bool>(
              selector: (_, vm) => vm.isDomestic,
              builder: (context, isDomestic, _) {
                return Row(
                  spacing: 20.w,
                  children: [
                    const AlertBadge(path: '/alerts'),
                    if (!isDomestic)
                      GestureDetector(
                        onTap: () => _showDateFilterBottomSheet(),
                        child: SvgPicture.asset(
                          AppAssets.icCalendar,
                          width: 24.w,
                          height: 24.w,
                        ),
                      ),
                    GestureDetector(
                      onTap: () {},
                      child: SvgPicture.asset(
                        AppAssets.icSearch,
                        width: 24.w,
                        height: 24.w,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildExhibitTabBar() {
    return SliverAppBar(
      pinned: true,
      toolbarHeight: 28.h + 8.h,
      elevation: 0,
      backgroundColor: AppColors.gray0,
      surfaceTintColor: AppColors.gray0,
      flexibleSpace: TabBar(
        controller: _tabController,
        padding: EdgeInsets.only(left: 12.w, right: 12.w, bottom: 8.h),
        dividerHeight: 0,
        overlayColor: WidgetStateColor.resolveWith(
          (states) => Colors.transparent,
        ),
        indicator: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.primary200, width: 2.w),
          ),
        ),
        indicatorWeight: 2.h,
        labelStyle:
            ArtTripText.pretendard()
                .title01Bold()
                .color(AppColors.textPoint)
                .build()
                .style(),
        unselectedLabelStyle:
            ArtTripText.pretendard()
                .title01Bold()
                .color(AppColors.textTertiary)
                .build()
                .style(),
        labelPadding: EdgeInsets.symmetric(horizontal: 12.w),
        indicatorSize: TabBarIndicatorSize.label,
        tabAlignment: TabAlignment.start,
        isScrollable: true,
        tabs: [
          Tab(text: context.l10n.internationalExhibition),
          Tab(text: context.l10n.domesticExhibition),
        ],
        onTap: (index) async {
          final homeViewModel = Provider.of<HomeViewModel>(
            context,
            listen: false,
          );
          if (index == (homeViewModel.isDomestic ? 1 : 0)) return;

          homeViewModel.isDomestic = index == 0 ? false : true;
          await homeViewModel.load(context);
        },
      ),
    );
  }

  void _showDateFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
      ),
      backgroundColor: AppColors.subLightGray,
      isScrollControlled: true,
      builder:
          (_) => Selector<HomeViewModel, List<String>?>(
            selector: (_, vm) => vm.overseasCountriesCache,
            builder: (context, overseasCountries, _) {
              if (overseasCountries == null) {
                return Container(
                  height: MediaQuery.of(context).size.height / 2,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(
                    color: AppColors.primary300,
                  ),
                );
              }
              return DateFilterBottomSheet(overseasCountries);
            },
          ),
    );
  }
}
