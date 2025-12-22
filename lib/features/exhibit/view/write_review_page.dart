import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/exhibit/data/models/write_review_params.dart';
import 'package:arttrip/features/exhibit/viewmodel/write_review_viewmodel.dart';
import 'package:arttrip/features/exhibit/widgets/write_review/photo_attach_section.dart';
import 'package:arttrip/features/exhibit/widgets/write_review/review_content_section.dart';
import 'package:arttrip/features/exhibit/widgets/write_review/submit_review_button.dart';
import 'package:arttrip/features/exhibit/widgets/write_review/visit_date_section.dart';
import 'package:arttrip/features/exhibit/widgets/write_review/write_review_header.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:arttrip/shared/widgets/init_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

/// 리뷰 작성 페이지
class WriteReviewPage extends StatelessWidget {
  const WriteReviewPage({
    super.key,
    required this.exhibitId,
    required this.params,
  });

  final int exhibitId;
  final WriteReviewParams params;

  @override
  Widget build(BuildContext context) {
    return InitWidget(
      init: () {
        context.read<WriteReviewViewModel>().reset();
      },
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
              .text(context.l10n.writeReviewTitle),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WriteReviewHeader(params: params),
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
                    SubmitReviewButton(exhibitId: exhibitId),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
