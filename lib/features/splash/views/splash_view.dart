import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/features/auth/services/auth_service.dart';
import 'package:arttrip/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 스플래시 화면
///
/// 앱 시작 시 인증 상태를 확인하고 적절한 화면으로 이동
/// 토큰 만료 여부는 API 호출 시 서버 401 응답으로 판단
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndNavigate();
    });
  }

  Future<void> _checkAuthAndNavigate() async {
    // 네이티브 스플래시 제거
    FlutterNativeSplash.remove();

    final authService = AuthService.instance;

    // 토큰 존재 여부만 확인 (만료 여부는 API 호출 시 서버에서 판단)
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
    Routes.go(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}
