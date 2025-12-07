import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/extensions.dart';
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
  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
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
                      onPressed: () {
                        // TODO: Implement Kakao login
                      },
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
