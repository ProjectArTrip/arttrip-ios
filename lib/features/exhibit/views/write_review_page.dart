import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/exhibit/data/models/write_review_params.dart';
import 'package:arttrip/features/exhibit/viewmodels/write_review_viewmodel.dart';
import 'package:arttrip/features/exhibit/widgets/write_review/photo_attach_section.dart';
import 'package:arttrip/features/exhibit/widgets/write_review/review_content_section.dart';
import 'package:arttrip/features/exhibit/widgets/write_review/submit_review_button.dart';
import 'package:arttrip/features/exhibit/widgets/write_review/visit_date_section.dart';
import 'package:arttrip/features/exhibit/widgets/write_review/write_review_header.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:arttrip/shared/widgets/app_confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

/// 리뷰 작성/수정 페이지
class WriteReviewPage extends StatefulWidget {
  const WriteReviewPage({super.key, this.exhibitId = 0, required this.params});

  /// 신규 작성 시 필수, 수정 모드에서는 사용하지 않음
  final int exhibitId;
  final WriteReviewParams params;

  @override
  State<WriteReviewPage> createState() => _WriteReviewPageState();
}

class _WriteReviewPageState extends State<WriteReviewPage> {
  @override
  void initState() {
    super.initState();
    final vm = context.read<WriteReviewViewModel>();
    vm.reset(notify: false);
    if (widget.params.isEditMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        vm.initForEdit(reviewId: widget.params.reviewId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _onPopInvoked,
      child: Scaffold(
        backgroundColor: AppColors.gray0,
        appBar: AppBar(
          backgroundColor: AppColors.gray0,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: ArtTripText.pretendard()
              .headline()
              .color(AppColors.textPrimary)
              .build()
              .text(
                widget.params.isEditMode
                    ? context.l10n.editReviewTitle
                    : context.l10n.writeReviewTitle,
              ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WriteReviewHeader(params: widget.params),
                    const Divider(height: 1, color: AppColors.gray50),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 16.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const VisitDateSection(),
                          SizedBox(height: 12.h),
                          const PhotoAttachSection(),
                          SizedBox(height: 12.h),
                          const ReviewContentSection(),
                        ],
                      ),
                    ),
                    SubmitReviewButton(exhibitId: widget.exhibitId),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onPopInvoked(bool didPop, Object? result) async {
    if (didPop) return;

    final shouldQuit = await AppConfirmDialog.show(
      context: context,
      title: context.l10n.writeQuitTitle,
      content: ArtTripText.pretendard()
          .body01Regular()
          .color(AppColors.textSecondary)
          .textAlign(TextAlign.center)
          .build()
          .text(context.l10n.writeQuitContent),
      cancelText: context.l10n.cancel,
      confirmText: context.l10n.confirm,
    );

    if (shouldQuit == true && mounted) {
      Navigator.of(context).pop();
    }
  }
}
