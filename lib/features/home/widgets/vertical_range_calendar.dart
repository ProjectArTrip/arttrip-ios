import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:arttrip/shared/widgets/init_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VerticalRangeCalendar extends StatefulWidget {
  const VerticalRangeCalendar({
    super.key,
    required this.rangeStart,
    required this.rangeEnd,
    required this.updateRanges,
  });

  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final Function(DateTime? rangeStart, DateTime? rangeEnd) updateRanges;

  @override
  State<VerticalRangeCalendar> createState() => _VerticalRangeCalendarState();
}

class _VerticalRangeCalendarState extends State<VerticalRangeCalendar> {
  late PageController _pageController;
  final ValueNotifier<DateTime> _focusedDay = ValueNotifier(DateTime.now());
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  final DateTime _today = DateTime.now();
  final DateTime _startMonth = DateTime(2020, 1);
  final DateTime _endMonth = DateTime(2050, 12);
  late int _totalMonths;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.8,
      initialPage: _initialPageFromToday(),
    );
    _rangeStart = widget.rangeStart ?? _today;
    _rangeEnd = widget.rangeEnd;

    _totalMonths =
        (_endMonth.year - _startMonth.year) * 12 +
        (_endMonth.month - _startMonth.month) +
        1;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int _initialPageFromToday() {
    return (_today.year - _startMonth.year) * 12 +
        (_today.month - _startMonth.month);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isWithinRange(DateTime day) {
    if (_rangeStart == null || _rangeEnd == null) return false;
    return day.isAfter(_rangeStart!) && day.isBefore(_rangeEnd!);
  }

  DateTime _dateFromIndex(int index) {
    return DateTime(_startMonth.year, _startMonth.month + index, 1);
  }

  List<DateTime?> _daysInMonth(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    final lastDay = DateTime(date.year, date.month + 1, 0);

    final leadingEmptyCount = firstDay.weekday % 7;

    return [
      // 1일 전 빈칸
      ...List.generate(leadingEmptyCount, (_) => null),

      // 실제 날짜
      ...List.generate(
        lastDay.day,
        (i) => DateTime(date.year, date.month, i + 1),
      ),
    ];
  }

  bool _isToday(DateTime day) {
    return day.year == _today.year &&
        day.month == _today.month &&
        day.day == _today.day;
  }

  bool _isTodaySelected() {
    final start = _rangeStart;
    final end = _rangeEnd;

    if (start != null && _isToday(start)) return true;
    if (end != null && _isToday(end)) return true;

    return false;
  }

  void _onDayTap(DateTime day) {
    if (_rangeStart == null || _rangeEnd != null) {
      _rangeStart = day;
      _rangeEnd = null;
    } else {
      if (day.isBefore(_rangeStart!)) {
        _rangeEnd = _rangeStart;
        _rangeStart = day;
      } else {
        _rangeEnd = day;
      }
    }
    _focusedDay.value = day;
  }

  bool _isSpecialCalendar(int year, int month) {
    // 해당 달 1일
    final firstDay = DateTime(year, month, 1);
    // 해당 달 마지막 날
    final lastDay = DateTime(year, month + 1, 0).day;

    if (firstDay.weekday == DateTime.friday && lastDay == 31) {
      return true;
    } else if (firstDay.weekday == DateTime.saturday &&
        (lastDay == 30 || lastDay == 31)) {
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return InitWidget(
      init: () => widget.updateRanges(_rangeStart, _rangeEnd),
      child: Expanded(
        child: PageView.builder(
          controller: _pageController,
          padEnds: false,
          scrollDirection: Axis.vertical,
          itemCount: _totalMonths,
          itemBuilder: (context, index) {
            final date = _dateFromIndex(index);
            final days = _daysInMonth(date);

            return ValueListenableBuilder(
              valueListenable: _focusedDay,
              builder: (_, _, _) {
                return Column(
                  children: [
                    // header
                    Padding(
                      padding: EdgeInsets.only(top: 16.h),
                      child: ArtTripText.pretendard()
                          .title02Bold()
                          .build()
                          .text('${date.year}. ${date.month}'),
                    ),

                    GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(0),
                      shrinkWrap: true,
                      crossAxisCount: 7,
                      mainAxisSpacing: 10.h,
                      childAspectRatio:
                          (28 + 16).w /
                          (24 +
                                  12 +
                                  (_isSpecialCalendar(date.year, date.month)
                                      ? -4.5
                                      : 0))
                              .h,
                      children:
                          days.map((day) {
                            if (day == null) {
                              return const SizedBox.shrink();
                            }
                            final isStart =
                                _rangeStart != null &&
                                _isSameDay(day, _rangeStart!);
                            final isEnd =
                                _rangeEnd != null &&
                                _isSameDay(day, _rangeEnd!);
                            final isMiddle = _isWithinRange(day);
                            final isRangeSelected =
                                _rangeStart != null && _rangeEnd != null;
                            final isPastDate = day.isBefore(
                              DateTime(_today.year, _today.month, _today.day),
                            );

                            Widget? child;

                            /// 선택 날짜 사이
                            if (isMiddle) {
                              child = Container(
                                height: 28.w,
                                margin: EdgeInsets.symmetric(vertical: 6.h),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary100,
                                ),
                                alignment: Alignment.center,
                                child: ArtTripText.pretendard()
                                    .body01Bold()
                                    .build()
                                    .text('${day.day}'),
                              );
                            } else if (isStart || isEnd) {
                              /// 선택 날짜 시작과 끝
                              child = Stack(
                                children: [
                                  if (isRangeSelected &&
                                      (_rangeStart != _rangeEnd))
                                    Positioned(
                                      top: 0,
                                      bottom: 0,
                                      left: isRangeSelected && isEnd ? 0 : null,
                                      right:
                                          isRangeSelected && isStart ? 0 : null,
                                      child: Container(
                                        width: (28 + 16).w / 2,
                                        height: 28.w,
                                        margin: EdgeInsets.symmetric(
                                          vertical: 6.h,
                                        ),
                                        alignment: Alignment.center,
                                        color: AppColors.primary100,
                                      ),
                                    ),
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      width: 28.w,
                                      height: 28.w,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary300,
                                        shape: BoxShape.circle,
                                      ),
                                      margin: EdgeInsets.symmetric(
                                        vertical: 4.h,
                                      ),
                                      alignment: Alignment.center,
                                      child: ArtTripText.pretendard()
                                          .body01Bold()
                                          .color(AppColors.textWhite)
                                          .build()
                                          .text('${day.day}'),
                                    ),
                                  ),
                                ],
                              );
                            } else if (_isToday(day) && !_isTodaySelected()) {
                              child = Container(
                                width: 28.w,
                                height: 28.w,
                                decoration: BoxDecoration(
                                  color: AppColors.subLightGray,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.gray100),
                                ),
                                alignment: Alignment.center,
                                child: ArtTripText.pretendard()
                                    .body01Bold()
                                    .color(AppColors.textSecondary)
                                    .build()
                                    .text('${day.day}'),
                              );
                            }
                            return GestureDetector(
                              onTap:
                                  isPastDate
                                      ? null
                                      : () {
                                        _onDayTap(day);
                                        widget.updateRanges(
                                          _rangeStart,
                                          _rangeEnd,
                                        );
                                      },
                              child: Container(
                                alignment: Alignment.center,
                                color: Colors.transparent,
                                child:
                                    child ??
                                    ArtTripText.pretendard()
                                        .body01Bold()
                                        .color(
                                          isPastDate
                                              ? AppColors.textTertiary
                                              : AppColors.textPrimary,
                                        )
                                        .build()
                                        .text('${day.day}'),
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
