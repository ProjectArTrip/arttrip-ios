import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/home/home_repository.dart';
import 'package:arttrip/shared/models/exhibit_model.dart';
import 'package:arttrip/shared/widgets/async_view.dart';
import 'package:flutter/material.dart';

class HomeViewModel with ChangeNotifier {
  HomeViewModel(this.repository);
  final HomeRepository repository;

  AsyncState<List<String>> locations = const AsyncState.loading();
  AsyncState<List<ExhibitModel>> todayExhibitRecommendations = const AsyncState.loading();
  AsyncState<List<String>> genres = const AsyncState.loading();

  bool _isDomestic = false;
  late String _selectedLocation;
  late String _selectedGenre;

  bool get isDomestic => _isDomestic;
  String get selectedLocation => _selectedLocation;
  String get selectedGenre => _selectedGenre;

  set isDomestic(bool value) {
    _isDomestic = value;
    notifyListeners();
  }

  set selectedLocation(String region) {
    _selectedLocation = region;
    notifyListeners();
  }

  set selectedGenre(String genre) {
    _selectedGenre = genre;
    notifyListeners();
  }

  void load(BuildContext context) {
    fetchOverseasCountries(context);
    fetchTodayExhibitRecommendations();
    fetchGenres();
  }

  Future<void> fetchOverseasCountries(BuildContext context) async {
    locations = const AsyncState.loading();
    notifyListeners();

    var result = await repository.fetchOverseasCountries();
    if (result == null || context.mounted == false) {
      locations = const AsyncState.error();
    } else {
      result = [context.l10n.allItems, ...result];
      _selectedLocation = context.l10n.allItems;
      locations = AsyncState.success(result);
    }
    notifyListeners();
  }

  Future<void> fetchDomesticRegions() async {
    locations = const AsyncState.loading();
    notifyListeners();

    var result = await repository.fetchDomesticRegions();
    if (result == null) {
      locations = const AsyncState.error();
    } else {
      if (result.isNotEmpty) _selectedLocation = result[0];
      locations = AsyncState.success(result);
    }
    notifyListeners();
  }

  Future<void> fetchTodayExhibitRecommendations() async {
    todayExhibitRecommendations = const AsyncState.loading();
    notifyListeners();

    var result = await repository.fetchTodayExhibitRecommendations(
      isDomestic: _isDomestic,
      country: _isDomestic ? null : _selectedLocation,
      region: _isDomestic ? _selectedLocation : null,
    );
    if (result == null) {
      todayExhibitRecommendations = const AsyncState.error();
    } else {
      todayExhibitRecommendations = AsyncState.success(result);
    }
    notifyListeners();
  }

  Future<void> fetchGenres() async {
    genres = const AsyncState.loading();
    notifyListeners();

    var result = await repository.fetchGenres();
    if (result == null) {
      genres = const AsyncState.error();
    } else {
      genres = AsyncState.success(result);
      _selectedGenre = result.first;
    }
    notifyListeners();
  }
}
