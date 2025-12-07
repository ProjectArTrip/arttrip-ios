import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/auth/service/auth_service.dart';
import 'package:arttrip/main_page.dart';

import 'package:arttrip/shared/utils/snackbar_utils.dart';
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

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
  }

  Future<void> _handleKakaoLogin() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      var result = await AuthService.instance.loginWithKakao();

      if (!mounted) return;

      if (result.isSuccess) {
        debugPrint('로그인 성공');

        // 메인 화면으로 이동
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainPage()),
        );
      } else {
        SnackBarUtils.showError(
          context,
          message: result.errorMessage ?? '로그인에 실패했습니다',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
                SvgPicture.asset(
                  AppAssets.logo,
                  width: 188.w,
                  height: 59.h,
                ),
                SizedBox(height: 120.h),
                Column(
                  spacing: 12.h,
                  children: [
                    SocialLoginButton(
                      onPressed: _isLoading ? () {} : () => _handleKakaoLogin(),
                      label: context.l10n.loginKakao,
                      icon: AppAssets.iconKakao,
                      backgroundColor: AppColors.subKakao,
                      textColor: Colors.black,
                    ),
                    SocialLoginButton(
                      onPressed: () {
                        // TODO: Implement Google login
                      },
                      label: context.l10n.loginGoogle,
                      icon: AppAssets.iconGoogle,
                      backgroundColor: AppColors.gray0,
                      textColor: Colors.black,
                    ),
                    SocialLoginButton(
                      onPressed: () {
                        // TODO: Implement Apple login
                      },
                      label: context.l10n.loginApple,
                      icon: AppAssets.iconApple,
                      backgroundColor: AppColors.gray900,
                      textColor: AppColors.textWhite,
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
