import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_review_model.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:arttrip/shared/widgets/app_cached_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 리뷰 목록의 개별 아이템 위젯
class ReviewListItem extends StatelessWidget {
  const ReviewListItem({super.key, required this.review});

  final ExhibitReviewModel review;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        SizedBox(height: 12.h),
        _buildContent(),
        if (review.thumbnailUrl?.isNotEmpty ?? false) ...[
          SizedBox(height: 20.h),
          _buildThumbnail(),
        ],
        SizedBox(height: 16.h),
        const Divider(height: 1, color: AppColors.gray50),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: ArtTripText.pretendard()
              .body02Bold()
              .color(const Color(0xFFA5A5AF))
              .build()
              .text(review.nickname ?? '익명'),
        ),
        SizedBox(width: 10.w),
        ArtTripText.pretendard()
            .body02Light()
            .color(const Color(0xFFA5A5AF))
            .build()
            .text(review.visitDate),
      ],
    );
  }

  Widget _buildContent() {
    return ArtTripText.pretendard()
        .body02Regular()
        .color(const Color(0xFF111111))
        .build()
        .text(review.content);
  }

  Widget _buildThumbnail() {
    return AppCachedImage(
      imageUrl: review.thumbnailUrl!,
      width: 100.w,
      height: 100.w,
      borderRadius: BorderRadius.circular(8.r),
    );
  }
}
