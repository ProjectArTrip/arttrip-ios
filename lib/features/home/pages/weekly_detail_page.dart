import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/app_utils.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_filter_model.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_model.dart';
import 'package:arttrip/features/exhibit/viewmodels/exhibit_viewmodel.dart';
import 'package:arttrip/features/home/home_viewmodel.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:arttrip/shared/widgets/alert_badge.dart';
import 'package:arttrip/shared/widgets/common_appbar.dart';
import 'package:arttrip/shared/widgets/exception_view.dart';
import 'package:arttrip/shared/widgets/exhibit_list_item.dart';
import 'package:arttrip/shared/widgets/exhibits_loading_view.dart';
import 'package:arttrip/shared/widgets/no_exhibits_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class WeeklyDetailPage extends StatefulWidget {
  const WeeklyDetailPage({super.key});

  @override
  State<WeeklyDetailPage> createState() => _WeeklyDetailPageState();
}

class _WeeklyDetailPageState extends State<WeeklyDetailPage> {
  final ScrollController _scrollController = ScrollController();
  late ValueNotifier<DateTime> _selectedDate;
  late ValueNotifier<String> _area;

  final ValueNotifier<List<ExhibitModel>?> _exhibits = ValueNotifier([]);
  final ValueNotifier<bool> _isLoading = ValueNotifier(true); // 전체 로딩 상태
  final ValueNotifier<bool> _hasNext = ValueNotifier(true); // 다음 페이지 존재 여부
  final ValueNotifier<bool> _loadingMore = ValueNotifier(false); // 추가 로딩 상태

  late final bool _isDomestic;
  final double _threshold = 50.0;
  final int _size = 10;
  int _cursor = 0;

  @override
  void initState() {
    super.initState();
    _init();
    Future.delayed(Duration.zero, () => _getWeeklyExhibits());

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
    final homeVM = context.read<HomeViewModel>();

    _isDomestic = homeVM.isDomestic;

    /// 해외/국내 -> 국가/국내별 지역의 선택했던 값
    final DateTime date =
        homeVM.selectedDateInWeek[homeVM.locationType][homeVM.area[homeVM
            .locationType]];
    _selectedDate = ValueNotifier(date);

    _area = ValueNotifier(homeVM.area[homeVM.locationType]!);
  }

  Future<void> _getWeeklyExhibits() async {
    _isLoading.value = true;
    _cursor = 0;

    final exhibitVM = Provider.of<ExhibitViewModel>(context, listen: false);
    final ExhibitFilterModel? result = await exhibitVM.getExhibitFilters(
      isDomestic: _isDomestic,
      endDate: AppUtil.formatDateYMD(_selectedDate.value),
      country: _isDomestic ? null : _area.value,
      region: _isDomestic ? _area.value : null,
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
      isDomestic: _isDomestic,
      endDate: AppUtil.formatDateYMD(_selectedDate.value),
      country: _isDomestic ? null : _area.value,
      region: _isDomestic ? _area.value : null,
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
        title: context.l10n.weeklyExhibitionSchedule,
        actions: const [AlertBadge()],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          children: [
            /// 년,월 필터
            Row(
              children: [
                Padding(
                  padding: EdgeInsetsGeometry.symmetric(vertical: 11.h),
                  child: ArtTripText.pretendard().title02Bold().build().text(
                    AppUtil.formatDateLocaleYM(
                      context,
                      _selectedDate.value,
                    ),
                  ),
                ),
              ],
            ),
            _buildWeeklyCalendar(AppUtil.getCurrentWeek(DateTime.now())),
            SizedBox(height: 8.h),
            ValueListenableBuilder(
              valueListenable: _isLoading,
              builder: (context, isLoading, child) {
                if (isLoading) {
                  return const ExhibitsLoadingView();
                }

                return ValueListenableBuilder(
                  valueListenable: _exhibits,
                  builder: (context, exhibits, child) {
                    if (exhibits == null) {
                      return const ExceptionView();
                    } else if (exhibits.isEmpty) {
                      return const NoExhibitsView();
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
                            padding: EdgeInsets.only(top: 8.h, bottom: 16.h),
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
                              return ExhibitListItem(item: item, isDomestic: _isDomestic);
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
    );
  }

  Widget _buildWeeklyCalendar(List<DateTime> currentWeek) {
    final locale = Localizations.localeOf(context);

    return ValueListenableBuilder(
      valueListenable: _selectedDate,
      builder: (context, selectedDate, child) {
        return SizedBox(
          height: 50.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(currentWeek.length, (index) {
              final date = currentWeek[index];
              final isToday = DateUtils.isSameDay(date, selectedDate);
              final weekDay = AppUtil.weekdayLabel(date: date, locale: locale);

              return GestureDetector(
                onTap: () {
                  _selectedDate.value = date;
                  _cursor = 0;
                  _getWeeklyExhibits();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 1.w,
                    vertical: 1.h,
                  ),
                  color: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 28.w,
                        height: 28.w,
                        alignment: Alignment.center,
                        decoration: isToday
                            ? const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.textPoint,
                              )
                            : null,
                        child: isToday
                            ? ArtTripText.pretendard()
                                  .body01Bold()
                                  .color(AppColors.textWhite)
                                  .build()
                                  .text(date.day.toString())
                            : ArtTripText.pretendard()
                                  .body01Regular()
                                  .textAlign(TextAlign.center)
                                  .build()
                                  .text(date.day.toString()),
                      ),
                      isToday
                          ? ArtTripText.pretendard()
                                .body01Bold()
                                .color(AppColors.textPoint)
                                .textAlign(TextAlign.center)
                                .build()
                                .text(weekDay)
                          : ArtTripText.pretendard()
                                .body01Light()
                                .textAlign(TextAlign.center)
                                .build()
                                .text(weekDay),
                    ],
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
