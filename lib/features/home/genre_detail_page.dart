import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/app_utils.dart';
import 'package:arttrip/core/enum.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_model.dart';
import 'package:arttrip/features/exhibit/viewmodels/exhibit_viewmodel.dart';
import 'package:arttrip/features/home/home_viewmodel.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:arttrip/shared/widgets/alert_badge.dart';
import 'package:arttrip/shared/widgets/common_appbar.dart';
import 'package:arttrip/shared/widgets/exhibit_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// 장르별 전시 전체 목록 화면
class GenreDetailPage extends StatefulWidget {
  const GenreDetailPage({
    super.key,
    required this.genreName,
    required this.isDomestic,
    this.region,
    this.country,
  });

  final String genreName;
  final bool isDomestic;
  final String? region;
  final String? country;

  @override
  State<GenreDetailPage> createState() => _GenreDetailPageState();
}

class _GenreDetailPageState extends State<GenreDetailPage> {
  final double threshold = 50.0;
  final ValueNotifier<SortType> _selectedSortType = ValueNotifier(
    SortType.latest,
  );
  late ValueNotifier<String> _selectedGenre;
  final ValueNotifier<List<ExhibitModel>?> _exhibits = ValueNotifier([]);
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _isLoading = ValueNotifier(true); // 전체 로딩 상태
  final ValueNotifier<bool> _hasNext = ValueNotifier(true); // 다음 페이지 존재 여부
  final ValueNotifier<bool> _loadingMore = ValueNotifier(false); // 추가 로딩 상태

  final int _size = 10;
  int _cursor = 0;

  @override
  void initState() {
    super.initState();
    _selectedGenre = ValueNotifier(widget.genreName);
    final exhibitVM = context.read<ExhibitViewModel>();
    Future.delayed(Duration.zero, () async {
      final result = await exhibitVM.getExhibitFilters(
        isDomestic: widget.isDomestic,
        cursor: _cursor,
        size: _size,
        country: widget.country,
        region: widget.region,
        genres: widget.genreName,
        sortType: SortType.latest.type,
      );
      _exhibits.value = result;
      _isLoading.value = false;

      if ((result?.isEmpty ?? true) || (result?.length ?? _size) < _size) {
        _hasNext.value = false;
        AppUtil.debugLog('No more exhibits to load: ${_hasNext.value}');
      }
    });

    _scrollController.addListener(_scrollControllerListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollControllerListener() async {
    if (_loadingMore.value) return;
    AppUtil.debugLog('now loading more');
    _loadingMore.value = true;

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - threshold) {
      if (!_isLoading.value && _hasNext.value) {
        await _loadMoreExhibits();
      }
    }
    _loadingMore.value = false;
  }

  Future<void> _loadMoreExhibits() async {
    if (!_hasNext.value) return;

    ++_cursor;
    final exhibitVM = context.read<ExhibitViewModel>();
    final result = await exhibitVM.getExhibitFilters(
      isDomestic: widget.isDomestic,
      cursor: _cursor,
      size: _size,
      country: widget.country,
      region: widget.region,
      genres: _selectedGenre.value,
      sortType: _selectedSortType.value.type,
    );
    _exhibits.value = [...?_exhibits.value, ...?result];
    if ((result?.isEmpty ?? true) || (result?.length ?? _size) < _size) {
      _hasNext.value = false;
      AppUtil.debugLog('No more exhibits to load: ${_hasNext.value}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        titleWidget: ValueListenableBuilder(
          valueListenable: _selectedGenre,
          builder: (context, selectedGenre, _) => ArtTripText.pretendard()
              .headline()
              .build()
              .text(context.l10n.genreDetailExhibition(selectedGenre)),
        ),
        actions: const [AlertBadge()],
      ),
      body: ListView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 24.h),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// 조회 결과 개수
              Padding(
                padding: EdgeInsets.symmetric(vertical: 11.h),
                child: ValueListenableBuilder(
                  valueListenable: _exhibits,
                  builder: (context, exhibits, child) {
                    return ArtTripText.pretendard().title02Bold().build().text(
                      context.l10n.totalCount(exhibits?.length ?? 0),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsetsGeometry.symmetric(vertical: 8.h),
                child: GestureDetector(
                  onTap: () => _buildFilterSheet(),
                  child: SvgPicture.asset(
                    AppAssets.icFilter,
                    width: 24.w,
                    height: 24.w,
                  ),
                ),
              ),
            ],
          ),

          /// 전시 리스트
          ValueListenableBuilder(
            valueListenable: _isLoading,
            builder: (context, isLoading, child) {
              if (isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return ValueListenableBuilder(
                valueListenable: _exhibits,
                builder: (context, exhibits, _) {
                  if (exhibits == null) {
                    return const Center(
                      child: Text(
                        'Something went wrong',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    );
                  }
                  return ValueListenableBuilder(
                    valueListenable: _loadingMore,
                    builder: (context, loadingMore, child) {
                      final int length =
                          exhibits.length + (loadingMore ? 1 : 0);
                      return ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
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
                          return ExhibitListItem(item: item);
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  /// 필터 시트
  Future<void> _buildFilterSheet() {
    final ValueNotifier<String> tempSelectedGenre = ValueNotifier(
      _selectedGenre.value,
    );
    final ValueNotifier<SortType> tempSelectedSortType = ValueNotifier(
      _selectedSortType.value,
    );

    return showModalBottomSheet(
      context: context,
      useSafeArea: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
      ),
      backgroundColor: AppColors.subLightGray,
      isScrollControlled: true,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 24.w,
              right: 24.w,
              bottom: 32.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 정렬
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8.h,
                  children: [
                    ArtTripText.pretendard().body01Bold().build().text(
                      context.l10n.sort,
                    ),
                    ValueListenableBuilder(
                      valueListenable: tempSelectedSortType,
                      builder: (context, tempSortType, child) {
                        return Wrap(
                          spacing: 12.w,
                          children: List.generate(3, (index) {
                            late String sortTypeName;
                            switch (index) {
                              case 0:
                                sortTypeName = context.l10n.sortByLatest;
                                break;
                              case 1:
                                sortTypeName = context.l10n.sortByEndingSoon;
                                break;
                              case 2:
                                sortTypeName = context.l10n.sortByPopular;
                                break;
                            }

                            final isSelected =
                                tempSortType == SortType.values[index];
                            return _buildGenreFilterChips(
                              onTap: () {
                                tempSelectedSortType.value =
                                    SortType.values[index];
                              },
                              isSelected: isSelected,
                              displayName: sortTypeName,
                            );
                          }),
                        );
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Divider(height: 1.h, color: AppColors.gray100),
                ),

                /// 전시 장르
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8.h,
                  children: [
                    ArtTripText.pretendard().body01Bold().build().text(
                      context.l10n.exhibitGenre,
                    ),
                    Selector<HomeViewModel, List<String>>(
                      selector: (_, vm) => vm.genres.data ?? [],
                      builder: (context, genres, child) {
                        return ValueListenableBuilder(
                          valueListenable: tempSelectedGenre,
                          builder: (context, tempGenre, child) {
                            return Wrap(
                              spacing: 12.w,
                              runSpacing: 12.h,
                              children: List.generate(genres.length, (index) {
                                final String item = genres[index];
                                return _buildGenreFilterChips(
                                  onTap: () {
                                    tempSelectedGenre.value = item;
                                  },
                                  isSelected: tempGenre == item,
                                  displayName: item,
                                );
                              }),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// 적용하기
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(left: 24.w, right: 24.w),
              child: GestureDetector(
                onTap: () async {
                  context.pop();
                  _isLoading.value = true;
                  _cursor = 0;

                  final exhibitVM = context.read<ExhibitViewModel>();
                  final result = await exhibitVM.getExhibitFilters(
                    isDomestic: widget.isDomestic,
                    cursor: _cursor,
                    size: _size,
                    country: widget.country,
                    region: widget.region,
                    genres: tempSelectedGenre.value,
                    sortType: tempSelectedSortType.value.type,
                  );
                  _exhibits.value = result;
                  _selectedGenre.value = tempSelectedGenre.value;
                  _selectedSortType.value = tempSelectedSortType.value;
                  _isLoading.value = false;
                  _hasNext.value = true;

                  if ((result?.isEmpty ?? true) ||
                      (result?.length ?? _size) < _size) {
                    _hasNext.value = false;
                    AppUtil.debugLog(
                      'No more exhibits to load: ${_hasNext.value}',
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: 17.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    color: AppColors.primary300,
                  ),
                  child: ArtTripText.pretendard()
                      .title02Bold()
                      .color(AppColors.textWhite)
                      .build()
                      .text(context.l10n.apply),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 필터 시트에서 쓰이는 칩
  Widget _buildGenreFilterChips({
    Function()? onTap,
    bool isSelected = false,
    required String displayName,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 20.w,
          vertical: 8.h,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary300 : AppColors.gray0,
          borderRadius: BorderRadius.circular(100.r),
          border: isSelected
              ? Border.all(color: Colors.transparent)
              : Border.all(color: AppColors.gray100),
        ),
        child: isSelected
            ? ArtTripText.pretendard()
                  .body01Bold()
                  .color(AppColors.textWhite)
                  .textAlign(TextAlign.center)
                  .build()
                  .text(displayName)
            : ArtTripText.pretendard()
                  .body01Light()
                  .textAlign(TextAlign.center)
                  .build()
                  .text(displayName),
      ),
    );
  }
}
