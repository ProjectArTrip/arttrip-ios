import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/config/prefs.dart';
import 'package:arttrip/core/config/provider_config.dart';
import 'package:arttrip/core/enum.dart';
import 'package:arttrip/core/env.dart';
import 'package:arttrip/core/network/network.dart';
import 'package:arttrip/features/auth/service/auth_service.dart';
import 'package:arttrip/features/auth/service/token_storage_service.dart';
import 'package:arttrip/l10n/generated/app_localizations.dart';
import 'package:arttrip/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:provider/provider.dart';

void main() async {
  var widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 시스템 UI 모드 설정
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.top]);

  // 환경 변수 로드
  await dotenv.load(fileName: '.env');

  // SharedPreferences 초기화
  await Prefs().init();

  // 카카오 SDK 초기화
  KakaoSdk.init(nativeAppKey: Env.kakaoNativeAppKey);

  // Dio 클라이언트 초기화
  DioClient.instance.initialize(
    options: DioClientOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      enableLogging: true,
      enableRetry: true,
      maxRetries: 3,
    ),
    authInterceptor: AuthInterceptor(
      tokenProvider: () async => TokenStorageService.instance.getAccessToken(),
      onTokenRefresh: () => AuthService.instance.refreshToken(),
      onTokenExpired: () async {
        await AuthService.instance.logout();
        appRouter.go('/login');
      },
    ),
  );

  runApp(MultiProvider(
    providers: getProviders,
    child: const ArtTripApp(),
  ));
}

class ArtTripApp extends StatelessWidget {
  const ArtTripApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp.router(
          title: 'ArtTrip',
          debugShowCheckedModeBanner: false,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary300),
            scaffoldBackgroundColor: AppColors.gray0,
            useMaterial3: true,
            fontFamily: FontFamilyType.pretendard.fontName,
          ),
          routerConfig: appRouter,
        );
      },
    );
  }
}
