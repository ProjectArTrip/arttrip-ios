import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/app_consts.dart';
import 'package:arttrip/core/app_utils.dart';
import 'package:arttrip/core/config/prefs.dart';
import 'package:arttrip/core/config/provider_config.dart';
import 'package:arttrip/core/enum.dart';
import 'package:arttrip/core/env.dart';
import 'package:arttrip/core/network/network.dart';
import 'package:arttrip/features/alert/local_noti_widget.dart';
import 'package:arttrip/features/auth/services/auth_service.dart';
import 'package:arttrip/features/auth/services/token_storage_service.dart';
import 'package:arttrip/l10n/generated/app_localizations.dart';
import 'package:arttrip/routes/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  AppUtil.debugLog('FCM background message: ${message.messageId}');
}

OverlayEntry? _inAppBannerEntry;

void _showLocalNoti(RemoteMessage message) {
  final overlay = appRouter.routerDelegate.navigatorKey.currentState?.overlay;
  if (overlay == null) return;

  _inAppBannerEntry?.remove();
  _inAppBannerEntry = OverlayEntry(
    builder: (_) => LocalNotiWidget(
      message: message.notification?.title ?? '',
      onDismiss: () {
        _inAppBannerEntry?.remove();
        _inAppBannerEntry = null;
      },
    ),
  );
  overlay.insert(_inAppBannerEntry!);
}

Future<void> _initFcm() async {
  final messaging = FirebaseMessaging.instance;

  await messaging.requestPermission(
    alert: true,
    announcement: true,
    badge: true,
    carPlay: false,
    criticalAlert: true,
    provisional: true,
    sound: true,
  );

  try {
    final token = await messaging.getToken();
    if (token != null) {
      await Prefs().setFcmToken(token);
      AppUtil.debugLog('FCM token saved: $token');
    }
  } catch (e) {
    AppUtil.debugLog('Failed to get FCM token: $e');
  }

  // 포그라운드 메시지 - 인앱 배너만 표시
  FirebaseMessaging.onMessage.listen((message) {
    AppUtil.debugLog('FCM foreground message: ${message.toMap()}');
    _showLocalNoti(message);
  });

  // 백그라운드에서 알림 탭해서 앱 열었을 때
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    AppUtil.debugLog('FCM onMessageOpenedApp: ${message.toMap()}');
  });

  // 종료 상태에서 알림 탭해서 앱 열었을 때
  final initialMessage = await messaging.getInitialMessage();
  if (initialMessage != null) {
    AppUtil.debugLog('FCM initialMessage: ${initialMessage.toMap()}');
  }
}

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 시스템 UI 모드 설정
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top],
  );

  // 앱 이름 초기화
  AppConsts.appName = (await PackageInfo.fromPlatform()).appName;

  // 환경 변수 로드
  await dotenv.load(fileName: '.env');

  // SharedPreferences 초기화
  await Prefs().init();

  // Firebase 초기화
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await _initFcm();

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

  runApp(MultiProvider(providers: getProviders, child: const ArtTripApp()));
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
