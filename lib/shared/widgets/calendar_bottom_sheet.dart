import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:table_calendar/table_calendar.dart';

/// 공용 달력 바텀시트 위젯
class CalendarBottomSheet extends StatefulWidget {
  const CalendarBottomSheet({
    super.key,
    this.initialDate,
    this.firstDate,
    this.lastDate,
  });

  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;

  @override
  State<CalendarBottomSheet> createState() => _CalendarBottomSheetState();
}

class _CalendarBottomSheetState extends State<CalendarBottomSheet> {
  late DateTime _focusedDay;
  late DateTime _firstDay;
  late DateTime _lastDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    _firstDay = widget.firstDate ?? DateTime(2000);
    _lastDay = widget.lastDate ?? now;

    // 초기 선택 날짜 결정 (initialDate가 없으면 오늘)
    var initialSelection = widget.initialDate ?? now;
    if (initialSelection.isAfter(_lastDay)) {
      initialSelection = _lastDay;
    }
    if (initialSelection.isBefore(_firstDay)) {
      initialSelection = _firstDay;
    }
    _selectedDay = initialSelection;
    _focusedDay = initialSelection;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.subLightGray,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [_buildHeader(), _buildCalendar()],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.only(
        top: 24.h,
        bottom: 16.h,
        left: 16.w,
        right: 16.w,
      ),
      child: Row(
        children: [
          SizedBox(width: 24.w),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildArrowButton(
                  icon: AppAssets.icNoArrowLeft,
                  onTap: _goToPreviousMonth,
                  enabled: _canGoToPreviousMonth,
                ),
                SizedBox(width: 4.w),
                ArtTripText.pretendard()
                    .title01Bold()
                    .color(AppColors.textPrimary)
                    .build()
                    .text(
                      context.l10n.calendarYearMonth(
                        _focusedDay.month,
                        _focusedDay.year,
                      ),
                    ),
                SizedBox(width: 4.w),
                _buildArrowButton(
                  icon: AppAssets.icNoArrowRight,
                  onTap: _goToNextMonth,
                  enabled: _canGoToNextMonth,
                ),
              ],
            ),
          ),
          _buildIconButton(
            icon: AppAssets.icClose,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildArrowButton({
    required String icon,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: SvgPicture.asset(
        icon,
        width: 24.w,
        height: 24.w,
        colorFilter: ColorFilter.mode(
          enabled ? AppColors.textPrimary : AppColors.gray100,
          BlendMode.srcIn,
        ),
      ),
    );
  }

  Widget _buildIconButton({required String icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: SvgPicture.asset(icon, width: 24.w, height: 24.w),
    );
  }

  Widget _buildCalendar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 17.w),
      child: TableCalendar(
        firstDay: _firstDay,
        lastDay: _lastDay,
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        startingDayOfWeek: StartingDayOfWeek.sunday,
        headerVisible: false,
        daysOfWeekHeight: 36.h,
        rowHeight: 44.h,
        onDaySelected: (selectedDay, focusedDay) {
          Navigator.pop(context, selectedDay);
        },
        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
          });
        },
        calendarBuilders: CalendarBuilders(
          dowBuilder: (context, day) {
            final l10n = context.l10n;
            final weekdays = [
              l10n.weekdaySun,
              l10n.weekdayMon,
              l10n.weekdayTue,
              l10n.weekdayWed,
              l10n.weekdayThu,
              l10n.weekdayFri,
              l10n.weekdaySat,
            ];
            final weekdayIndex = day.weekday % 7;

            return Align(
              alignment: Alignment.topCenter,
              child: ArtTripText.pretendard()
                  .body01Regular()
                  .color(AppColors.textSecondary)
                  .build()
                  .text(weekdays[weekdayIndex]),
            );
          },
          defaultBuilder: (context, day, focusedDay) {
            return _buildDayCell(day, isDisabled: false);
          },
          todayBuilder: (context, day, focusedDay) {
            // 오늘 날짜도 일반 스타일 사용 (선택되면 selectedBuilder가 처리)
            return _buildDayCell(day, isDisabled: false);
          },
          selectedBuilder: (context, day, focusedDay) {
            return _buildSelectedDayCell(day);
          },
          disabledBuilder: (context, day, focusedDay) {
            return _buildDayCell(day, isDisabled: true);
          },
          outsideBuilder: (context, day, focusedDay) {
            return const SizedBox.shrink();
          },
        ),
        calendarStyle: const CalendarStyle(outsideDaysVisible: false),
      ),
    );
  }

  Widget _buildDayCell(DateTime day, {required bool isDisabled}) {
    return Center(
      child: ArtTripText.pretendard()
          .body01Bold()
          .color(isDisabled ? AppColors.gray100 : AppColors.textPrimary)
          .build()
          .text('${day.day}'),
    );
  }

  Widget _buildSelectedDayCell(DateTime day) {
    return Center(
      child: Container(
        width: 28.w,
        height: 24.h,
        decoration: BoxDecoration(
          color: AppColors.primary300,
          borderRadius: BorderRadius.circular(100.r),
        ),
        child: Center(
          child: ArtTripText.pretendard()
              .body01Bold()
              .color(AppColors.textWhite)
              .build()
              .text('${day.day}'),
        ),
      ),
    );
  }

  bool get _canGoToPreviousMonth {
    return _focusedDay.year > _firstDay.year ||
        (_focusedDay.year == _firstDay.year &&
            _focusedDay.month > _firstDay.month);
  }

  bool get _canGoToNextMonth {
    return _focusedDay.year < _lastDay.year ||
        (_focusedDay.year == _lastDay.year &&
            _focusedDay.month < _lastDay.month);
  }

  void _goToPreviousMonth() {
    if (!_canGoToPreviousMonth) return;
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
    });
  }

  void _goToNextMonth() {
    if (!_canGoToNextMonth) return;
    var nextMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
    if (nextMonth.isAfter(_lastDay)) {
      nextMonth = _lastDay;
    }
    setState(() {
      _focusedDay = nextMonth;
    });
  }
}

/// 달력 바텀시트를 표시하는 헬퍼 함수
Future<DateTime?> showCalendarBottomSheet({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => CalendarBottomSheet(
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    ),
  );
}
