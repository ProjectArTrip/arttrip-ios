import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/exhibit/data/models/review_submit_result.dart';
import 'package:arttrip/features/exhibit/viewmodels/write_review_viewmodel.dart';
import 'package:arttrip/shared/utils/snackbar_utils.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:arttrip/shared/widgets/bad_word_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

/// 리뷰 작성/수정 페이지 - 등록/수정 버튼
class SubmitReviewButton extends StatelessWidget {
  const SubmitReviewButton({super.key, this.exhibitId = 0});

  /// 신규 작성 시 필수, 수정 모드에서는 사용하지 않음
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
              child: vm.isSubmitting
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
                        .text(
                          vm.isEditMode
                              ? context.l10n.updateReview
                              : context.l10n.submitReview,
                        ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _onSubmit(BuildContext context, WriteReviewViewModel vm) async {
    final ReviewSubmitResult result = vm.isEditMode
        ? await vm.updateReview()
        : await vm.submitReview(exhibitId);

    if (!context.mounted) return;

    switch (result) {
      case ReviewSubmitResult.success:
        Navigator.of(context).pop(true);
      case ReviewSubmitResult.badWord:
        await BadWordDialog.show(context);
      case ReviewSubmitResult.failure:
        SnackBarUtils.showError(
          context,
          message: vm.isEditMode
              ? context.l10n.reviewUpdateError
              : context.l10n.reviewSubmitError,
        );
    }
  }
}
