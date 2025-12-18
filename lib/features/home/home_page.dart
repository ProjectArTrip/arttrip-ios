import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/home/home_viewmodel.dart';
import 'package:arttrip/features/home/views/genre_exhibition_view.dart';
import 'package:arttrip/features/home/views/international_domestic_tab_view.dart';
import 'package:arttrip/features/home/views/personalized_exhibition_view.dart';
import 'package:arttrip/features/home/views/regional_exhibition_view.dart';
import 'package:arttrip/features/home/views/today_exhibit_recommendation_view.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
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
      var homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
      homeViewModel.selectedLocation = context.l10n.allItems;
      homeViewModel.load(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray0,
      body: SafeArea(
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
          slivers: [
            _buildAppBar(),
            _buildExhibitionTabBar(),
            const InternationalDomesticTabView(),
            const TodayExhibitRecommendationView(),
            const PersonalizedExhibitionView(),
            Selector<HomeViewModel, bool>(
              selector: (_, vm) => vm.isDomestic,
              builder: (context, isDomestic, _) {
                return isDomestic
                    ? const RegionalExhibitionView()
                    : const SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),
            const GenreExhibitionView(),
            SliverToBoxAdapter(child: SizedBox(height: 24.h)),
          ],
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
            Row(
              spacing: 20.w,
              children: [
                GestureDetector(
                  onTap: () {},
                  child: SvgPicture.asset(
                    AppAssets.icNotification,
                    width: 24.w,
                    height: 24.w,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
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
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildExhibitionTabBar() {
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
        onTap: (index) {
          var homeViewModel = Provider.of<HomeViewModel>(
            context,
            listen: false,
          );
          homeViewModel.isDomestic = index == 0 ? false : true;
          homeViewModel.load(context);
        },
      ),
    );
  }
}
