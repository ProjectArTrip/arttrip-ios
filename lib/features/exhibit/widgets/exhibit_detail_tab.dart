import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_detail_model.dart';
import 'package:arttrip/features/exhibit/widgets/exhibit_info_row.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 전시 상세 정보 탭 콘텐츠
class ExhibitDetailModelTabContent extends StatelessWidget {
  const ExhibitDetailModelTabContent({super.key, required this.exhibit});

  final ExhibitDetailModel exhibit;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    final infoItems = <Widget>[];

    if (exhibit.hallAddress.isNotEmpty) {
      infoItems.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExhibitInfoRow(
              iconPath: AppAssets.icLocation2,
              label: context.l10n.exhibitAddress,
              value: exhibit.hallAddress,
              extraWidget: _buildCopyButton(context, exhibit.hallAddress),
            ),
            SizedBox(height: 4.h),
            Align(
              alignment: Alignment.center,
              child: ArtTripText.pretendard()
                  .body02Regular()
                  .color(AppColors.textSecondary)
                  .build()
                  .text(context.l10n.exhibitAddressNotice),
            ),
          ],
        ),
      );
    }

    infoItems.add(
      ExhibitInfoRow(
        iconPath: AppAssets.icTime,
        label: context.l10n.exhibitOpeningHours,
        value: exhibit.hallOpeningHours ?? context.l10n.noInfo,
        isEmpty: exhibit.hallOpeningHours == null,
      ),
    );

    infoItems.add(
      ExhibitInfoRow(
        iconPath: AppAssets.icPhone,
        label: context.l10n.exhibitPhone,
        value: exhibit.hallPhone ?? context.l10n.noInfo,
        isEmpty: exhibit.hallPhone == null,
      ),
    );

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
        children:
            infoItems.expand((item) => [item, SizedBox(height: 12.h)]).toList()
              ..removeLast(),
      ),
    );
  }

  Widget _buildCopyButton(BuildContext context, String text) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: text));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.copyCompleted),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: ArtTripText.pretendard()
          .body01Regular()
          .color(AppColors.textPoint)
          .build()
          .text(context.l10n.copy),
    );
  }

  Widget _buildDescriptionBox(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: AppColors.subLightGray,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ArtTripText.pretendard()
              .title01Bold()
              .color(AppColors.textPrimary)
              .build()
              .text(context.l10n.exhibitDescription),
          SizedBox(height: 8.h),
          ArtTripText.pretendard()
              .title01Light()
              .color(AppColors.textPrimary)
              .build()
              .text(exhibit.description),
        ],
      ),
    );
  }
}

/// 플레이스홀더 탭 (지도)
class ExhibitPlaceholderTabContent extends StatelessWidget {
  const ExhibitPlaceholderTabContent({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200.h,
      child: Center(
        child: ArtTripText.pretendard()
            .body01Regular()
            .color(AppColors.textTertiary)
            .build()
            .text(label),
      ),
    );
  }
}
