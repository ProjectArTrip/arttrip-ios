import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 전시 상세 페이지의 헤더 섹션 (제목, 장소, 기간, 버튼)
class ExhibitHeaderSection extends StatelessWidget {
  const ExhibitHeaderSection({
    super.key,
    required this.title,
    required this.hallName,
    required this.exhibitPeriod,
    required this.ticketUrl,
  });

  final String title;
  final String hallName;
  final String exhibitPeriod;
  final String ticketUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(),
        SizedBox(height: 16.h),
        _buildSubInfo(hallName),
        SizedBox(height: 4.h),
        _buildSubInfo(exhibitPeriod),
        SizedBox(height: 16.h),
        _buildTicketButton(context),
      ],
    );
  }

  Widget _buildTitle() {
    return ArtTripText.pretendard()
        .title01Bold()
        .color(AppColors.textPrimary)
        .build()
        .text(title);
  }

  Widget _buildSubInfo(String text) {
    return ArtTripText.pretendard()
        .body02Regular()
        .color(AppColors.textPrimary)
        .build()
        .text(text);
  }

  Widget _buildTicketButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: () {
          // TODO: url_launcher 패키지 추가 후 구현
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary300,
          foregroundColor: AppColors.textWhite,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        child: ArtTripText.pretendard()
            .body01Bold()
            .color(AppColors.textWhite)
            .build()
            .text(context.l10n.goToHomepage),
      ),
    );
  }
}
