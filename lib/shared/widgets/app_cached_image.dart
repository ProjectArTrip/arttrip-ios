import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/app_consts.dart';
import 'package:arttrip/shared/widgets/shimmer_skeleton_item.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

/// 공용 네트워크 이미지 위젯
/// - Shimmer 스켈레톤 로딩
/// - 에러 시 기본 아이콘 표시
/// - 선택적 borderRadius 지원
class AppCachedImage extends StatelessWidget {
  const AppCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.debugShowPlaceholder = true, // 테스트용: true면 placeholder만 표시
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final bool debugShowPlaceholder;

  @override
  Widget build(BuildContext context) {
    // 테스트용: placeholder만 표시
    if (debugShowPlaceholder) {
      return _buildPlaceholder();
    }

    Widget image = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => _buildPlaceholder(),
      errorWidget:
          (context, url, error) => Container(
            width: width,
            height: height,
            color: AppColors.gray100,
            child: const Center(
              child: Icon(
                Icons.image_not_supported,
                color: AppColors.textTertiary,
              ),
            ),
          ),
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }

  Widget _buildPlaceholder() {
    Widget placeholder = Shimmer(
      duration: const Duration(milliseconds: AppConsts.shimmerDurationMs),
      interval: const Duration(milliseconds: AppConsts.shimmerIntervalMs),
      child: ShimmerSkeletonItem(width: width, height: height, radius: 0),
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: placeholder);
    }
    return placeholder;
  }
}
