import 'package:flutter/material.dart';
import 'l10n/generated/app_localizations.dart';

import 'core/app_colors.dart';
import 'shared/main_view.dart';

void main() {
  runApp(const ArtTripApp());
}

class ArtTripApp extends StatelessWidget {
  const ArtTripApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ArtTrip',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary300),
        scaffoldBackgroundColor: AppColors.gray0,
        useMaterial3: true,
        fontFamily: 'Pretendard',
      ),
      home: const MainView(),
    );
  }
}
