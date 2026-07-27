import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/onboarding/data/models/keyword_model.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 추천 검색어 섹션
class RecommendedSearchSection extends StatelessWidget {
  const RecommendedSearchSection({
    super.key,
    required this.keywords,
    required this.onTap,
  });

  final List<KeywordModel> keywords;
  final Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    if (keywords.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ArtTripText.pretendard()
            .title02Bold()
            .color(AppColors.textPrimary)
            .build()
            .text(context.l10n.recommendedSearches),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: keywords.map((keyword) => _buildChip(keyword)).toList(),
        ),
      ],
    );
  }

  Widget _buildChip(KeywordModel keyword) {
    return GestureDetector(
      onTap: () => onTap(keyword.name),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 19.w, vertical: 11.h),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.gray100),
          borderRadius: BorderRadius.circular(100.r),
        ),
        child: ArtTripText.pretendard()
            .body01Bold()
            .color(AppColors.textPoint)
            .build()
            .text(keyword.name),
      ),
    );
  }
}
