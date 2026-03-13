import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/features/my/data/models/recent_exhibit_model.dart';
import 'package:arttrip/routes/routes.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:arttrip/shared/widgets/app_cached_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 최근 본 전시 목록의 개별 아이템 위젯
class RecentExhibitItem extends StatelessWidget {
  const RecentExhibitItem({super.key, required this.exhibit});

  final RecentExhibitModel exhibit;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Routes.push(context, '/exhibit/${exhibit.exhibitId}'),
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          _buildThumbnail(),
          SizedBox(width: 16.w),
          Expanded(child: _buildInfo()),
        ],
      ),
    );
  }

  Widget _buildThumbnail() {
    if (exhibit.exhibitImage == null || exhibit.exhibitImage!.isEmpty) {
      return Container(
        width: 100.w,
        height: 100.w,
        decoration: BoxDecoration(
          color: AppColors.gray50,
          borderRadius: BorderRadius.circular(8.r),
        ),
      );
    }

    return AppCachedImage(
      imageUrl: exhibit.exhibitImage!,
      width: 100.w,
      height: 100.w,
      borderRadius: BorderRadius.circular(8.r),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ArtTripText.pretendard()
            .title02Bold()
            .ellipsis(3)
            .color(AppColors.textPrimary)
            .build()
            .text(exhibit.title),
        if (exhibit.exhibitHallName != null &&
            exhibit.exhibitHallName!.isNotEmpty) ...[
          SizedBox(height: 4.h),
          ArtTripText.pretendard()
              .body02Regular()
              .ellipsis(1)
              .color(AppColors.textTertiary)
              .build()
              .text(exhibit.exhibitHallName!),
        ],
      ],
    );
  }
}
