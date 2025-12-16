import 'package:arttrip/core/app_consts.dart';
import 'package:arttrip/features/home/home_repository.dart';
import 'package:arttrip/shared/models/exhibit_model.dart';

class HybridHomeRepository implements HomeRepository {
  HybridHomeRepository({required this.mock, required this.api});

  final HomeRepository mock;
  final HomeRepositoryImpl api;

  @override
  Future<List<String>?> fetchOverseasCountries() {
    if (AppConsts.useMock) {
      return mock.fetchOverseasCountries();
    }
    return api.fetchOverseasCountries();
  }

  @override
  Future<List<String>?> fetchDomesticRegions() {
    if (AppConsts.useMock) {
      return mock.fetchDomesticRegions();
    }
    return api.fetchDomesticRegions();
  }

  @override
  Future<List<ExhibitModel>?> fetchTodayExhibitRecommendations({
    required bool isDomestic,
    String? country,
    String? region,
  }) {
    if (AppConsts.useMock) {
      return mock.fetchTodayExhibitRecommendations(isDomestic: isDomestic);
    }
    return api.fetchTodayExhibitRecommendations(isDomestic: isDomestic, country: country, region: region);
  }
}
