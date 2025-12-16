import 'package:arttrip/core/app_consts.dart';
import 'package:arttrip/core/network/network.dart';
import 'package:arttrip/features/home/home_repository.dart';
import 'package:arttrip/features/home/home_repository_mock.dart';
import 'package:arttrip/features/home/home_viewmodel.dart';
import 'package:arttrip/features/home/hybrid_home_repository.dart';
import 'package:arttrip/features/onboarding/data/keywords_repository.dart';
import 'package:arttrip/features/onboarding/data/keywords_repository_mock.dart';
import 'package:arttrip/features/onboarding/viewmodel/keywords_viewmodel.dart';
import 'package:provider/provider.dart';

final List<ChangeNotifierProvider> getProviders = [
  ChangeNotifierProvider<HomeViewModel>(
    create: (_) => HomeViewModel(
        HybridHomeRepository(mock: HomeRepositoryMockImpl(), api: HomeRepositoryImpl(DioClient.instance))),
  ),
  ChangeNotifierProvider<KeywordsViewModel>(
    create: (_) => KeywordsViewModel(
        AppConsts.useMock ? KeywordsRepositoryMockImpl() : KeywordsRepositoryImpl(DioClient.instance)),
  ),
];
