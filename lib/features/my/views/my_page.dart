import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/auth/services/auth_service.dart';
import 'package:arttrip/features/my/data/models/user_profile_model.dart';
import 'package:arttrip/features/my/viewmodels/my_viewmodel.dart';
import 'package:arttrip/features/my/widgets/my_menu_item.dart';
import 'package:arttrip/features/my/widgets/my_profile_section.dart';
import 'package:arttrip/routes/routes.dart';
import 'package:arttrip/shared/widgets/alert_badge.dart';
import 'package:arttrip/shared/widgets/app_divider.dart';
import 'package:arttrip/shared/widgets/async_view.dart';
import 'package:arttrip/shared/widgets/common_appbar.dart';
import 'package:arttrip/shared/widgets/init_widget.dart';
import 'package:arttrip/shared/widgets/shimmer_skeleton_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return InitWidget(
      init: () => context.read<MyViewModel>().fetchUserProfile(),
      child: Scaffold(
        backgroundColor: AppColors.gray0,
        appBar: CommonAppBar(
          title: context.l10n.myPageTitle,
          showBackButton: false,
          actions: [
            const AlertBadge(path: '/alerts'),
            SizedBox(width: 20.w),
            SvgPicture.asset(AppAssets.icSearch, width: 24.w, height: 24.w),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileSection(context),
              const AppDivider(),
              SizedBox(height: 20.h),
              _buildMenuList(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return Selector<MyViewModel, AsyncState<UserProfileModel>>(
      selector: (_, vm) => vm.profileState,
      builder: (context, state, _) {
        return AsyncView<UserProfileModel>(
          state: state,
          onLoading: () => _buildProfileSkeleton(),
          onData:
              (profile) => MyProfileSection(
                profile: profile,
                onTap: () {
                  Routes.push(context, '/my/edit-profile', extra: profile);
                },
              ),
        );
      },
    );
  }

  Widget _buildProfileSkeleton() {
    return Shimmer(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Row(
          children: [
            const ShimmerSkeletonItem(width: 80, height: 80, radius: 40),
            SizedBox(width: 12.w),
            const ShimmerSkeletonItem(width: 80, height: 20, radius: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuList(BuildContext context) {
    return Column(
      children: [
        MyMenuItem(
          title: context.l10n.myRecentExhibits,
          onTap: () {
            // 최근 본 전시 (추후 구현)
          },
        ),
        SizedBox(height: 24.h),
        MyMenuItem(
          title: context.l10n.myReviews,
          onTap: () => Routes.push(context, '/my/reviews'),
        ),
        SizedBox(height: 24.h),
        MyMenuItem(
          title: context.l10n.myTasteAnalysis,
          onTap: () => Routes.push(context, '/my/taste-analysis'),
        ),
        SizedBox(height: 24.h),
        MyMenuItem(
          title: context.l10n.settings,
          onTap: () => Routes.push(context, '/my/settings'),
        ),
        SizedBox(height: 24.h),
        MyMenuItem(
          title: context.l10n.logout,
          textColor: AppColors.subRed,
          showArrow: false,
          onTap: () => _handleLogout(context),
        ),
      ],
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    await AuthService.instance.logout();
    if (context.mounted) {
      Routes.go(context, '/login');
    }
  }
}
