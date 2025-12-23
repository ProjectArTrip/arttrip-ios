import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/exhibit/viewmodel/write_review_viewmodel.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

/// 리뷰 작성 페이지 - 리뷰 작성 섹션
class ReviewContentSection extends StatelessWidget {
  const ReviewContentSection({super.key});

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
                .text(context.l10n.reviewContentLabel),
            SizedBox(height: 8.h),
            Container(
              height: 256,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.gray100),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Stack(
                children: [
                  TextField(
                    maxLines: 9,
                    maxLength: WriteReviewViewModel.maxContentLength,
                    decoration: InputDecoration(
                      hintText: context.l10n.reviewContentPlaceholder,
                      hintStyle:
                          ArtTripText.pretendard()
                              .body01Regular()
                              .color(AppColors.textTertiary)
                              .build()
                              .style(),
                      contentPadding: EdgeInsets.fromLTRB(
                        16.w,
                        16.w,
                        16.w,
                        36.h,
                      ),
                      border: InputBorder.none,
                      counterText: '',
                    ),
                    style:
                        ArtTripText.pretendard()
                            .body01Regular()
                            .color(AppColors.textPrimary)
                            .build()
                            .style(),
                    onChanged: vm.setContent,
                  ),
                  Positioned(
                    bottom: 12.h,
                    right: 16.w,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ArtTripText.pretendard()
                            .body02Bold()
                            .color(AppColors.textSecondary)
                            .build()
                            .text('${vm.contentLength}'),
                        ArtTripText.pretendard()
                            .body02Regular()
                            .color(AppColors.textTertiary)
                            .build()
                            .text('/${WriteReviewViewModel.maxContentLength}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
