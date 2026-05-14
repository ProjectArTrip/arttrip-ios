import 'package:arttrip/core/app_utils.dart';
import 'package:arttrip/core/enum.dart';
import 'package:arttrip/features/splash/data/maintenance_model.dart';
import 'package:arttrip/features/splash/data/maintenance_repository.dart';
import 'package:flutter/material.dart';

class SplashViewModel with ChangeNotifier {
  SplashViewModel(this._repository);

  final MaintenanceRepository _repository;

  MaintenanceModel? _maintenance;
  bool _isLoading = false;

  MaintenanceModel? get maintenance => _maintenance;
  bool get isLoading => _isLoading;

  MaintenanceState get maintenanceState =>
      MaintenanceState.fromString(_maintenance?.state);

  Future<void> fetchMaintenanceStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      _maintenance = await _repository.fetchMaintenanceStatus();
    } catch (e) {
      AppUtil.debugLog('fetchMaintenanceStatus: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void reset() {
    _maintenance = null;
    _isLoading = false;
    notifyListeners();
  }
}
