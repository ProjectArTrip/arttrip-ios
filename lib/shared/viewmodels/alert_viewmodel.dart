import 'package:flutter/material.dart';

class AlertViewModel with ChangeNotifier {
  int _unreadCount = 0;

  int get unreadCount => _unreadCount;
  bool get hasUnread => _unreadCount > 0;

  set unreadCount(int count) {
    _unreadCount = count;
    notifyListeners();
  }

  Future<void> fetchAlerts() async {
    // TODO: 알림 리스트 API 연동
    _unreadCount = 0;
    notifyListeners();
  }
}
