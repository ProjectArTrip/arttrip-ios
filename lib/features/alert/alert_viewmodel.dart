import 'package:arttrip/core/app_utils.dart';
import 'package:arttrip/features/alert/alert_detail_model.dart';
import 'package:arttrip/features/alert/alert_repository.dart';
import 'package:flutter/material.dart';

class AlertViewModel with ChangeNotifier {
  AlertViewModel(this._repository);

  final AlertRepository _repository;

  int _unreadCount = 0;

  int get unreadCount => _unreadCount;
  bool get hasUnread => _unreadCount > 0;

  set unreadCount(int count) {
    _unreadCount = count;
    notifyListeners();
  }

  Future<AlertDetailModel?> getAlerts({int cursor = 0, int size = 10}) async {
    try {
      return await _repository.fetchAlerts(cursor: cursor, size: size);
    } catch (e) {
      AppUtil.debugLog('getAlerts error: $e');
      return null;
    }
  }
}
