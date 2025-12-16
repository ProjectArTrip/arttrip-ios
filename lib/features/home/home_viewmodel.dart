import 'package:arttrip/features/home/home_repository.dart';
import 'package:flutter/material.dart';

class HomeViewModel with ChangeNotifier {
  HomeViewModel(this.repository);
  final HomeRepository repository;

  bool _isDomestic = true;
  String? _selectedRegion;

  bool get isDomestic => _isDomestic;
  String? get selectedRegion => _selectedRegion;

  set isDomestic(bool value) {
    _isDomestic = value;
    notifyListeners();
  }

  void updateSelectedRegion(String region) {
    _selectedRegion = region;
    notifyListeners();
  }

  Future<List<String>?> fetchOverseasCountries() {
    var overseasCountries = repository.fetchOverseasCountries();
    overseasCountries.then((value) {
      if (value?.isNotEmpty == true) updateSelectedRegion(value!.first);
    });
    return overseasCountries;
  }

  Future<List<String>?> fetchDomesticRegions() {
    return repository.fetchDomesticRegions();
  }
}
