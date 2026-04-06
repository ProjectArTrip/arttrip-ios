import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/app_utils.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/home/widgets/vertical_range_calendar.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class DateFilterBottomSheet extends StatefulWidget {
  const DateFilterBottomSheet(this.overseasCountries, {super.key});

  final List<String> overseasCountries;

  @override
  State<DateFilterBottomSheet> createState() => _DateFilterBottomSheetState();
}

class _DateFilterBottomSheetState extends State<DateFilterBottomSheet> {
  final ValueNotifier<bool> _isApplyEnabled = ValueNotifier(false);
  final ValueNotifier<bool?> _isCountryCardOpen = ValueNotifier(null);
  final ValueNotifier<String> _selectedCountry = ValueNotifier('');
  final ValueNotifier<DateTime?> _rangeStart = ValueNotifier(null);
  final ValueNotifier<DateTime?> _rangeEnd = ValueNotifier(null);

  void updateApplyEnabled() {
    _isApplyEnabled.value =
        _selectedCountry.value.isNotEmpty &&
        _rangeStart.value != null &&
        _rangeEnd.value != null;
  }

  void updateRanges(DateTime? rangeStart, DateTime? rangeEnd) {
    _rangeStart.value = rangeStart;
    _rangeEnd.value = rangeEnd;
    updateApplyEnabled();
  }

  String formatSelectedStartDate(DateTime? date) {
    if (date == null) return '';
    final language = AppUtil.getLanguage(context);
    final monthDay = DateFormat('M.dd', language).format(date);
    final weekday = DateFormat('E', language).format(date);

    return '$monthDay ($weekday)';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height - 108.h,
      child: ValueListenableBuilder(
        valueListenable: _isCountryCardOpen,
        builder: (context, isCountryCardOpen, child) {
          return Column(
            children: [
              Container(
                width: 32.w,
                height: 4.h,
                margin: EdgeInsets.only(top: 10.h),
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              SizedBox(height: 16.h),
              ArtTripText.pretendard().title02Bold().build().text(
                context.l10n.selectCountryAndDate,
              ),
              SizedBox(height: 24.h),

              /// 국가
              ValueListenableBuilder(
                valueListenable: _selectedCountry,
                builder: (context, selectedCountry, child) {
                  return GestureDetector(
                    onTap: () {
                      _isCountryCardOpen.value = true;
                    },
                    child: _buildCard(
                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 16.h,
                              horizontal: 20.w,
                            ),
                            child: Row(
                              spacing: 12.w,
                              children: [
                                SvgPicture.asset(
                                  AppAssets.icTablerWorld,
                                  width: 20.w,
                                  height: 20.w,
                                ),
                                ArtTripText.pretendard()
                                    .font(14)
                                    .fontWeight(FontWeight.bold)
                                    .build()
                                    .text(context.l10n.country),
                                if (selectedCountry.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(left: 4.w),
                                    child: ArtTripText.pretendard()
                                        .body01Bold()
                                        .color(AppColors.textPoint)
                                        .build()
                                        .text(selectedCountry),
                                  ),
                              ],
                            ),
                          ),
                          if (isCountryCardOpen == true) _buildCountryCard(),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 12.h),

              /// 날짜
              ValueListenableBuilder(
                valueListenable: _rangeEnd,
                builder: (context, rangeEnd, child) {
                  return ValueListenableBuilder(
                    valueListenable: _rangeStart,
                    builder: (context, rangeStart, child) {
                      return GestureDetector(
                        onTap: () {
                          _isCountryCardOpen.value = false;
                        },
                        child: _buildCard(
                          Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 16.h,
                                  horizontal: 20.w,
                                ),
                                child: Row(
                                  spacing: 12.w,
                                  children: [
                                    SvgPicture.asset(
                                      AppAssets.icCalendar,
                                      width: 20.w,
                                      height: 20.w,
                                    ),
                                    ArtTripText.pretendard()
                                        .font(14)
                                        .fontWeight(FontWeight.bold)
                                        .build()
                                        .text(context.l10n.date),
                                    if (rangeStart != null || rangeEnd != null)
                                      ArtTripText.pretendard()
                                          .body01Bold()
                                          .color(AppColors.textPoint)
                                          .build()
                                          .text(
                                            '${formatSelectedStartDate(rangeStart)} - ${formatSelectedStartDate(rangeEnd)}',
                                          ),
                                  ],
                                ),
                              ),
                              if (isCountryCardOpen == false)
                                _buildCalendarCard(),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const Expanded(child: SizedBox.shrink()),
              ValueListenableBuilder(
                valueListenable: _isApplyEnabled,
                builder: (context, isApplyEnabled, child) {
                  return Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(
                      left: 24.w,
                      right: 24.w,
                      bottom: 44.h,
                    ),
                    child: ElevatedButton(
                      onPressed: isApplyEnabled ? () {} : null,
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
                      child: ArtTripText.pretendard()
                          .title02Bold()
                          .color(
                            isApplyEnabled
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
          );
        },
      ),
    );
  }

  Container _buildCard(Widget child) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      decoration: BoxDecoration(
        color: AppColors.gray0,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 2),
            blurRadius: 4,
            color: AppColors.gray900.withValues(alpha: 0.04),
          ),
        ],
      ),
      child: child,
    );
  }

  Column _buildCountryCard() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 1.w,
          margin: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: const BoxDecoration(color: AppColors.gray50),
        ),
        ValueListenableBuilder(
          valueListenable: _selectedCountry,
          builder: (context, selectedCountry, child) {
            return Padding(
              padding: EdgeInsets.all(16.w),
              child: Wrap(
                spacing: 12.w,
                runSpacing: 12.h,
                children: List.generate(widget.overseasCountries.length, (
                  index,
                ) {
                  final item = widget.overseasCountries[index];
                  final isSelected = selectedCountry == item;
                  return GestureDetector(
                    onTap: () {
                      _selectedCountry.value = item;
                      updateApplyEnabled();
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
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: isSelected
                          ? ArtTripText.pretendard()
                                .body01Bold()
                                .color(AppColors.textWhite)
                                .build()
                                .text(item)
                          : ArtTripText.pretendard().body01Light().build().text(
                              item,
                            ),
                    ),
                  );
                }),
              ),
            );
          },
        ),
      ],
    );
  }

  SizedBox _buildCalendarCard() {
    final weekdays = AppUtil.getLocalizedWeekdays(
      Localizations.localeOf(context),
    );
    return SizedBox(
      height: 442.h - 52.h,
      child: Column(
        children: [
          /// weekdays
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(weekdays.length, (index) {
                final item = weekdays[index];
                return Padding(
                  padding: EdgeInsets.only(top: 4.h, bottom: 8.h),
                  child: ArtTripText.pretendard()
                      .body01Regular()
                      .color(AppColors.textTertiary)
                      .build()
                      .text(item),
                );
              }),
            ),
          ),
          Divider(color: AppColors.gray100, height: 1.h),

          /// calendar
          VerticalRangeCalendar(
            rangeStart: _rangeStart.value,
            rangeEnd: _rangeEnd.value,
            updateRanges: updateRanges,
          ),
        ],
      ),
    );
  }
}
