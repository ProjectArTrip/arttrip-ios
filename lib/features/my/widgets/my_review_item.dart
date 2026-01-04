import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/my/data/models/my_review_model.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:arttrip/shared/widgets/app_cached_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 나의 리뷰 목록의 개별 아이템 위젯
class MyReviewItem extends StatelessWidget {
  const MyReviewItem({
    super.key,
    required this.review,
    this.onDelete,
    this.onEdit,
  });

  final MyReviewModel review;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        SizedBox(height: 16.h),
        _buildContentBox(),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildInfo(context)),
        SizedBox(width: 12.w),
        _buildThumbnail(),
      ],
    );
  }

  Widget _buildInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ArtTripText.pretendard()
            .body01Bold()
            .color(AppColors.textPrimary)
            .build()
            .text(review.reviewTitle),
        SizedBox(height: 8.h),
        ArtTripText.pretendard()
            .body02Regular()
            .color(AppColors.textTertiary)
            .build()
            .text(context.l10n.visitDateFormat(_formatDate(review.visitDate))),
        SizedBox(height: 8.h),
        _buildActionButtons(context),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        _buildActionButton(label: context.l10n.deleteButton, onTap: onDelete),
        SizedBox(width: 8.w),
        _buildActionButton(label: context.l10n.editButton, onTap: onEdit),
      ],
    );
  }

  Widget _buildActionButton({required String label, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.gray50),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: ArtTripText.pretendard()
            .body02Bold()
            .color(AppColors.textPrimary)
            .build()
            .text(label),
      ),
    );
  }

  Widget _buildThumbnail() {
    if (review.thumbnailUrl == null || review.thumbnailUrl!.isEmpty) {
      return Container(
        width: 72.w,
        height: 72.h,
        decoration: BoxDecoration(
          color: AppColors.gray50,
          borderRadius: BorderRadius.circular(8.r),
        ),
      );
    }

    return AppCachedImage(
      imageUrl: review.thumbnailUrl!,
      width: 72.w,
      height: 72.h,
      borderRadius: BorderRadius.circular(4.r),
    );
  }

  Widget _buildContentBox() {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 100.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.subLightGray,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: ArtTripText.pretendard()
          .body01Regular()
          .color(AppColors.textPrimary)
          .build()
          .text(review.content),
    );
  }

  String _formatDate(String dateString) {
    // "2025-12-05" -> "2025.12.05"
    return dateString.replaceAll('-', '.');
  }
}
