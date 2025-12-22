import 'package:arttrip/core/app_consts.dart';
import 'package:arttrip/features/exhibit/data/exhibit_repository.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_detail.dart';

class ExhibitRepositoryHybrid implements ExhibitRepository {
  ExhibitRepositoryHybrid({required this.mock, required this.api});

  final ExhibitRepository mock;
  final ExhibitRepositoryImpl api;

  @override
  Future<ExhibitDetail?> fetchExhibitDetail(int exhibitId) {
    if (AppConsts.useMock) {
      return mock.fetchExhibitDetail(exhibitId);
    }
    return api.fetchExhibitDetail(exhibitId);
  }

  @override
  Future<void> updateFavoriteExhibit(int exhibitId, bool isFavorite) {
    // if (AppConsts.useMock) {
    //   return mock.updateFavoriteExhibit(exhibitId, isFavorite);
    // }
    return api.updateFavoriteExhibit(exhibitId, isFavorite);
  }
}
