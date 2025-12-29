import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/exhibit/viewmodels/write_review_viewmodel.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

/// 리뷰 작성 페이지 - 등록하기 버튼
class SubmitReviewButton extends StatelessWidget {
  const SubmitReviewButton({super.key, required this.exhibitId});

  final int exhibitId;

  @override
  Widget build(BuildContext context) {
    return Consumer<WriteReviewViewModel>(
      builder: (context, vm, _) {
        return Padding(
          padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h),
          child: SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: vm.canSubmit ? () => _onSubmit(context, vm) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary300,
                foregroundColor: AppColors.textWhite,
                disabledBackgroundColor: AppColors.gray100,
                disabledForegroundColor: AppColors.textTertiary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child:
                  vm.isSubmitting
                      ? SizedBox(
                        width: 24.w,
                        height: 24.h,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : ArtTripText.pretendard()
                          .body01Bold()
                          .color(
                            vm.canSubmit
                                ? AppColors.textWhite
                                : AppColors.textTertiary,
                          )
                          .build()
                          .text(context.l10n.submitReview),
            ),
          ),
        );
      },
    );
  }

  Future<void> _onSubmit(BuildContext context, WriteReviewViewModel vm) async {
    var success = await vm.submitReview(exhibitId);

    if (!context.mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.reviewSubmitError),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
