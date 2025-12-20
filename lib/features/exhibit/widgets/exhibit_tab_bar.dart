import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:flutter/material.dart';

/// 전시 상세 페이지의 탭바 위젯
class ExhibitTabBar extends StatelessWidget {
  const ExhibitTabBar({super.key, required this.tabController});

  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.gray100, width: 1)),
      ),
      child: TabBar(
        controller: tabController,
        labelColor: AppColors.primary300,
        unselectedLabelColor: AppColors.textTertiary,
        labelStyle: ArtTripText.pretendard()
            .body01Bold()
            .color(AppColors.primary300)
            .build()
            .style(),
        unselectedLabelStyle: ArtTripText.pretendard()
            .body01Bold()
            .color(AppColors.textTertiary)
            .build()
            .style(),
        indicatorColor: AppColors.primary200,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorWeight: 2,
        dividerHeight: 0,
        tabs: [
          Tab(text: context.l10n.exhibitDetailTab),
          Tab(text: context.l10n.exhibitMapTab),
          Tab(text: context.l10n.exhibitReviewTab),
        ],
      ),
    );
  }
}

/// 탭바를 고정 헤더로 만들기 위한 Delegate
class ExhibitTabBarDelegate extends SliverPersistentHeaderDelegate {
  ExhibitTabBarDelegate({required this.child});

  final Widget child;

  @override
  double get minExtent => 48;

  @override
  double get maxExtent => 48;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant ExhibitTabBarDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}
