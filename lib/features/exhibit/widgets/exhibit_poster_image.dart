import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/shared/widgets/app_cached_image.dart';
import 'package:arttrip/shared/widgets/exhibit_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 전시 포스터 이미지 위젯
class ExhibitPosterImage extends StatelessWidget {
  const ExhibitPosterImage({super.key, this.posterUrl, this.status});

  final String? posterUrl;
  final String? status;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        posterUrl != null
            ? AppCachedImage(
              imageUrl: posterUrl!,
              width: double.infinity,
              height: 276.h,
              fit: BoxFit.cover,
            )
            : Container(
              width: double.infinity,
              height: 276.h,
              color: AppColors.gray100,
              child: const Center(
                child: Icon(
                  Icons.image_not_supported,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
        if (status != null && status!.isNotEmpty)
          Positioned(
            top: 16.h,
            left: 24.w,
            child: ExhibitDetailModelStatusBadge(status!),
          ),
      ],
    );
  }
}
