import 'dart:async';

import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/enum.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/auth/services/auth_service.dart';
import 'package:arttrip/routes/app_routes.dart';
import 'package:arttrip/routes/routes.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:arttrip/shared/widgets/social_login_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  int _logoTapCount = 0;
  bool _showTestLogin = false;

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
  }

  void _onLogoTap() {
    setState(() {
      _logoTapCount++;
      if (_logoTapCount >= 5) {
        _showTestLogin = true;
      }
    });
  }

  OverlayEntry? _errorEntry;

  void _showLoginError() {
    _errorEntry?.remove();
    _errorEntry = OverlayEntry(
      builder: (_) => _LoginErrorOverlay(
        onDismiss: () {
          _errorEntry?.remove();
          _errorEntry = null;
        },
      ),
    );
    Overlay.of(context).insert(_errorEntry!);
  }

  Future<void> _handleTestLogin() async {
    final credentials = await showDialog<(String, String)>(
      context: context,
      builder: (_) => const _TestLoginDialog(),
    );
    if (credentials == null || !mounted) return;

    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final result = await AuthService.instance.loginWithTestAccount(
        context,
        email: credentials.$1,
        password: credentials.$2,
      );
      if (!mounted) return;
      if (result.isSuccess) {
        _navigateAfterLogin(result.onboardingStep);
      } else {
        _showLoginError();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleLogin(BuildContext buildContext) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final params = await AuthService.instance.getGoogleCredentials();
      if (!mounted) return;
      if (params != null) {
        await Routes.push(context, AppRoutes.onboardingTerms, extra: params);
      } else {
        _showLoginError();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAppleLogin(BuildContext buildContext) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final params = await AuthService.instance.getAppleCredentials();
      if (!mounted) return;
      if (params != null) {
        await Routes.push(context, AppRoutes.onboardingTerms, extra: params);
      } else {
        _showLoginError();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleKakaoLogin(BuildContext buildContext) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final params = await AuthService.instance.getKakaoCredentials();
      if (!mounted) return;
      if (params != null) {
        await Routes.push(context, AppRoutes.onboardingTerms, extra: params);
      } else {
        _showLoginError();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateAfterLogin(OnboardingStep? step) {
    switch (step) {
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
    return Scaffold(
      backgroundColor: AppColors.primary300,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _onLogoTap,
                  child: SvgPicture.asset(
                    AppAssets.icLogoWhite,
                    width: 188.w,
                    height: 59.h,
                  ),
                ),
                SizedBox(height: 120.h),
                Column(
                  spacing: 12.h,
                  children: [
                    SocialLoginButton(
                      onPressed: _isLoading
                          ? () {}
                          : () => _handleKakaoLogin(context),
                      label: context.l10n.loginKakao,
                      icon: AppAssets.icKakao,
                      backgroundColor: AppColors.subKakao,
                      textColor: Colors.black,
                    ),
                    SocialLoginButton(
                      onPressed: _isLoading
                          ? () {}
                          : () => _handleGoogleLogin(context),
                      label: context.l10n.loginGoogle,
                      icon: AppAssets.icGoogle,
                      backgroundColor: AppColors.gray0,
                      textColor: Colors.black,
                    ),
                    SocialLoginButton(
                      onPressed: _isLoading
                          ? () {}
                          : () => _handleAppleLogin(context),
                      label: context.l10n.loginApple,
                      icon: AppAssets.icApple,
                      backgroundColor: AppColors.gray900,
                      textColor: AppColors.textWhite,
                    ),
                    if (_showTestLogin)
                      SocialLoginButton(
                        onPressed: _handleTestLogin,
                        label: context.l10n.loginTest,
                        icon: AppAssets.icException,
                        backgroundColor: AppColors.textTertiary,
                        textColor: AppColors.textPrimary,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 로그인 실패 시 하단에 나타나는 에러 메시지 오버레이
class _LoginErrorOverlay extends StatefulWidget {
  const _LoginErrorOverlay({required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  State<_LoginErrorOverlay> createState() => _LoginErrorOverlayState();
}

class _LoginErrorOverlayState extends State<_LoginErrorOverlay> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), widget.onDismiss);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: widget.onDismiss,
          child: SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(left: 32.w, right: 32.w, bottom: 80.h),
                child: GestureDetector(
                  onTap: widget.onDismiss,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: 24.h,
                      horizontal: 10.w,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.textTertiary,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: ArtTripText.pretendard()
                        .body01Bold()
                        .color(AppColors.gray0)
                        .textAlign(TextAlign.center)
                        .build()
                        .text(context.l10n.loginFailed),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TestLoginDialog extends StatefulWidget {
  const _TestLoginDialog();

  @override
  State<_TestLoginDialog> createState() => _TestLoginDialogState();
}

class _TestLoginDialogState extends State<_TestLoginDialog> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ArtTripText.pretendard()
                .body01Bold()
                .color(AppColors.textPrimary)
                .build()
                .text(context.l10n.loginTest),
            SizedBox(height: 20.h),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: context.l10n.emailLabel,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 12.h,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: context.l10n.passwordLabel,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 12.h,
                ),
              ),
            ),
            SizedBox(height: 24.h),
            GestureDetector(
              onTap: () => Navigator.pop(
                context,
                (_emailController.text.trim(), _passwordController.text),
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  color: AppColors.primary300,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                alignment: Alignment.center,
                child: ArtTripText.pretendard()
                    .body01Bold()
                    .color(AppColors.gray0)
                    .build()
                    .text(context.l10n.loginButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
