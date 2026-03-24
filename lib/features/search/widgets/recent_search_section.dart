import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/search/data/models/search_history_model.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 최근 검색어 섹션
class RecentSearchSection extends StatelessWidget {
  const RecentSearchSection({
    super.key,
    required this.recentSearches,
    required this.onTap,
    required this.onDelete,
    required this.onClearAll,
  });

  final List<SearchHistoryModel> recentSearches;
  final Function(String) onTap;
  final Function(int) onDelete;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    if (recentSearches.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ArtTripText.pretendard()
                .title02Bold()
                .color(AppColors.textPrimary)
                .build()
                .text(context.l10n.recentSearches),
            GestureDetector(
              onTap: onClearAll,
              child: ArtTripText.pretendard()
                  .body02Regular()
                  .color(AppColors.textPrimary)
                  .build()
                  .text(context.l10n.clearAll),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: recentSearches.map((item) => _buildChip(item)).toList(),
        ),
      ],
    );
  }

  Widget _buildChip(SearchHistoryModel item) {
    return GestureDetector(
      onTap: () => onTap(item.content),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.gray100),
          borderRadius: BorderRadius.circular(100.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ArtTripText.pretendard()
                .body01Light()
                .color(AppColors.textPrimary)
                .build()
                .text(item.content),
            SizedBox(width: 8.w),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onDelete(item.searchHistoryId),
              child: SvgPicture.asset(AppAssets.icDelete),
            ),
          ],
        ),
      ),
    );
  }
}
