import 'package:arttrip/core/app_utils.dart';
import 'package:arttrip/features/alert/alert_detail_model.dart';
import 'package:arttrip/features/alert/alert_repository.dart';
import 'package:flutter/material.dart';

class AlertViewModel with ChangeNotifier {
  AlertViewModel(this._repository);

  final AlertRepository _repository;

  bool _hasUnread = false;

  bool get hasUnread => _hasUnread;

  set hasUnread(bool hasUnread) {
    _hasUnread = hasUnread;
    notifyListeners();
  }

  Future<AlertDetailModel?> getAlerts({int? cursor, int size = 10}) async {
    try {
      return await _repository.fetchAlerts(cursor: cursor, size: size);
    } catch (e) {
      AppUtil.debugLog('getAlerts error: $e');
      return null;
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      hasUnread = false; // 모든 알림을 읽음 처리했으므로 카운트 초기화
    } catch (e) {
      AppUtil.debugLog('markAllAsRead error: $e');
    }
  }

  Future<void> getUnreadAlerts() async {
    try {
      final count = await _repository.fetchUnreadAlerts();
      hasUnread = count ?? false;
    } catch (e) {
      AppUtil.debugLog('getUnreadAlerts error: $e');
    }
  }
}
