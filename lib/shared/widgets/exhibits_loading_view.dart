import 'package:arttrip/core/app_consts.dart';
import 'package:arttrip/shared/widgets/shimmer_skeleton_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

/// 전시 리스트가 로딩 중인 경우 보여주는 위젯
class ExhibitsLoadingView extends StatelessWidget {
  const ExhibitsLoadingView({super.key, this.itemCount = 5});

  final int itemCount; // 로딩 아이템 개수

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      duration: const Duration(
        milliseconds: AppConsts.shimmerDurationMs,
      ),
      interval: const Duration(
        milliseconds: AppConsts.shimmerIntervalMs,
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        itemBuilder: (context, index) => Row(
          spacing: 12.w,
          children: [
            const ShimmerSkeletonItem(width: 100, height: 100, radius: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerSkeletonItem(width: 160, height: 16, radius: 10),
                SizedBox(height: 4.h),
                const ShimmerSkeletonItem(width: 120, height: 14, radius: 10),
                SizedBox(height: 2.h),
                const ShimmerSkeletonItem(width: 120, height: 14, radius: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
