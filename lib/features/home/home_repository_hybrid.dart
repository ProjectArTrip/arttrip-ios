import 'package:arttrip/core/app_consts.dart';
import 'package:arttrip/features/home/home_repository.dart';
import 'package:arttrip/shared/models/exhibit_model.dart';

class HomeRepositoryHybrid implements HomeRepository {
  HomeRepositoryHybrid({required this.mock, required this.api});

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
    return api.fetchTodayExhibitRecommendations(
      isDomestic: isDomestic,
      country: country,
      region: region,
    );
  }

  @override
  Future<List<String>?> fetchGenres() {
    if (AppConsts.useMock) {
      return mock.fetchGenres();
    }
    return api.fetchGenres();
  }

  @override
  Future<List<ExhibitModel>?> fetchExhibitionsByGenre({
    required bool isDomestic,
    String? country,
    String? region,
    required String genre,
  }) {
    if (AppConsts.useMock) {
      return mock.fetchExhibitionsByGenre(
        isDomestic: isDomestic,
        country: country,
        region: region,
        genre: genre,
      );
    }
    return api.fetchExhibitionsByGenre(
      isDomestic: isDomestic,
      country: country,
      region: region,
      genre: genre,
    );
  }
}
