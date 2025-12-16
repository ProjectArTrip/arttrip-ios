import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/home/home_repository.dart';
import 'package:arttrip/shared/models/exhibit_model.dart';
import 'package:arttrip/shared/widgets/async_view.dart';
import 'package:flutter/material.dart';

class HomeViewModel with ChangeNotifier {
  HomeViewModel(this.repository);
  final HomeRepository repository;

  AsyncState<List<String>?> regions = const AsyncState.loading();

  bool _isDomestic = false;
  int _selectedRegionIndex = 0;

  bool get isDomestic => _isDomestic;
  int get selectedRegionIndex => _selectedRegionIndex;

  set isDomestic(bool value) {
    _isDomestic = value;
    notifyListeners();
  }

  void load(BuildContext context) {
    fetchOverseasCountries(context);
  }

  set selectedRegionIndex(int index) {
    _selectedRegionIndex = index;
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
      _selectedRegionIndex = 0;
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
      if (result.isNotEmpty) _selectedRegionIndex = 0;
      regions = AsyncState.success(result);
    }
    notifyListeners();
  }

  Future<List<ExhibitModel>?> fetchTodayExhibitRecommendations({
    String? country,
    String? region,
  }) {
    return repository.fetchTodayExhibitRecommendations(
      isDomestic: _isDomestic,
      country: country,
      region: region,
    );
  }
}
