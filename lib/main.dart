import 'package:arttrip/core/enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/app_colors.dart';
import 'features/login/view/login_view.dart';
import 'l10n/generated/app_localizations.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const ArtTripApp());
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
        return MaterialApp(
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
          home: const LoginView(),
        );
      },
    );
  }
}
