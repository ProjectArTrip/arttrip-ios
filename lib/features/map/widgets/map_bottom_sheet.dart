import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/enum.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/map/viewmodels/map_viewmodel.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:arttrip/shared/widgets/exhibit_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class MapBottomSheet extends StatelessWidget {
  const MapBottomSheet({
    super.key,
    required this.sheetController,
    required this.onDragUp,
  });

  final DraggableScrollableController sheetController;
  final VoidCallback onDragUp;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: sheetController,
      initialChildSize: 0.07,
      minChildSize: 0.07,
      maxChildSize: 0.8,
      snap: true,
      snapSizes: const [0.4, 0.8],
      builder: (context, scrollController) {
        return NotificationListener<DraggableScrollableNotification>(
          onNotification: (notification) {
            if (notification.extent > 0.1) {
              onDragUp();
            }
            return false;
          },
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: AppColors.gray0,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(16.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: Consumer<MapViewModel>(
              builder: (context, vm, _) {
                final exhibits = vm.currentExhibits;
                final count = vm.exhibitTotalCount;
                final isLoading =
                    vm.exhibitsState.status == AsyncStatus.loading;
                final hasData = exhibits.isNotEmpty || count > 0;

                return CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    // 드래그 핸들 (스크롤 시 고정)
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _HandleHeaderDelegate(
                        sheetController: sheetController,
                      ),
                    ),

                    // 접힌 상태: "전시 리스트 확인하기"
                    if (!hasData)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: Center(
                            child: ArtTripText.pretendard()
                                .body01Bold()
                                .color(AppColors.primary300)
                                .build()
                                .text(context.l10n.mapExhibitListButton),
                          ),
                        ),
                      ),

                    // 헤더 (스크롤 시 고정)
                    if (hasData)
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _StickyHeaderDelegate(count: count),
                      ),

                    // 전시 리스트
                    if (exhibits.isNotEmpty)
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (exhibits.length > 3 &&
                                index == exhibits.length - 3) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                context
                                    .read<MapViewModel>()
                                    .fetchMoreExhibits();
                              });
                            }
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 24.w,
                                vertical: 8.h,
                              ),
                              child: ExhibitListItem(
                                item: exhibits[index],
                              ),
                            );
                          },
                          childCount: exhibits.length,
                        ),
                      ),

                    // 하단 여백
                    if (exhibits.isNotEmpty)
                      SliverToBoxAdapter(
                        child: SizedBox(height: 24.h),
                      ),

                    // 로딩 상태
                    if (isLoading && hasData)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),

                    // 빈 상태 (로딩 아닐 때만)
                    if (!isLoading && exhibits.isEmpty && count > 0)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: ArtTripText.pretendard()
                              .body01Regular()
                              .color(AppColors.textTertiary)
                              .build()
                              .text(
                                context.l10n.mapNoExhibits,
                              ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

}

class _HandleHeaderDelegate extends SliverPersistentHeaderDelegate {
  _HandleHeaderDelegate({required this.sheetController});

  final DraggableScrollableController sheetController;
  static const double _height = 28;
  static const _snapSizes = [0.07, 0.4, 0.8];

  @override
  double get maxExtent => _height;

  @override
  double get minExtent => _height;

  @override
  bool shouldRebuild(covariant _HandleHeaderDelegate oldDelegate) => false;

  void _onTap() {
    if (!sheetController.isAttached) return;
    final target = sheetController.size < 0.5 ? 0.8 : 0.4;
    sheetController.animateTo(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _onDragUpdate(DragUpdateDetails details, BuildContext context) {
    if (!sheetController.isAttached) return;
    final screenHeight = MediaQuery.of(context).size.height;
    final delta = -details.delta.dy / screenHeight;
    final newSize = (sheetController.size + delta).clamp(0.07, 0.8);
    sheetController.jumpTo(newSize);
  }

  void _onDragEnd(DragEndDetails details) {
    if (!sheetController.isAttached) return;
    final velocity = details.primaryVelocity ?? 0;
    final current = sheetController.size;

    double target;
    if (velocity < -300) {
      final above = _snapSizes.where((s) => s > current + 0.01).toList();
      target = above.isNotEmpty ? above.first : _snapSizes.last;
    } else if (velocity > 300) {
      final below = _snapSizes.where((s) => s < current - 0.01).toList();
      target = below.isNotEmpty ? below.last : _snapSizes.first;
    } else {
      target = _snapSizes.reduce(
        (a, b) => (a - current).abs() < (b - current).abs() ? a : b,
      );
    }

    sheetController.animateTo(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return GestureDetector(
      onTap: _onTap,
      onVerticalDragUpdate: (d) => _onDragUpdate(d, context),
      onVerticalDragEnd: _onDragEnd,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: _height,
        color: AppColors.gray0,
        alignment: Alignment.center,
        child: Container(
          width: 32.w,
          height: 4.h,
          decoration: BoxDecoration(
            color: AppColors.gray100,
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _StickyHeaderDelegate({required this.count});

  final int count;
  static const double _height = 56;

  @override
  double get maxExtent => _height;

  @override
  double get minExtent => _height;

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) =>
      count != oldDelegate.count;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      height: _height,
      color: AppColors.gray0,
      alignment: Alignment.bottomLeft,
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 8.h),
      child: Row(
        children: [
          ArtTripText.pretendard()
              .headline()
              .color(AppColors.textPrimary)
              .build()
              .text('${context.l10n.mapExhibitCount} '),
          SizedBox(width: 8.w),
          ArtTripText.pretendard()
              .headline()
              .color(AppColors.primary300)
              .build()
              .text('$count'),
          ArtTripText.pretendard()
              .headline()
              .color(AppColors.textPrimary)
              .build()
              .text(context.l10n.mapExhibitUnit),
        ],
      ),
    );
  }
}
