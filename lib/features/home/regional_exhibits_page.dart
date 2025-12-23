import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/home/home_viewmodel.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:arttrip/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class RegionalExhibitsPage extends StatefulWidget {
  const RegionalExhibitsPage(this.regionName, {super.key});

  final String regionName;

  @override
  State<RegionalExhibitsPage> createState() => _RegionalExhibitsPageState();
}

class _RegionalExhibitsPageState extends State<RegionalExhibitsPage> {
  final ValueNotifier<String?> _regionName = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    _regionName.value = widget.regionName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray0,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(52.h),
        child: ValueListenableBuilder(
          valueListenable: _regionName,
          builder: (context, regionName, _) {
            return CommonAppBar(title: regionName);
          },
        ),
      ),
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
                      _showFilterBottomSheet(_regionName.value!);
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

  void _showFilterBottomSheet(String selectedRegion) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.subLightGray,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: 244.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 8.h,
            children: [
              Container(
                alignment: Alignment.centerRight,
                margin: EdgeInsets.only(top: 16.h, right: 24.w, bottom: 8.h),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: SvgPicture.asset(
                    AppAssets.icClose,
                    width: 24.w,
                    height: 24.w,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8.h,
                  children: [
                    ArtTripText.pretendard().body01Bold().build().text(
                      context.l10n.domestic,
                    ),
                    Selector<HomeViewModel, List<String>>(
                      selector: (_, vm) => vm.domesticRegionsCache!,
                      builder: (context, domesticRegionsCache, _) {
                        return Wrap(
                          spacing: 12.w,
                          runSpacing: 12.h,
                          children: List.generate(domesticRegionsCache.length, (
                            index,
                          ) {
                            var item = domesticRegionsCache[index];
                            var isSelected = selectedRegion == item;
                            return GestureDetector(
                              onTap: () {
                                _regionName.value = item;
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 8.h,
                                  horizontal: 20.w,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? AppColors.primary300
                                          : AppColors.gray0,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child:
                                    isSelected
                                        ? ArtTripText.pretendard()
                                            .body01Bold()
                                            .color(AppColors.textWhite)
                                            .build()
                                            .text(item)
                                        : ArtTripText.pretendard()
                                            .body01Light()
                                            .build()
                                            .text(item),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
