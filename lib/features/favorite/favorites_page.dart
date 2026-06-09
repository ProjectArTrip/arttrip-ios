import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/app_utils.dart';
import 'package:arttrip/core/enum.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_model.dart';
import 'package:arttrip/features/exhibit/data/models/favorite_filter_model.dart';
import 'package:arttrip/features/exhibit/viewmodels/exhibit_viewmodel.dart';
import 'package:arttrip/features/home/home_viewmodel.dart';
import 'package:arttrip/shared/models/region_model.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:arttrip/shared/widgets/alert_badge.dart';
import 'package:arttrip/shared/widgets/async_view.dart';
import 'package:arttrip/shared/widgets/common_appbar.dart';
import 'package:arttrip/shared/widgets/exception_view.dart';
import 'package:arttrip/shared/widgets/exhibit_list_item.dart';
import 'package:arttrip/shared/widgets/exhibits_loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// 즐겨찾기 페이지
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<List<ExhibitModel>?> _exhibits = ValueNotifier([]);
  final ValueNotifier<SortType> _sortType = ValueNotifier(SortType.latest);
  final ValueNotifier<String?> _selectedOverseasCountry = ValueNotifier(null);
  final ValueNotifier<String?> _selectedDomesticArea = ValueNotifier(null);

  final ValueNotifier<bool> _isLoading = ValueNotifier(true); // 전체 로딩 상태
  final ValueNotifier<bool> _hasNext = ValueNotifier(true); // 다음 페이지 존재 여부
  final ValueNotifier<bool> _loadingMore = ValueNotifier(false); // 추가 로딩 상태

  final double _threshold = 50.0;
  final int _size = 10;
  int _cursor = 0;

  late int _lastRefreshTrigger;

  @override
  void initState() {
    super.initState();
    final exhibitVM = context.read<ExhibitViewModel>();
    _lastRefreshTrigger = exhibitVM.favoritesRefreshTrigger;
    exhibitVM.addListener(_onFavoritesRefreshTriggered);

    final homeVM = context.read<HomeViewModel>();
    Future.delayed(Duration.zero, () async {
      if (mounted) await homeVM.getDomesticRegions(context);
      if (homeVM.locationType == LocationType.overseas) {
        if (mounted) await homeVM.getOverseasCountries(context);
      }
      await _getFavoriteExhibits();
    });

    _scrollController.addListener(() async {
      // 데이터 로딩중이거나 더 불러올 데이터가 없으면 추가 로딩 방지
      if (_loadingMore.value || !_hasNext.value) return;

      final position = _scrollController.position;

      if (position.pixels >= position.maxScrollExtent - _threshold) {
        if (!_isLoading.value && _hasNext.value) {
          AppUtil.debugLog('now loading more');
          await _loadMoreExhibits();
        }
      }
    });
  }

  @override
  void dispose() {
    context.read<ExhibitViewModel>().removeListener(
      _onFavoritesRefreshTriggered,
    );
    _scrollController.dispose();
    super.dispose();
  }

  void _onFavoritesRefreshTriggered() {
    final exhibitVM = context.read<ExhibitViewModel>();

    final trigger = exhibitVM.favoritesRefreshTrigger;
    if (trigger != _lastRefreshTrigger) {
      _lastRefreshTrigger = trigger;
      _getFavoriteExhibits();
      return;
    }

    if (_exhibits.value != null) {
      _exhibits.value = _exhibits.value!
          .where(
            (e) => e.exhibitId != null && exhibitVM.isFavorite(e.exhibitId),
          )
          .toList();
    }
  }

  Future<void> _getFavoriteExhibits() async {
    _isLoading.value = true;
    _cursor = 0;

    final exhibitVM = Provider.of<ExhibitViewModel>(context, listen: false);
    final FavoriteFilterModel? result = await exhibitVM.getFavoriteFilters(
      cursor: _cursor,
      size: _size,
      sortType: _sortType.value.type,
      country: _selectedOverseasCountry.value,
      region: _selectedDomesticArea.value,
    );

    _exhibits.value = result?.favorites;
    _hasNext.value = result?.hasNext ?? false;
    _cursor = result?.nextCursor ?? 0;
    _isLoading.value = false;

    exhibitVM.initializeFromExhibits(result?.favorites ?? []);
  }

  Future<void> _loadMoreExhibits() async {
    if (!_hasNext.value) return;
    _loadingMore.value = true;

    final exhibitVM = context.read<ExhibitViewModel>();
    final result = await exhibitVM.getFavoriteFilters(
      cursor: _cursor,
      size: _size,
      sortType: _sortType.value.type,
      country: _selectedOverseasCountry.value,
      region: _selectedDomesticArea.value,
    );
    _exhibits.value = [...?_exhibits.value, ...?result?.favorites];
    _hasNext.value = result?.hasNext ?? false;
    _cursor = result?.nextCursor ?? 0;
    _loadingMore.value = false;

    exhibitVM.initializeFromExhibits(result?.favorites ?? []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        showBackButton: false,
        title: context.l10n.navStorage,
        actions: const [AlertBadge()],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _getFavoriteExhibits,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// 조회 결과 개수
                    Padding(
                      padding: EdgeInsets.only(top: 11.h, bottom: 19.h),
                      child: ValueListenableBuilder(
                        valueListenable: _exhibits,
                        builder: (context, exhibits, child) {
                          return ArtTripText.pretendard()
                              .title02Bold()
                              .build()
                              .text(
                                context.l10n.totalCount(exhibits?.length ?? 0),
                              );
                        },
                      ),
                    ),

                    /// 최신순, 마감순, 필터
                    ValueListenableBuilder(
                      valueListenable: _sortType,
                      builder: (context, sortType, child) {
                        return Row(
                          children: [
                            _buildSortType(
                              isSelected: sortType == SortType.latest,
                              sortType: SortType.latest,
                              sortTypeName: context.l10n.sortByLatest,
                            ),
                            Container(
                              width: 1.w,
                              height: 12.h,
                              margin: EdgeInsets.symmetric(horizontal: 8.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: AppColors.gray100,
                              ),
                            ),
                            _buildSortType(
                              isSelected: sortType == SortType.endingSoon,
                              sortType: SortType.endingSoon,
                              sortTypeName: context.l10n.sortByEndingSoon,
                            ),
                            SizedBox(width: 12.w),
                            GestureDetector(
                              onTap: () => _showFilterBottomSheet(),
                              child: SvgPicture.asset(
                                AppAssets.icFilter,
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

              /// 즐겨찾기 전시 리스트
              ValueListenableBuilder(
                valueListenable: _isLoading,
                builder: (context, isLoading, child) {
                  if (isLoading) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 12.h,
                          horizontal: 24.w,
                        ),
                        child: const ExhibitsLoadingView(),
                      ),
                    );
                  }

                  return ValueListenableBuilder(
                    valueListenable: _exhibits,
                    builder: (context, exhibits, child) {
                      if (exhibits == null) {
                        return const ExceptionView();
                      } else if (exhibits.isEmpty) {
                        return Expanded(
                          child: Column(
                            spacing: 8.h,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                AppAssets.icFavorite,
                                width: 96.w,
                                height: 96.w,
                              ),
                              ArtTripText.pretendard()
                                  .body01Regular()
                                  .color(AppColors.textTertiary)
                                  .build()
                                  .text(context.l10n.noFavorites),
                            ],
                          ),
                        );
                      }

                      return ValueListenableBuilder(
                        valueListenable: _loadingMore,
                        builder: (context, loadingMore, child) {
                          final int length =
                              exhibits.length + (loadingMore ? 1 : 0);

                          return Expanded(
                            child: ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              controller: _scrollController,
                              padding: EdgeInsets.only(
                                left: 24.w,
                                right: 24.w,
                                top: 8.h,
                                bottom: 16.h,
                              ),
                              itemCount: length,
                              separatorBuilder: (context, index) =>
                                  SizedBox(height: 12.h),
                              itemBuilder: (context, index) {
                                if (loadingMore && index == exhibits.length) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                final ExhibitModel item = exhibits[index];
                                return ExhibitListItem(
                                  item: item,
                                  isDomestic: false,
                                  showArea: true,
                                  forceFavorite: true,
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    final ValueNotifier<String?> tempOverseasCountry = ValueNotifier(
      _selectedOverseasCountry.value,
    );
    final ValueNotifier<String?> tempDomesticArea = ValueNotifier(
      _selectedDomesticArea.value,
    );
    final ValueNotifier<bool> isApplyEnabled = ValueNotifier(false);

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
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// 닫기 버튼
            Padding(
              padding: EdgeInsets.only(right: 4.w, top: 8.h, bottom: 8.h),
              child: Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: SvgPicture.asset(
                    AppAssets.icClose,
                    width: 24.w,
                    height: 24.w,
                  ),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 24.w,
                right: 24.w,
                bottom: 20.h,
              ),
              child: ValueListenableBuilder(
                valueListenable: tempOverseasCountry,
                builder: (context, overseasCountry, child) {
                  return ValueListenableBuilder(
                    valueListenable: tempDomesticArea,
                    builder: (context, domesticArea, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// 해외
                          Column(
                            spacing: 8.h,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ArtTripText.pretendard()
                                  .body01Bold()
                                  .build()
                                  .text(context.l10n.oversea),
                              Selector<HomeViewModel, AsyncState<List<String>>>(
                                selector: (_, vm) => vm.overseasCountries,
                                builder: (context, overseasCountries, _) {
                                  return AsyncView(
                                    state: overseasCountries,
                                    onData: (data) {
                                      return Wrap(
                                        spacing: 12.w,
                                        runSpacing: 12.h,
                                        children: List.generate(
                                          data.length,
                                          (index) {
                                            final item = data[index];
                                            final isSelected =
                                                overseasCountry == item ||
                                                (overseasCountry == null &&
                                                    index == 0);

                                            return GestureDetector(
                                              onTap: () {
                                                tempOverseasCountry.value =
                                                    item;
                                                isApplyEnabled.value = true;
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                  vertical: 8.h,
                                                  horizontal: 20.w,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? AppColors.primary300
                                                      : AppColors.gray0,
                                                  border: Border.all(
                                                    color: isSelected
                                                        ? Colors.transparent
                                                        : AppColors.gray100,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        100,
                                                      ),
                                                ),
                                                child: isSelected
                                                    ? ArtTripText.pretendard()
                                                          .body01Bold()
                                                          .color(
                                                            AppColors.textWhite,
                                                          )
                                                          .build()
                                                          .text(item)
                                                    : ArtTripText.pretendard()
                                                          .body01Light()
                                                          .build()
                                                          .text(item),
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),

                          Padding(
                            padding: EdgeInsetsGeometry.only(
                              top: 20.h,
                              bottom: 16.h,
                            ),
                            child: Divider(
                              height: 1.h,
                              color: AppColors.gray100,
                            ),
                          ),

                          /// 국내
                          Column(
                            spacing: 8.h,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ArtTripText.pretendard()
                                  .body01Bold()
                                  .build()
                                  .text(context.l10n.domestic),
                              Selector<
                                HomeViewModel,
                                AsyncState<List<RegionModel>>
                              >(
                                selector: (_, vm) => vm.domesticRegions,
                                builder: (context, regions, _) {
                                  return AsyncView(
                                    state: regions,
                                    onData: (data) {
                                      final tempList = List.from(data);
                                      final result = tempList.indexWhere(
                                        (e) =>
                                            e.region == context.l10n.allItems,
                                      );
                                      if (result == -1) {
                                        tempList.insert(
                                          0,
                                          RegionModel(
                                            region: context.l10n.allItems,
                                          ),
                                        );
                                      }

                                      return Wrap(
                                        spacing: 12.w,
                                        runSpacing: 12.h,
                                        children: List.generate(
                                          tempList.length,
                                          (index) {
                                            final item = tempList[index];
                                            final isSelected =
                                                domesticArea == item.region ||
                                                (domesticArea == null &&
                                                    index == 0);

                                            return GestureDetector(
                                              onTap: () {
                                                if (index == 0) {
                                                  tempDomesticArea.value = null;
                                                } else {
                                                  tempDomesticArea.value =
                                                      item.region;
                                                }
                                                isApplyEnabled.value = true;
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                  vertical: 8.h,
                                                  horizontal: 20.w,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? AppColors.primary300
                                                      : AppColors.gray0,
                                                  border: Border.all(
                                                    color: isSelected
                                                        ? Colors.transparent
                                                        : AppColors.gray100,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        100,
                                                      ),
                                                ),
                                                child: isSelected
                                                    ? ArtTripText.pretendard()
                                                          .body01Bold()
                                                          .color(
                                                            AppColors.textWhite,
                                                          )
                                                          .build()
                                                          .text(item.region)
                                                    : ArtTripText.pretendard()
                                                          .body01Light()
                                                          .build()
                                                          .text(item.region),
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),

            /// 전체 해제, 찾아보기
            Container(
              padding: EdgeInsets.only(left: 24.w, right: 24.w, top: 12.h),
              child: Row(
                spacing: 20.w,
                children: [
                  /// 전체 해제
                  GestureDetector(
                    onTap: () {
                      tempOverseasCountry.value = null;
                      tempDomesticArea.value = null;
                      isApplyEnabled.value = true;
                    },
                    child: ColoredBox(
                      color: Colors.transparent,
                      child: Column(
                        spacing: 4.h,
                        children: [
                          SvgPicture.asset(
                            AppAssets.icRefresh,
                            width: 24.w,
                            height: 24.w,
                          ),
                          ArtTripText.pretendard()
                              .body02Light()
                              .color(AppColors.textSecondary)
                              .build()
                              .text(context.l10n.resetAll),
                        ],
                      ),
                    ),
                  ),

                  /// 찾아보기
                  ValueListenableBuilder(
                    valueListenable: isApplyEnabled,
                    builder: (context, enabled, child) {
                      return Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary300,
                            padding: EdgeInsets.symmetric(vertical: 17.h),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            disabledBackgroundColor: AppColors.gray100,
                            overlayColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.circular(12.r),
                            ),
                          ),
                          onPressed: enabled
                              ? () {
                                  _selectedOverseasCountry.value =
                                      tempOverseasCountry.value;
                                  _selectedDomesticArea.value =
                                      tempDomesticArea.value;
                                  _getFavoriteExhibits();
                                  context.pop();
                                }
                              : null,
                          child: ArtTripText.pretendard()
                              .title02Bold()
                              .color(
                                enabled
                                    ? AppColors.textWhite
                                    : AppColors.textTertiary,
                              )
                              .build()
                              .text(context.l10n.apply),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortType({
    required bool isSelected,
    required SortType sortType,
    required String sortTypeName,
  }) {
    return GestureDetector(
      onTap: () {
        _sortType.value = sortType;
        _getFavoriteExhibits();
      },
      child: isSelected
          ? ArtTripText.pretendard()
                .body01Bold()
                .color(AppColors.textPoint)
                .build()
                .text(sortTypeName)
          : ArtTripText.pretendard()
                .body01Regular()
                .color(AppColors.textPrimary)
                .build()
                .text(sortTypeName),
    );
  }
}
