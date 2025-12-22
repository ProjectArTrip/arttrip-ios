import 'package:arttrip/core/app_consts.dart';
import 'package:arttrip/core/network/network.dart';
import 'package:arttrip/features/exhibit/data/exhibit_repository.dart';
import 'package:arttrip/features/exhibit/data/exhibit_repository_mock.dart';
import 'package:arttrip/features/exhibit/viewmodel/exhibit_detail_viewmodel.dart';
import 'package:arttrip/features/exhibit/viewmodel/write_review_viewmodel.dart';
import 'package:arttrip/features/home/home_repository.dart';
import 'package:arttrip/features/home/home_repository_hybrid.dart';
import 'package:arttrip/features/home/home_repository_mock.dart';
import 'package:arttrip/features/home/home_viewmodel.dart';
import 'package:arttrip/features/onboarding/data/keywords_repository.dart';
import 'package:arttrip/features/onboarding/data/keywords_repository_mock.dart';
import 'package:arttrip/features/onboarding/viewmodel/keywords_viewmodel.dart';
import 'package:provider/provider.dart';

/// ViewModel Providers
final List<ChangeNotifierProvider> getProviders = [
  ChangeNotifierProvider<HomeViewModel>(
    create:
        (_) => HomeViewModel(
          HomeRepositoryHybrid(
            mock: HomeRepositoryMockImpl(),
            api: HomeRepositoryImpl(DioClient.instance),
          ),
        ),
  ),
  ChangeNotifierProvider<KeywordsViewModel>(
    create:
        (_) => KeywordsViewModel(
          AppConsts.useMock
              ? KeywordsRepositoryMockImpl()
              : KeywordsRepositoryImpl(DioClient.instance),
        ),
  ),
  ChangeNotifierProvider<ExhibitDetailViewModel>(
    create:
        (_) => ExhibitDetailViewModel(
          AppConsts.useMock
              ? ExhibitRepositoryMockImpl()
              : ExhibitRepositoryImpl(DioClient.instance),
        ),
  ),
  ChangeNotifierProvider<WriteReviewViewModel>(
    create:
        (_) => WriteReviewViewModel(
          AppConsts.useMock
              ? ExhibitRepositoryMockImpl()
              : ExhibitRepositoryImpl(DioClient.instance),
        ),
  ),
];
