import 'package:arttrip/features/home/home_repository.dart';
import 'package:arttrip/shared/models/region_model.dart';
import 'package:flutter/material.dart';

class HomeViewModel with ChangeNotifier {
  HomeViewModel(this.repository);
  final HomeRepository repository;

  bool _isDomestic = true;
  RegionModel? _selectedRegion;

  bool get isDomestic => _isDomestic;
  RegionModel? get selectedRegion => _selectedRegion;

  set isDomestic(bool value) {
    _isDomestic = value;
    notifyListeners();
  }

  void updateSelectedRegion(RegionModel region) {
    _selectedRegion = region;
    notifyListeners();
  }

  Future<List<RegionModel>?> fetchOverseasCountries() {
    var overseasCountries = repository.fetchOverseasCountries();
    overseasCountries.then((value) {
      if (value?.isNotEmpty == true) updateSelectedRegion(value!.first);
    });
    return overseasCountries;
  }

  Future<List<RegionModel>?> fetchDomesticRegions() {
    return repository.fetchDomesticRegions();
  }
}
