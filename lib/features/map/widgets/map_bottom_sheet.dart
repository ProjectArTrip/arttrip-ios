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
                      delegate: _HandleHeaderDelegate(onTap: _onHandleTap),
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

  void _onHandleTap() {
    if (!sheetController.isAttached) return;
    final target = sheetController.size < 0.5 ? 0.8 : 0.4;
    sheetController.animateTo(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}

class _HandleHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _HandleHeaderDelegate({required this.onTap});

  final VoidCallback onTap;
  static const double _height = 28;

  @override
  double get maxExtent => _height;

  @override
  double get minExtent => _height;

  @override
  bool shouldRebuild(covariant _HandleHeaderDelegate oldDelegate) => false;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return GestureDetector(
      onTap: onTap,
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
