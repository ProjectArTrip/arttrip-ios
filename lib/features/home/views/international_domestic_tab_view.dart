import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/home/home_viewmodel.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:arttrip/shared/widgets/async_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class InternationalDomesticTabView extends StatefulWidget {
  const InternationalDomesticTabView({super.key});

  @override
  State<InternationalDomesticTabView> createState() => _InternationalDomesticTabViewState();
}

class _InternationalDomesticTabViewState extends State<InternationalDomesticTabView> with TickerProviderStateMixin {
  List<GlobalKey>? _itemKeys;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _updateSelectedLocationIndex(int index, String location) {
    var homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
    homeViewModel.selectedLocation = location;
    homeViewModel.fetchTodayExhibitRecommendations();
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
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        switch (index) {
          /// tabbar
          case 0:
            return _buildExhibitionTabBar();

          /// countries
          case 1:
            return SizedBox(
              height: 64.h,
              child: Selector<HomeViewModel, AsyncState<List<String>>>(
                selector: (_, vm) => vm.locations,
                builder: (context, state, _) {
                  return AsyncView(
                    state: state,
                    onData: (data) {
                      if (data.isEmpty) return const SizedBox.shrink();

                      var itemCount = data.length;
                      _itemKeys = List.generate(itemCount, (_) => GlobalKey());

                      return ListView.separated(
                        shrinkWrap: true,
                        itemCount: itemCount,
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
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
                  );
                },
              ),
            );

          default:
            return const SizedBox.shrink();
        }
      }, childCount: 2),
    );
  }

  Container _buildExhibitionTabBar() {
    return Container(
      height: 28.h,
      margin: EdgeInsets.only(top: 16.h),
      child: TabBar(
        controller: _tabController,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        dividerHeight: 0,
        overlayColor: WidgetStateColor.resolveWith((states) => Colors.transparent),
        indicator: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.primary200, width: 2.w))),
        indicatorWeight: 2.h,
        labelStyle: ArtTripText.pretendard().title01Bold().color(AppColors.textPoint).build().style(),
        unselectedLabelStyle: ArtTripText.pretendard().title01Bold().color(AppColors.textTertiary).build().style(),
        labelPadding: EdgeInsets.symmetric(horizontal: 12.w),
        indicatorSize: TabBarIndicatorSize.label,
        tabAlignment: TabAlignment.start,
        isScrollable: true,
        tabs: [Tab(text: context.l10n.internationalExhibition), Tab(text: context.l10n.domesticExhibition)],
        onTap: (index) {
          var homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
          homeViewModel.isDomestic = index == 0 ? false : true;
          if (index == 0) {
            homeViewModel.fetchOverseasCountries(context);
          } else {
            homeViewModel.fetchDomesticRegions();
          }
        },
      ),
    );
  }

  GestureDetector _buildLocationItem(GlobalKey key, int index, String location) {
    return GestureDetector(
      onTap: () {
        var homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
        if (homeViewModel.selectedLocation != location) _updateSelectedLocationIndex(index, location);
      },
      child: Selector<HomeViewModel, String>(
        selector: (_, vm) => vm.selectedLocation,
        builder: (context, selectedLocationIndex, _) {
          var isSelected = location == selectedLocationIndex;
          return Container(
            key: key,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: isSelected ? AppColors.primary300 : AppColors.gray0,
              border: Border.all(color: isSelected ? AppColors.primary300 : AppColors.gray100, width: 1.w),
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
