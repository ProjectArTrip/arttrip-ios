import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/home/home_viewmodel.dart';
import 'package:arttrip/features/home/views/international_domestic_tab_view.dart';
import 'package:arttrip/features/home/views/today_exhibit_recommendation_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
      homeViewModel.selectedRegion = context.l10n.allItems;
      homeViewModel.load(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray0,
      appBar: AppBar(
        toolbarHeight: 52.h,
        backgroundColor: Colors.white,
        leadingWidth: 88.w + 24.w,
        leading: Padding(
          padding: EdgeInsets.only(left: 24.w),
          child: SvgPicture.asset(AppAssets.icLogoBlack, width: 88.w, height: 28.h),
        ),
        actions: [
          Row(
            spacing: 20.w,
            children: [
              GestureDetector(
                onTap: () {},
                child: SvgPicture.asset(AppAssets.icNotification, width: 24.w, height: 24.w),
              ),
              GestureDetector(onTap: () {}, child: SvgPicture.asset(AppAssets.icCalendar, width: 24.w, height: 24.w)),
              GestureDetector(
                onTap: () {},
                child: SvgPicture.asset(AppAssets.icSearch, width: 24.w, height: 24.w),
              ),
            ],
          ),
          SizedBox(width: 24.w),
        ],
      ),
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _scrollController,
        slivers: [
          const InternationalDomesticTabView(),
          const TodayExhibitRecommendationView(),
        ],
      ),
    );
  }
}
