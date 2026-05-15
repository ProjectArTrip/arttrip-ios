import 'package:arttrip/shared/widgets/app_cached_image.dart';
import 'package:arttrip/shared/widgets/exhibit_status_badge.dart';
import 'package:arttrip/shared/widgets/image_empty_big_widget.dart';
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
            : ImageEmptyBigWidget(width: double.infinity, height: 276.h),

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
