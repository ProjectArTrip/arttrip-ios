import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/exhibit/viewmodel/write_review_viewmodel.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:arttrip/shared/widgets/calendar_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// 리뷰 작성 페이지 - 방문일 선택 섹션
class VisitDateSection extends StatelessWidget {
  const VisitDateSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WriteReviewViewModel>(
      builder: (context, vm, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ArtTripText.pretendard()
                .body01Regular()
                .color(AppColors.textPrimary)
                .build()
                .text(context.l10n.visitDateLabel),
            SizedBox(height: 8.h),
            InkWell(
              onTap: () => _showDatePicker(context, vm),
              borderRadius: BorderRadius.circular(8.r),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.gray100),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ArtTripText.pretendard()
                        .body01Regular()
                        .color(
                          vm.visitDate != null
                              ? AppColors.textPrimary
                              : AppColors.textTertiary,
                        )
                        .build()
                        .text(
                          vm.visitDate != null
                              ? DateFormat('yyyy.MM.dd').format(vm.visitDate!)
                              : context.l10n.visitDatePlaceholder,
                        ),
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 20.w,
                      color: AppColors.textPrimary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDatePicker(
    BuildContext context,
    WriteReviewViewModel vm,
  ) async {
    var picked = await showCalendarBottomSheet(
      context: context,
      initialDate: vm.visitDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      vm.setVisitDate(picked);
    }
  }
}
