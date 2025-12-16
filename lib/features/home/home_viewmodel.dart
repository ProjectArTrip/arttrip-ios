import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/home/home_repository.dart';
import 'package:arttrip/shared/models/exhibit_model.dart';
import 'package:arttrip/shared/widgets/async_view.dart';
import 'package:flutter/material.dart';

class HomeViewModel with ChangeNotifier {
  HomeViewModel(this.repository);
  final HomeRepository repository;

  AsyncState<List<String>?> regions = const AsyncState.loading();
  AsyncState<List<ExhibitModel>?> todayExhibitRecommendations = const AsyncState.loading();

  bool _isDomestic = false;
  late String _selectedRegion;

  bool get isDomestic => _isDomestic;
  String get selectedRegion => _selectedRegion;

  set isDomestic(bool value) {
    _isDomestic = value;
    notifyListeners();
  }

  void load(BuildContext context) {
    fetchOverseasCountries(context);
    fetchTodayExhibitRecommendations();
  }

  set selectedRegion(String region) {
    _selectedRegion = region;
    notifyListeners();
  }

  Future<void> fetchOverseasCountries(BuildContext context) async {
    regions = const AsyncState.loading();
    notifyListeners();

    var result = await repository.fetchOverseasCountries();
    if (result == null || context.mounted == false) {
      regions = const AsyncState.error();
    } else {
      result = [context.l10n.allItems, ...result];
      _selectedRegion = context.l10n.allItems;
      regions = AsyncState.success(result);
    }
    notifyListeners();
  }

  Future<void> fetchDomesticRegions() async {
    regions = const AsyncState.loading();
    notifyListeners();

    var result = await repository.fetchDomesticRegions();
    if (result == null) {
      regions = const AsyncState.error();
    } else {
      if (result.isNotEmpty) _selectedRegion = result[0];
      regions = AsyncState.success(result);
    }
    notifyListeners();
  }

  Future<void> fetchTodayExhibitRecommendations() async {
    todayExhibitRecommendations = const AsyncState.loading();
    notifyListeners();

    var result = await repository.fetchTodayExhibitRecommendations(
      isDomestic: _isDomestic,
      country: _isDomestic ? null : _selectedRegion,
      region: _isDomestic ? _selectedRegion : null,
    );
    if (result == null) {
      todayExhibitRecommendations = const AsyncState.error();
    } else {
      todayExhibitRecommendations = AsyncState.success(result);
    }
    notifyListeners();
  }
}
