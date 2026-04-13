import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/app_utils.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_filter_model.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_model.dart';
import 'package:arttrip/features/exhibit/viewmodels/exhibit_viewmodel.dart';
import 'package:arttrip/features/home/home_viewmodel.dart';
import 'package:arttrip/shared/models/region_model.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:arttrip/shared/widgets/alert_badge.dart';
import 'package:arttrip/shared/widgets/common_appbar.dart';
import 'package:arttrip/shared/widgets/exception_view.dart';
import 'package:arttrip/shared/widgets/exhibit_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class RegionDetailPage extends StatefulWidget {
  const RegionDetailPage(this.regionName, {super.key});

  final String regionName;

  @override
  State<RegionDetailPage> createState() => _RegionDetailPageState();
}

class _RegionDetailPageState extends State<RegionDetailPage> {
  final ScrollController _scrollController = ScrollController();
  late ValueNotifier<String> _selectedRegion;
  final ValueNotifier<bool> _isOpenDropDown = ValueNotifier(false);
  final ValueNotifier<List<ExhibitModel>?> _exhibits = ValueNotifier([]);
  final ValueNotifier<bool> _isLoading = ValueNotifier(true); // 전체 로딩 상태
  final ValueNotifier<bool> _hasNext = ValueNotifier(true); // 다음 페이지 존재 여부
  final ValueNotifier<bool> _loadingMore = ValueNotifier(false); // 추가 로딩 상태

  final double threshold = 50.0;
  final int _size = 10;
  int _cursor = 0;

  @override
  void initState() {
    super.initState();
    _selectedRegion = ValueNotifier(widget.regionName);
    Future.delayed(Duration.zero, () => _getRegionExhibits());

    _scrollController.addListener(() async {
      // 데이터 로딩중이거나 더 불러올 데이터가 없으면 추가 로딩 방지
      if (_loadingMore.value || !_hasNext.value) return;

      final position = _scrollController.position;

      if (position.pixels >= position.maxScrollExtent - threshold) {
        if (!_isLoading.value && _hasNext.value) {
          AppUtil.debugLog('now loading more');
          await _loadMoreExhibits();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _getRegionExhibits() async {
    _isLoading.value = true;

    final exhibitVM = Provider.of<ExhibitViewModel>(
      context,
      listen: false,
    );
    final ExhibitFilterModel? result = await exhibitVM.getExhibitFilters(
      isDomestic: true,
      region: _selectedRegion.value,
      cursor: _cursor,
      size: _size,
    );

    _exhibits.value = result?.exhibits;
    _hasNext.value = result?.hasNext ?? false;
    _cursor = result?.nextCursor ?? 0;
    _isLoading.value = false;
  }

  Future<void> _loadMoreExhibits() async {
    if (!_hasNext.value) return;
    _loadingMore.value = true;

    final exhibitVM = context.read<ExhibitViewModel>();
    final result = await exhibitVM.getExhibitFilters(
      isDomestic: true,
      region: _selectedRegion.value,
      cursor: _cursor,
      size: _size,
    );
    _exhibits.value = [...?_exhibits.value, ...?result?.exhibits];
    _hasNext.value = result?.hasNext ?? false;
    _cursor = result?.nextCursor ?? 0;
    _loadingMore.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray0,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(52.h),
        child: ValueListenableBuilder(
          valueListenable: _selectedRegion,
          builder: (context, selectedRegion, _) {
            return CommonAppBar(
              elevation: 1.h,
              titleWidget: Center(
                child: Selector<HomeViewModel, List<RegionModel>>(
                  selector: (_, vm) => vm.domesticRegions.data ?? [],
                  builder: (context, regions, _) {
                    return GestureDetector(
                      onTap: () =>
                          _isOpenDropDown.value = !_isOpenDropDown.value,
                      child: Container(
                        width: double.infinity,
                        color: Colors.transparent,
                        child: Row(
                          spacing: 4.w,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ArtTripText.pretendard().headline().build().text(
                              selectedRegion,
                            ),
                            ValueListenableBuilder(
                              valueListenable: _isOpenDropDown,
                              builder: (context, isOpenDropDown, child) {
                                return SvgPicture.asset(
                                  isOpenDropDown
                                      ? AppAssets.icNoArrowUp
                                      : AppAssets.icNoArrowDown,
                                  width: 24.w,
                                  height: 24.w,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              actions: const [AlertBadge()],
            );
          },
        ),
      ),
      body: Stack(
        children: [
          ValueListenableBuilder(
            valueListenable: _isLoading,
            builder: (context, isLoading, child) {
              if (isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return ValueListenableBuilder(
                valueListenable: _exhibits,
                builder: (context, exhibits, child) {
                  if (exhibits == null) {
                    return const ExceptionView();
                  }

                  return ValueListenableBuilder(
                    valueListenable: _loadingMore,
                    builder: (context, loadingMore, child) {
                      final int length =
                          exhibits.length + (loadingMore ? 1 : 0);
                      return ListView.separated(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: length,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 12.h,
                        ),
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 12.h),
                        itemBuilder: (context, index) {
                          if (loadingMore && index == exhibits.length) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final item = exhibits[index];
                          return ExhibitListItem(item: item);
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
          ValueListenableBuilder(
            valueListenable: _isOpenDropDown,
            builder: (context, isOpenDropDown, child) {
              return GestureDetector(
                onTap: () => _isOpenDropDown.value = false,
                child: IgnorePointer(
                  ignoring: !isOpenDropDown,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    color: _isOpenDropDown.value
                        ? const Color(0xFF000000).withValues(alpha: 0.6)
                        : Colors.transparent,
                  ),
                ),
              );
            },
          ),

          /// 지역 슬라이드 패널
          ValueListenableBuilder(
            valueListenable: _isOpenDropDown,
            builder: (context, isOpenDropDown, child) {
              return AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                top: isOpenDropDown ? 0 : -396.h,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  ignoring: !isOpenDropDown,
                  child: Container(
                    height: 396.h,
                    decoration: BoxDecoration(
                      color: AppColors.textWhite,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(16.r),
                      ),
                    ),
                    child: Selector<HomeViewModel, List<RegionModel>>(
                      selector: (_, vm) => vm.domesticRegions.data ?? [],
                      builder: (context, regions, _) {
                        return ListView.separated(
                          itemCount: regions.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 4.h),
                          itemBuilder: (context, index) {
                            final item = regions[index];
                            return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0),
                                ),
                              ),
                              onPressed: () {
                                _selectedRegion.value = item.region;
                                _isOpenDropDown.value = false;
                                _getRegionExhibits();
                              },
                              child: Padding(
                                padding: EdgeInsetsGeometry.symmetric(
                                  vertical: 16.h,
                                ),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: ArtTripText.pretendard()
                                      .title01Light()
                                      .textAlign(TextAlign.center)
                                      .build()
                                      .text(item.region),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
