import 'dart:async';

import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/app_consts.dart';
import 'package:arttrip/core/app_utils.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/alert/alert_model.dart';
import 'package:arttrip/features/alert/alert_viewmodel.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:arttrip/shared/widgets/alert_badge.dart';
import 'package:arttrip/shared/widgets/common_appbar.dart';
import 'package:arttrip/shared/widgets/exception_view.dart';
import 'package:arttrip/shared/widgets/shimmer_skeleton_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  final ValueNotifier<List<AlertModel>?> _alerts = ValueNotifier([]);
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _isLoading = ValueNotifier(true); // 전체 로딩 상태
  final ValueNotifier<bool> _hasNext = ValueNotifier(true); // 다음 페이지 존재 여부
  final ValueNotifier<bool> _loadingMore = ValueNotifier(false); // 추가 로딩 상태

  final double threshold = 50.0;
  final int _size = 10;
  int? _cursor;

  @override
  void initState() {
    super.initState();

    final alertVM = context.read<AlertViewModel>();
    Future.delayed(Duration.zero, () async {
      final result = await alertVM.getAlerts(
        cursor: _cursor,
        size: _size,
      );
      _alerts.value = result?.notifications;
      _isLoading.value = false;
      _hasNext.value = result?.hasNext ?? false;
      _cursor = result?.nextCursor;

      /// 알림 전체 읽음 처리
      unawaited(alertVM.markAllAsRead());
    });

    _scrollController.addListener(_scrollControllerListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollControllerListener() async {
    // 데이터 로딩중이거나 더 불러올 데이터가 없으면 추가 로딩 방지
    if (_loadingMore.value || !_hasNext.value) return;
    _loadingMore.value = true;

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - threshold) {
      if (!_isLoading.value && _hasNext.value) {
        AppUtil.debugLog('now loading more');
        await _loadMoreAlerts();
      }
    }
    _loadingMore.value = false;
  }

  Future<void> _loadMoreAlerts() async {
    if (!_hasNext.value) return;

    final alertVM = context.read<AlertViewModel>();
    final result = await alertVM.getAlerts(
      cursor: _cursor,
      size: _size,
    );
    _alerts.value = [...?_alerts.value, ...?result?.notifications];
    _hasNext.value = result?.hasNext ?? false;
    _cursor = result?.nextCursor;
  }

  String _formatRelativeTime(String createdAt) {
    try {
      final diff = DateTime.now().difference(
        DateTime.parse(createdAt).toLocal(),
      );
      if (diff.inMinutes < 60) return context.l10n.minutesAgo(diff.inMinutes);
      if (diff.inHours < 24) return context.l10n.hoursAgo(diff.inHours);
      return '${diff.inDays}일 전';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: context.l10n.alert),
      body: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(
              left: 24.w,
              top: 8.h,
              right: 24.w,
              bottom: 48.h,
            ),
            sliver: ValueListenableBuilder(
              valueListenable: _isLoading,
              builder: (context, isLoading, child) {
                if (isLoading) {
                  return SliverToBoxAdapter(child: _buildAlertsLoading());
                }

                return ValueListenableBuilder(
                  valueListenable: _alerts,
                  builder: (context, alerts, _) {
                    if (alerts == null) {
                      return SliverToBoxAdapter(child: _buildAlertsError());
                    } else if (alerts.isEmpty) {
                      return SliverToBoxAdapter(child: _buildAlertsEmpty());
                    }

                    return ValueListenableBuilder(
                      valueListenable: _loadingMore,
                      builder: (context, loadingMore, child) {
                        final int length =
                            alerts.length + (loadingMore ? 1 : 0);
                        return SliverList.separated(
                          itemCount: length,
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 4.h),
                          itemBuilder: (context, index) {
                            if (loadingMore && index == alerts.length) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final AlertModel item = alerts[index];

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 8.w,
                              children: [
                                Padding(
                                  padding: EdgeInsetsGeometry.all(12.w),
                                  child: AlertBadge(
                                    iconType: true,
                                    hasUnread: !item.isRead,
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 13.h),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          ArtTripText.pretendard()
                                              .title02Bold()
                                              .color(
                                                !item.isRead
                                                    ? AppColors.textPrimary
                                                    : AppColors.textSecondary,
                                              )
                                              .build()
                                              .text(item.title),
                                          ArtTripText.pretendard()
                                              .body02Light()
                                              .color(AppColors.textTertiary)
                                              .build()
                                              .text(
                                                _formatRelativeTime(
                                                  item.createdAt,
                                                ),
                                              ),
                                        ],
                                      ),
                                      SizedBox(height: 8.h),
                                      ArtTripText.pretendard()
                                          .body01Regular()
                                          .color(
                                            !item.isRead
                                                ? AppColors.textSecondary
                                                // ignore: dead_code
                                                : AppColors.textTertiary,
                                          )
                                          .ellipsis(2)
                                          .build()
                                          .text(item.body),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsLoading() {
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
        itemCount: 10,
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        itemBuilder: (context, index) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8.w,
          children: [
            Padding(
              padding: EdgeInsetsGeometry.all(12.w),
              child: const ShimmerSkeletonItem(width: 24, height: 24),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 13.h),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShimmerSkeletonItem(width: 160, height: 16),
                      ShimmerSkeletonItem(width: 40, height: 12),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  const ShimmerSkeletonItem(height: 14),
                  SizedBox(height: 4.h),
                  const ShimmerSkeletonItem(width: 200, height: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsEmpty() {
    return Align(
      alignment: Alignment.center,
      child: Column(
        spacing: 8.h,
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(AppAssets.icNoExhibits, width: 96.w, height: 96.w),
          ArtTripText.pretendard()
              .body01Regular()
              .textAlign(TextAlign.center)
              .color(AppColors.textTertiary)
              .build()
              .text(context.l10n.noAlertsTitle),
        ],
      ),
    );
  }

  Widget _buildAlertsError() {
    return const ExceptionView();
  }
}
