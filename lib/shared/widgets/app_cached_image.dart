import 'package:arttrip/core/app_consts.dart';
import 'package:arttrip/shared/widgets/image_empty_big_widget.dart';
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
    this.errorWidget,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget Function(BuildContext, String, Object)? errorWidget;

  @override
  Widget build(BuildContext context) {
    final Widget image = CachedNetworkImage(
      cacheKey: imageUrl,
      imageUrl: imageUrl,
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => _buildPlaceholder(),
      errorWidget:
          errorWidget ??
          (context, url, error) =>
              ImageEmptyBigWidget(width: width, height: height),
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }

  Widget _buildPlaceholder() {
    final Widget placeholder = Shimmer(
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
