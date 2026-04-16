import 'package:arttrip/core/app_consts.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_model.dart';
import 'package:arttrip/features/home/data/models/curation_model.dart';
import 'package:arttrip/features/home/home_repository.dart';
import 'package:arttrip/shared/models/region_model.dart';

class HomeRepositoryHybrid implements HomeRepository {
  HomeRepositoryHybrid({required this.mock, required this.api});

  final HomeRepository mock;
  final HomeRepositoryImpl api;

  @override
  Future<List<String>> fetchOverseasCountries() {
    if (AppConsts.useMock) {
      return mock.fetchOverseasCountries();
    }
    return api.fetchOverseasCountries();
  }

  @override
  Future<List<RegionModel>> fetchDomesticRegions() {
    if (AppConsts.useMock) {
      return mock.fetchDomesticRegions();
    }
    return api.fetchDomesticRegions();
  }

  @override
  Future<List<ExhibitModel>> fetchTodayExhibitRecommendations({
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
  Future<List<String>> fetchGenres() {
    if (AppConsts.useMock) {
      return mock.fetchGenres();
    }
    return api.fetchGenres();
  }

  @override
  Future<List<ExhibitModel>> fetchExhibitsByGenre({
    required bool isDomestic,
    String? country,
    String? region,
    required String genre,
  }) {
    if (AppConsts.useMock) {
      return mock.fetchExhibitsByGenre(
        isDomestic: isDomestic,
        country: country,
        region: region,
        genre: genre,
      );
    }
    return api.fetchExhibitsByGenre(
      isDomestic: isDomestic,
      country: country,
      region: region,
      genre: genre,
    );
  }

  @override
  Future<List<ExhibitModel>> fetchPersonalizedExhibits({
    required bool isDomestic,
    String? country,
    String? region,
  }) {
    if (AppConsts.useMock) {
      return mock.fetchPersonalizedExhibits(
        isDomestic: isDomestic,
        country: country,
        region: region,
      );
    }
    return api.fetchPersonalizedExhibits(
      isDomestic: isDomestic,
      country: country,
      region: region,
    );
  }

  @override
  Future<List<ExhibitModel>> fetchWeeklyExhibitsBySelectedDate({
    required bool isDomestic,
    String? country,
    String? region,
    required String date,
  }) {
    if (AppConsts.useMock) {
      return mock.fetchWeeklyExhibitsBySelectedDate(
        isDomestic: isDomestic,
        country: country,
        region: region,
        date: date,
      );
    }
    return api.fetchWeeklyExhibitsBySelectedDate(
      isDomestic: isDomestic,
      country: country,
      region: region,
      date: date,
    );
  }

  @override
  Future<CurationModel> fetchCurations({
    required bool isDomestic,
    String? country,
    String? region,
  }) {
    if (AppConsts.useMock) {
      return mock.fetchCurations(
        isDomestic: isDomestic,
        country: country,
        region: region,
      );
    }
    return api.fetchCurations(
      isDomestic: isDomestic,
      country: country,
      region: region,
    );
  }
}
