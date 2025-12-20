import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_detail.dart';
import 'package:arttrip/features/exhibit/widgets/exhibit_info_row.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 전시 상세 정보 탭 콘텐츠
class ExhibitDetailTab extends StatelessWidget {
  const ExhibitDetailTab({super.key, required this.exhibit});

  final ExhibitDetail exhibit;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoBox(context),
          SizedBox(height: 16.h),
          _buildDescriptionBox(context),
        ],
      ),
    );
  }

  Widget _buildInfoBox(BuildContext context) {
    var infoItems = <Widget>[];

    if (exhibit.hallAddress.isNotEmpty) {
      infoItems.add(ExhibitInfoRow(
        iconPath: AppAssets.icLocation2,
        label: context.l10n.exhibitAddress,
        value: exhibit.hallAddress,
      ));
    }

    if (exhibit.hallOpeningHours.isNotEmpty) {
      infoItems.add(ExhibitInfoRow(
        iconPath: AppAssets.icTime,
        label: context.l10n.exhibitOpeningHours,
        value: exhibit.hallOpeningHours,
      ));
    }

    if (exhibit.hallPhone.isNotEmpty) {
      infoItems.add(ExhibitInfoRow(
        iconPath: AppAssets.icPhone,
        label: context.l10n.exhibitPhone,
        value: exhibit.hallPhone,
      ));
    }

    if (infoItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.subLightGray,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: infoItems
            .expand((item) => [item, SizedBox(height: 12.h)])
            .toList()
          ..removeLast(),
      ),
    );
  }

  Widget _buildDescriptionBox(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.subLightGray,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ArtTripText.pretendard()
              .body02Bold()
              .color(AppColors.textPrimary)
              .build()
              .text(context.l10n.exhibitDescription),
          SizedBox(height: 8.h),
          ArtTripText.pretendard()
              .body02Light()
              .color(AppColors.textPrimary)
              .build()
              .text(exhibit.description),
        ],
      ),
    );
  }
}

/// 플레이스홀더 탭 (지도, 리뷰)
class ExhibitPlaceholderTab extends StatelessWidget {
  const ExhibitPlaceholderTab({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ArtTripText.pretendard()
          .body01Regular()
          .color(AppColors.textTertiary)
          .build()
          .text(label),
    );
  }
}
