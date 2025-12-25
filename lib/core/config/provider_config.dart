import 'package:arttrip/core/app_consts.dart';
import 'package:arttrip/core/network/network.dart';
import 'package:arttrip/features/exhibit/data/exhibit_repository.dart';
import 'package:arttrip/features/exhibit/data/exhibit_repository_hybrid.dart';
import 'package:arttrip/features/exhibit/data/exhibit_repository_mock.dart';
import 'package:arttrip/features/exhibit/viewmodels/exhibit_detail_viewmodel.dart';
import 'package:arttrip/features/exhibit/viewmodels/exhibit_viewmodel.dart';
import 'package:arttrip/features/exhibit/viewmodels/write_review_viewmodel.dart';
import 'package:arttrip/features/home/home_repository.dart';
import 'package:arttrip/features/home/home_repository_hybrid.dart';
import 'package:arttrip/features/home/home_repository_mock.dart';
import 'package:arttrip/features/home/home_viewmodel.dart';
import 'package:arttrip/features/onboarding/data/keywords_repository.dart';
import 'package:arttrip/features/onboarding/data/keywords_repository_mock.dart';
import 'package:arttrip/features/onboarding/viewmodels/keywords_viewmodel.dart';
import 'package:arttrip/shared/viewmodels/alert_viewmodel.dart';
import 'package:provider/provider.dart';

final getProviders = [
  ChangeNotifierProvider(create: (_) => AlertViewModel()),
  ChangeNotifierProvider(
    create:
        (_) => ExhibitViewModel(
          ExhibitRepositoryHybrid(
            mock: ExhibitRepositoryMockImpl(),
            api: ExhibitRepositoryImpl(DioClient.instance),
          ),
        ),
  ),
  ChangeNotifierProxyProvider<ExhibitViewModel, HomeViewModel>(
    create:
        (context) => HomeViewModel(
          exhibitVM: context.read<ExhibitViewModel>(),
          homeRepository: HomeRepositoryHybrid(
            mock: HomeRepositoryMockImpl(),
            api: HomeRepositoryImpl(DioClient.instance),
          ),
        ),
    update: (_, __, homeVM) => homeVM!,
  ),
  ChangeNotifierProvider<KeywordModelsViewModel>(
    create:
        (_) => KeywordModelsViewModel(
          AppConsts.useMock
              ? KeywordModelsRepositoryMockImpl()
              : KeywordModelsRepositoryImpl(DioClient.instance),
        ),
  ),
  ChangeNotifierProvider<ExhibitDetailModelViewModel>(
    create:
        (_) => ExhibitDetailModelViewModel(
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
