import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/enum.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/exhibit/viewmodels/exhibit_viewmodel.dart';
import 'package:arttrip/features/home/home_viewmodel.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:arttrip/shared/widgets/alert_badge.dart';
import 'package:arttrip/shared/widgets/common_appbar.dart';
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
  int size = 10;
  int cursor = 0;
  final ValueNotifier<SortType> _selectedSortType = ValueNotifier(
    SortType.latest,
  );
  late ValueNotifier<String> _selectedGenre;

  @override
  void initState() {
    super.initState();
    _selectedGenre = ValueNotifier(widget.genreName);
    final exhibitVM = context.read<ExhibitViewModel>();
    Future.delayed(Duration.zero, () {
      exhibitVM.getExhibitFilters(
        isDomestic: widget.isDomestic,
        cursor: cursor,
        size: size,
        country: widget.country,
        region: widget.region,
        genres: widget.genreName,
        sortType: SortType.latest.type,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: context.l10n.genreDetailExhibition(widget.genreName),
        actions: const [AlertBadge()],
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 24.h),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 11.h),
                child: ArtTripText.pretendard().title02Bold().build().text(
                  context.l10n.totalCount(size),
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

          // Builder(
          //   builder: (context) {
          //     return ListView.separated(
          //       physics: const NeverScrollableScrollPhysics(),
          //       shrinkWrap: true,
          //       size: size,
          //       separatorBuilder: (context, index) => SizedBox(height: 12.h),
          //       itemBuilder: (context, index) {
          //         return ExhibitListItem(item: ,);
          //       },
          //     );
          //   }
          // ),
        ],
      ),
    );
  }

  /// 필터 시트
  Future<void> _buildFilterSheet() {
    _selectedSortType.value = SortType.latest;
    _selectedGenre.value = widget.genreName;

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
                      valueListenable: _selectedSortType,
                      builder: (context, selectedSortType, child) {
                        return Wrap(
                          spacing: 12.w,
                          children: List.generate(3, (index) {
                            late String sortTypeName;
                            switch (index) {
                              case 0:
                                sortTypeName = context.l10n.sortByLatest;
                                break;
                              case 1:
                                sortTypeName = context.l10n.sortByDeadline;
                                break;
                              case 2:
                                sortTypeName = context.l10n.sortByPopular;
                                break;
                            }

                            final isSelected =
                                _selectedSortType.value ==
                                SortType.values[index];
                            return _buildGenreFilterChips(
                              onTap: () {
                                _selectedSortType.value =
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
                          valueListenable: _selectedGenre,
                          builder: (context, selectedGenre, child) {
                            return Wrap(
                              spacing: 12.w,
                              runSpacing: 12.h,
                              children: List.generate(genres.length, (index) {
                                final String item = genres[index];
                                return _buildGenreFilterChips(
                                  onTap: () {
                                    _selectedGenre.value = item;
                                  },
                                  isSelected: selectedGenre == item,
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
                onTap: () {
                  context.pop();
                  final exhibitVM = context.read<ExhibitViewModel>();
                  size = 10;
                  cursor = 0;
                  exhibitVM.getExhibitFilters(
                    isDomestic: widget.isDomestic,
                    cursor: cursor,
                    size: size,
                    country: widget.country,
                    region: widget.region,
                    genres: _selectedGenre.value,
                    sortType: _selectedSortType.value.type,
                  );
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
