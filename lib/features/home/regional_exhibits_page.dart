import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:arttrip/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RegionalExhibitsPage extends StatefulWidget {
  const RegionalExhibitsPage(this.regionName, {super.key});

  final String regionName;

  @override
  State<RegionalExhibitsPage> createState() => _RegionalExhibitsPageState();
}

class _RegionalExhibitsPageState extends State<RegionalExhibitsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray0,
      appBar: CommonAppBar(title: widget.regionName),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            surfaceTintColor: AppColors.gray0,
            backgroundColor: AppColors.gray0,
            elevation: 0,
            toolbarHeight: 40.h,
            leading: const SizedBox.shrink(),
            flexibleSpace: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // TODO: 개수 수정
                  ArtTripText.pretendard().title02Bold().build().text(
                    context.l10n.totalCount(5),
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: 필터 기능 추가
                    },
                    child: SvgPicture.asset(
                      AppAssets.icFilter,
                      width: 24.w,
                      height: 24.w,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsetsGeometry.only(
              left: 24.w,
              top: 8.h,
              right: 24.w,
              bottom: 72.h,
            ),
            sliver: SliverList.separated(
              itemCount: 10,
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                // TODO: API 추가 예정
                return Container();
              },
            ),
          ),
        ],
      ),
    );
  }
}
