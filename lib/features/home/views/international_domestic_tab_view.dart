import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/home/home_viewmodel.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:arttrip/shared/widgets/future_when.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class InternationalDomesticTabView extends StatefulWidget {
  const InternationalDomesticTabView({super.key});

  @override
  State<InternationalDomesticTabView> createState() =>
      _InternationalDomesticTabViewState();
}

class _InternationalDomesticTabViewState
    extends State<InternationalDomesticTabView>
    with TickerProviderStateMixin {
  final ValueNotifier<Future<List<String>?>?> _regionsFuture = ValueNotifier(
    null,
  );
  final ValueNotifier<int> _selectedRegionIndex = ValueNotifier(0);
  List<GlobalKey>? _itemKeys;
  String? allItem;

  @override
  void initState() {
    super.initState();
    _regionsFuture.value = Provider.of<HomeViewModel>(
      context,
      listen: false,
    ).fetchOverseasCountries();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    allItem ??= context.l10n.allItems;
  }

  void _updateSelectedRegionIndex(int index, String? region) {
    _selectedRegionIndex.value = index;
    Provider.of<HomeViewModel>(
      context,
      listen: false,
    ).updateSelectedRegion(region ?? allItem!);
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
              child: ValueListenableBuilder(
                valueListenable: _regionsFuture,
                builder: (context, regionsFuture, _) {
                  var homeViewModel = Provider.of<HomeViewModel>(
                    context,
                    listen: false,
                  );
                  return FutureWhen(
                    future:
                        regionsFuture ?? homeViewModel.fetchOverseasCountries(),
                    data: (data) {
                      if (data?.isEmpty ?? true) return const SizedBox.shrink();

                      _selectedRegionIndex.value = 0; // 데이터 호출이 빠를 수 있어서 초기화 추가
                      var itemCount = !homeViewModel.isDomestic
                          ? data!.length + 1
                          : data!.length;
                      _itemKeys = List.generate(itemCount, (_) => GlobalKey());

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _updateSelectedRegionIndex(
                          0,
                          !homeViewModel.isDomestic ? allItem! : data[0],
                        );
                      });

                      return ListView.separated(
                        shrinkWrap: true,
                        itemCount: itemCount,
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(
                          vertical: 16.h,
                          horizontal: 24.w,
                        ),
                        separatorBuilder: (context, index) =>
                            SizedBox(width: 8.w),
                        itemBuilder: (context, index) {
                          return _buildRegionItem(
                            _itemKeys![index],
                            index,
                            !homeViewModel.isDomestic
                                ? index == 0
                                      ? null
                                      : data[index - 1]
                                : data[index],
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
        controller: TabController(length: 2, vsync: this),
        padding: EdgeInsets.symmetric(horizontal: 12.w),
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
        labelStyle: ArtTripText.pretendard()
            .title01Bold()
            .color(AppColors.textPoint)
            .build()
            .style(),
        unselectedLabelStyle: ArtTripText.pretendard()
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
          if (index == 0) {
            _regionsFuture.value = homeViewModel.fetchOverseasCountries();
          } else {
            _regionsFuture.value = homeViewModel.fetchDomesticRegions();
          }
        },
      ),
    );
  }

  GestureDetector _buildRegionItem(GlobalKey key, int index, String? country) {
    return GestureDetector(
      onTap: () {
        if (_selectedRegionIndex.value != index) {
          _updateSelectedRegionIndex(index, index == 0 ? allItem! : country!);
        }
      },
      child: ValueListenableBuilder(
        valueListenable: _selectedRegionIndex,
        builder: (context, selectedRegionIndex, _) {
          var isSelected = index == selectedRegionIndex;
          return Container(
            key: key,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
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
                .text(country ?? context.l10n.allItems),
          );
        },
      ),
    );
  }
}
