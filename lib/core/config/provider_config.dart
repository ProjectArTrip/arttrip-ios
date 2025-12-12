import 'package:arttrip/core/app_consts.dart';
import 'package:arttrip/core/network/network.dart';
import 'package:arttrip/features/home/home_repository.dart';
import 'package:arttrip/features/home/home_repository_mock.dart';
import 'package:arttrip/features/home/home_viewmodel.dart';
import 'package:provider/provider.dart';

List<ChangeNotifierProvider> getProviders() {
  return [
    ChangeNotifierProvider<HomeViewModel>(
      create: (_) =>
          HomeViewModel(AppConsts.useMock ? HomeRepositoryMockImpl() : HomeRepositoryImpl(DioClient.instance)),
    ),
  ];
}
