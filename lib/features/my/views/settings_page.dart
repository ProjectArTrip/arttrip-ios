import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/auth/services/auth_service.dart';
import 'package:arttrip/features/my/widgets/my_menu_item.dart';
import 'package:arttrip/routes/app_routes.dart';
import 'package:arttrip/routes/route_params.dart';
import 'package:arttrip/routes/routes.dart';
import 'package:arttrip/shared/utils/snackbar_utils.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:arttrip/shared/widgets/app_confirm_dialog.dart';
import 'package:arttrip/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() => _appVersion = packageInfo.version);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray0,
      appBar: CommonAppBar(
        title: context.l10n.settingsTitle,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            _buildSectionHeader(context.l10n.permissionSettings),
            // -------------------------------------------------------------- //
            SizedBox(height: 16.h),
            MyMenuItem(
              title: context.l10n.notificationSettings,
              onTap: () {
                // 알림 설정 (추후 구현)
              },
            ),
            // -------------------------------------------------------------- //
            SizedBox(height: 56.h),
            _buildSectionHeader(context.l10n.arttripInfo),
            // -------------------------------------------------------------- //
            SizedBox(height: 16.h),
            MyMenuItem(
              title: context.l10n.notices,
              onTap: () {
                // 공지사항 (추후 구현)
              },
            ),
            // -------------------------------------------------------------- //
            SizedBox(height: 16.h),
            MyMenuItem(
              title: context.l10n.privacyPolicy,
              onTap: () => Routes.push(
                context,
                AppRoutes.webview,
                extra: WebViewParams(
                  title: context.l10n.privacyPolicy,
                  url:
                      'https://chiseled-cow-85a.notion.site/2ccbd56ec2ac8075b2e5dfa195f16bba?pvs=74',
                ),
              ),
            ),
            // -------------------------------------------------------------- //
            SizedBox(height: 16.h),
            MyMenuItem(
              title: context.l10n.termsOfService,
              onTap: () => Routes.push(
                context,
                AppRoutes.webview,
                extra: WebViewParams(
                  title: context.l10n.termsOfService,
                  url:
                      'https://chiseled-cow-85a.notion.site/2ccbd56ec2ac804ba690ce059d418a63?pvs=74',
                ),
              ),
            ),
            // -------------------------------------------------------------- //
            SizedBox(height: 16.h),
            MyMenuItem(
              title: context.l10n.appVersion,
              trailing: _appVersion,
              showArrow: false,
              onTap: () {},
            ),
            // ------------------------------------------ -------------------- //
            SizedBox(height: 24.h),
            MyMenuItem(
              title: context.l10n.deleteAccount,
              textColor: AppColors.textSecondary,
              showArrow: false,
              onTap: () => _onDeleteAccountTap(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: ArtTripText.pretendard()
          .title01Bold()
          .color(AppColors.textPrimary)
          .build()
          .text(title),
    );
  }

  Future<void> _onDeleteAccountTap() async {
    final result = await AppConfirmDialog.show(
      context: context,
      title: context.l10n.deleteAccountTitle,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ArtTripText.pretendard()
              .body01Regular()
              .color(AppColors.textPrimary)
              .textAlign(TextAlign.center)
              .build()
              .text(context.l10n.deleteAccountContent),
          SizedBox(height: 16.h),
          ArtTripText.pretendard()
              .body01Bold()
              .color(AppColors.textPrimary)
              .build()
              .text(context.l10n.deleteAccountQuestion),
        ],
      ),
      cancelText: context.l10n.cancel,
      confirmText: context.l10n.deleteAccountButton,
    );

    if (result != true) return;

    final isSuccess = await AuthService.instance.withdraw();
    if (!mounted) return;

    if (isSuccess) {
      Routes.go(context, AppRoutes.login);
    } else {
      SnackBarUtils.showError(
        context,
        message: context.l10n.deleteAccountFailed,
      );
    }
  }
}
