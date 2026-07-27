import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// 네트워크 연결 상태를 관리하는 서비스
///
/// 기능:
/// - 현재 연결 상태 확인
/// - 연결 상태 변경 스트림 제공
/// - 오프라인 모드 감지
class ConnectivityService {
  ConnectivityService._internal();

  static final ConnectivityService _instance = ConnectivityService._internal();

  /// 싱글톤 인스턴스
  static ConnectivityService get instance => _instance;

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  final _connectivityController =
      StreamController<ConnectivityStatus>.broadcast();

  /// 연결 상태 변경 스트림
  Stream<ConnectivityStatus> get onConnectivityChanged =>
      _connectivityController.stream;

  ConnectivityStatus _currentStatus = ConnectivityStatus.unknown;

  /// 현재 연결 상태
  ConnectivityStatus get currentStatus => _currentStatus;

  /// 온라인 여부
  bool get isOnline => _currentStatus != ConnectivityStatus.offline;

  /// 오프라인 여부
  bool get isOffline => _currentStatus == ConnectivityStatus.offline;

  /// 서비스 초기화
  Future<void> initialize() async {
    // 현재 상태 확인
    final results = await _connectivity.checkConnectivity();
    _updateStatus(results);

    // 상태 변경 구독
    _subscription = _connectivity.onConnectivityChanged.listen(
      _updateStatus,
      onError: (error) {
        debugPrint('ConnectivityService error: $error');
        _currentStatus = ConnectivityStatus.unknown;
        _connectivityController.add(_currentStatus);
      },
    );

    debugPrint('ConnectivityService initialized: $_currentStatus');
  }

  /// 현재 연결 상태 확인 (일회성)
  Future<ConnectivityStatus> checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    return _mapToStatus(results);
  }

  /// 연결 상태 업데이트
  void _updateStatus(List<ConnectivityResult> results) {
    final newStatus = _mapToStatus(results);

    if (newStatus != _currentStatus) {
      _currentStatus = newStatus;
      _connectivityController.add(_currentStatus);
      debugPrint('Connectivity changed: $_currentStatus');
    }
  }

  /// ConnectivityResult를 ConnectivityStatus로 변환
  ConnectivityStatus _mapToStatus(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return ConnectivityStatus.offline;
    }

    if (results.contains(ConnectivityResult.wifi)) {
      return ConnectivityStatus.wifi;
    }

    if (results.contains(ConnectivityResult.mobile)) {
      return ConnectivityStatus.mobile;
    }

    if (results.contains(ConnectivityResult.ethernet)) {
      return ConnectivityStatus.ethernet;
    }

    return ConnectivityStatus.other;
  }

  /// 서비스 정리
  void dispose() {
    _subscription?.cancel();
    _connectivityController.close();
  }
}

/// 연결 상태 enum
enum ConnectivityStatus {
  /// WiFi 연결
  wifi,

  /// 모바일 데이터 연결
  mobile,

  /// 이더넷 연결
  ethernet,

  /// 기타 연결
  other,

  /// 오프라인
  offline,

  /// 알 수 없음
  unknown;

  /// 연결됨 여부
  bool get isConnected => this != offline && this != unknown;

  /// 표시 이름
  String get displayName {
    switch (this) {
      case ConnectivityStatus.wifi:
        return 'WiFi';
      case ConnectivityStatus.mobile:
        return '모바일 데이터';
      case ConnectivityStatus.ethernet:
        return '이더넷';
      case ConnectivityStatus.other:
        return '기타';
      case ConnectivityStatus.offline:
        return '오프라인';
      case ConnectivityStatus.unknown:
        return '알 수 없음';
    }
  }
}
