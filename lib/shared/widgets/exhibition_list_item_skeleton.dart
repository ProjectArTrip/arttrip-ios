import 'package:arttrip/shared/widgets/shimmer_skeleton_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExhibitionListItemSkeleton extends StatelessWidget {
  const ExhibitionListItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 12.w,
      children: [
        const ShimmerSkeletonItem(width: 100, height: 100, radius: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerSkeletonItem(width: 64, height: 16, radius: 10),
            SizedBox(height: 4.h),
            const ShimmerSkeletonItem(width: 160, height: 16, radius: 10),
            SizedBox(height: 4.h),
            const ShimmerSkeletonItem(width: 120, height: 14, radius: 10),
            SizedBox(height: 2.h),
            const ShimmerSkeletonItem(width: 120, height: 14, radius: 10),
          ],
        ),
      ],
    );
  }
}
