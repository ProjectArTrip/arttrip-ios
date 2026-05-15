import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/features/exhibit/data/models/write_review_params.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:arttrip/shared/widgets/app_cached_image.dart';
import 'package:arttrip/shared/widgets/image_empty_small_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 리뷰 작성 페이지 - 전시 헤더 (포스터 + 제목 + 미술관명)
class WriteReviewHeader extends StatelessWidget {
  const WriteReviewHeader({super.key, required this.params});

  final WriteReviewParams params;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      child: Row(
        children: [
          params.posterUrl != null
              ? AppCachedImage(
                  imageUrl: params.posterUrl!,
                  width: 50.w,
                  height: 50.w,
                  borderRadius: BorderRadius.circular(4.r),
                  errorWidget: (_, _, _) => const ImageEmptySmallWidget(),
                )
              : Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    color: AppColors.gray100,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: const ImageEmptySmallWidget(),
                ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ArtTripText.pretendard()
                    .title02Bold()
                    .color(AppColors.textPrimary)
                    .build()
                    .text(params.title),
                SizedBox(height: 4.h),
                ArtTripText.pretendard()
                    .body02Regular()
                    .color(AppColors.textSecondary)
                    .build()
                    .text(params.hallName),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
