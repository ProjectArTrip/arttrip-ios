import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/app_utils.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_filter_model.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_model.dart';
import 'package:arttrip/features/exhibit/viewmodels/exhibit_viewmodel.dart';
import 'package:arttrip/features/home/home_viewmodel.dart';
import 'package:arttrip/features/home/widgets/date_filter_bottom_sheet.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:arttrip/shared/widgets/alert_badge.dart';
import 'package:arttrip/shared/widgets/async_view.dart';
import 'package:arttrip/shared/widgets/common_appbar.dart';
import 'package:arttrip/shared/widgets/exception_view.dart';
import 'package:arttrip/shared/widgets/exhibit_list_item.dart';
import 'package:arttrip/shared/widgets/exhibits_loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class CalendarResultPage extends StatefulWidget {
  const CalendarResultPage({
    super.key,
    required this.country,
    required this.rangeStart,
    required this.rangeEnd,
  });

  final String country;
  final DateTime rangeStart;
  final DateTime rangeEnd;

  @override
  State<CalendarResultPage> createState() => _CalendarResultPageState();
}

class _CalendarResultPageState extends State<CalendarResultPage> {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<List<ExhibitModel>?> _exhibits = ValueNotifier([]);
  late ValueNotifier<String> _selectedCountry;
  late ValueNotifier<DateTime> _rangeStart;
  late ValueNotifier<DateTime> _rangeEnd;

  final ValueNotifier<bool> _isLoading = ValueNotifier(true); // 전체 로딩 상태
  final ValueNotifier<bool> _hasNext = ValueNotifier(true); // 다음 페이지 존재 여부
  final ValueNotifier<bool> _loadingMore = ValueNotifier(false); // 추가 로딩 상태

  final double _threshold = 50.0;
  final int _size = 10;
  int _cursor = 0;

  @override
  void initState() {
    super.initState();
    _init();
    Future.delayed(Duration.zero, () => _getFilterExhibits());

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
    _scrollController.dispose();
    super.dispose();
  }

  void _init() {
    _selectedCountry = ValueNotifier(widget.country);
    _rangeStart = ValueNotifier(widget.rangeStart);
    _rangeEnd = ValueNotifier(widget.rangeEnd);
  }

  Future<void> _getFilterExhibits() async {
    _isLoading.value = true;

    final exhibitVM = Provider.of<ExhibitViewModel>(context, listen: false);
    final ExhibitFilterModel? result = await exhibitVM.getExhibitFilters(
      isDomestic: false,
      startDate: AppUtil.formatDateYMD(_rangeStart.value),
      endDate: AppUtil.formatDateYMD(_rangeEnd.value),
      country: _selectedCountry.value,
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
      isDomestic: false,
      startDate: AppUtil.formatDateYMD(_rangeStart.value),
      endDate: AppUtil.formatDateYMD(_rangeEnd.value),
      country: _selectedCountry.value,
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
      appBar: CommonAppBar(
        actions: [
          const AlertBadge(),
          SizedBox(width: 20.w),
          GestureDetector(
            onTap: () async {
              _showDateFilterBottomSheet();
            },
            child: SvgPicture.asset(
              AppAssets.icCalendar,
              width: 24.w,
              height: 24.w,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
            child: Row(
              spacing: 12.w,
              children: [
                ValueListenableBuilder(
                  valueListenable: _selectedCountry,
                  builder: (context, selectedCountry, child) {
                    return ArtTripText.pretendard().title02Bold().build().text(
                      selectedCountry,
                    );
                  },
                ),
                ValueListenableBuilder(
                  valueListenable: _rangeStart,
                  builder: (context, rangeStart, child) {
                    return ValueListenableBuilder(
                      valueListenable: _rangeEnd,
                      builder: (context, rangeEnd, child) {
                        return ArtTripText.pretendard()
                            .body01Regular()
                            .color(AppColors.textSecondary)
                            .build()
                            .text(
                              AppUtil.getRangeDateString(
                                context: context,
                                start: rangeStart,
                                end: rangeEnd,
                              ),
                            );
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          /// 전시 리스트
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _isLoading,
              builder: (context, isLoading, child) {
                if (isLoading) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 12.h,
                      horizontal: 24.w,
                    ),
                    child: const ExhibitsLoadingView(),
                  );
                }

                return ValueListenableBuilder(
                  valueListenable: _exhibits,
                  builder: (context, exhibits, _) {
                    if (exhibits == null) {
                      return const ExceptionView();
                    } else if (exhibits.isEmpty) {
                      return Center(
                        child: ArtTripText.pretendard()
                            .body01Regular()
                            .color(AppColors.textSecondary)
                            .build()
                            .text(context.l10n.noSearchResults),
                      );
                    }
                    return ValueListenableBuilder(
                      valueListenable: _loadingMore,
                      builder: (context, loadingMore, child) {
                        final int length =
                            exhibits.length + (loadingMore ? 1 : 0);
                        return ListView.separated(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.h,
                            vertical: 12.h,
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
                            return ExhibitListItem(item: item);
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDateFilterBottomSheet() {
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
      builder: (_) => Selector<HomeViewModel, AsyncState<List<String>>>(
        selector: (_, vm) => vm.overseasCountries,
        builder: (context, overseasCountries, _) {
          return AsyncView(
            state: overseasCountries,
            onData: (data) {
              return DateFilterBottomSheet(
                data,
                country: _selectedCountry.value,
                rangeStart: _rangeStart.value,
                rangeEnd: _rangeEnd.value,
              );
            },
          );
        },
      ),
    ).then((value) {
      if (value != null) {
        _selectedCountry.value = value['country'];
        _rangeStart.value = value['rangeStart'];
        _rangeEnd.value = value['rangeEnd'];
        _getFilterExhibits();
      }
    });
  }
}
