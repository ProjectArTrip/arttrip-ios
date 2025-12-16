import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/features/home/views/international_domestic_tab_view.dart';
import 'package:arttrip/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

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
              GestureDetector(
                onTap: () {},
                child: SvgPicture.asset(AppAssets.icCalendar, width: 24.w, height: 24.w),
              ),
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
        ],
      ),
      // TODO: 임시 버튼 - 전시 상세 페이지 진입 테스트용
      floatingActionButton: FloatingActionButton(
        onPressed: () => Routes.push(context, '/exhibit/1'),
        backgroundColor: AppColors.primary300,
        child: const Icon(Icons.art_track, color: Colors.white),
      ),
    );
  }
}
