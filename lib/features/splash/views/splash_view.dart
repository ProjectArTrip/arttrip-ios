import 'dart:io';

import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/app_utils.dart';
import 'package:arttrip/core/config/prefs.dart';
import 'package:arttrip/core/enum.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/auth/services/auth_service.dart';
import 'package:arttrip/features/splash/data/maintenance_model.dart';
import 'package:arttrip/features/splash/viewmodels/splash_viewmodel.dart';
import 'package:arttrip/routes/app_router.dart';
import 'package:arttrip/routes/app_routes.dart';
import 'package:arttrip/routes/routes.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:arttrip/shared/widgets/init_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

/// 스플래시 화면
///
/// 앱 시작 시 서버 점검 여부 확인 후 인증 상태를 확인하고 적절한 화면으로 이동
/// 토큰 만료 여부는 API 호출 시 서버 401 응답으로 판단
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  Future<void> _init() async {
    final vm = context.read<SplashViewModel>();
    await vm.fetchMaintenanceStatus();

    if (!mounted) return;

    final state = vm.maintenanceState;
    FlutterNativeSplash.remove();
    if (state == MaintenanceState.block) {
      await _showMaintenanceDialog(context, vm.maintenance!, isBlock: true);
    } else if (state == MaintenanceState.notice) {
      _checkAuthAndNavigate();

      final maintenance = vm.maintenance!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final navContext = appNavigatorKey.currentContext;

        if (navContext == null) return;
        showDialog<void>(
          context: navContext,
          barrierDismissible: false,
          builder: (ctx) => _buildDialog(ctx, maintenance, isBlock: false),
        );
      });
    } else {
      _checkAuthAndNavigate();
    }
  }

  /// 서버 공지/점검 팝업
  Future<void> _showMaintenanceDialog(
    BuildContext dialogContext,
    MaintenanceModel maintenance, {
    required bool isBlock,
  }) async {
    await showDialog<void>(
      context: dialogContext,
      barrierDismissible: false,
      builder: (ctx) => _buildDialog(ctx, maintenance, isBlock: isBlock),
    );
  }

  Widget _buildDialog(
    BuildContext ctx,
    MaintenanceModel maintenance, {
    required bool isBlock,
  }) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: AppColors.gray0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 24.w,
            right: 24,
            top: 32.h,
            bottom: 24.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ArtTripText.pretendard()
                  .font(16)
                  .height(1.5)
                  .fontWeight(FontWeight.bold)
                  .textAlign(TextAlign.center)
                  .build()
                  .text(maintenance.title ?? context.l10n.maintenanceTitle),
              SizedBox(height: 12.h),
              Divider(height: 1.h, color: AppColors.gray50),
              SizedBox(height: 24.h),
              ArtTripText.pretendard()
                  .body01Regular()
                  .textAlign(TextAlign.center)
                  .build()
                  .text(maintenance.message ?? context.l10n.maintenanceMessage),
              SizedBox(height: 16.h),
              ArtTripText.pretendard()
                  .body01Bold()
                  .textAlign(TextAlign.center)
                  .color(AppColors.subRed)
                  .build()
                  .text(
                    '${AppUtil.formatDateFullWithWeekday(context, AppUtil.parseDate(maintenance.startAt ?? ''))} ~ ${AppUtil.formatDateFullWithWeekday(context, AppUtil.parseDate(maintenance.endAt ?? ''))}',
                  ),
              SizedBox(height: 24.h),
              GestureDetector(
                onTap: () => isBlock ? exit(0) : Navigator.of(ctx).pop(),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 17.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary300,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  alignment: Alignment.center,
                  child: ArtTripText.pretendard()
                      .title02Bold()
                      .color(AppColors.textWhite)
                      .textAlign(TextAlign.center)
                      .build()
                      .text(maintenance.buttonText ?? context.l10n.exit),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _checkAuthAndNavigate() {
    if (!mounted) return;

    final authService = AuthService.instance;

    if (authService.isLoggedIn()) {
      _navigateToHome();
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    if (!mounted) return;
    Routes.go(context, '/login');
  }

  void _navigateToHome() {
    if (!mounted) return;
    switch (Prefs().onboardingStep) {
      case OnboardingStep.nickname:
        Routes.go(context, AppRoutes.onboardingNickname);
      case OnboardingStep.keyword:
        Routes.go(context, AppRoutes.onboardingKeywords);
      case OnboardingStep.completed:
      case null:
        Routes.go(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return InitWidget(
      init: _init,
      child: Scaffold(
        backgroundColor: AppColors.primary300,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16.h),
              Text(
                '로그인 확인 중...',
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
