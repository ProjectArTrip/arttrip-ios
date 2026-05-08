import 'package:arttrip/core/app_utils.dart';
import 'package:arttrip/core/network/dio_client.dart';
import 'package:arttrip/features/alert/alert_detail_model.dart';

abstract class AlertRepository {
  /// 알림 목록 조회
  Future<AlertDetailModel> fetchAlerts({
    required int? cursor,
    required int size,
  });

  /// 알림 전체 읽음 처리
  Future<void> markAllAsRead();

  /// 안읽음 알림 여부 조회
  Future<bool> fetchUnreadAlerts();
}

class AlertRepositoryImpl implements AlertRepository {
  AlertRepositoryImpl(this._dio);
  final DioClient _dio;

  @override
  Future<AlertDetailModel> fetchAlerts({
    required int? cursor,
    required int size,
  }) async {
    try {
      final response = await _dio.get(
        '/notifications',
        queryParameters: {'cursor': cursor, 'size': size},
      );
      final data = response.dataOrNull;
      if (data == null) throw Exception('No data');

      return AlertDetailModel.fromJson(data);
    } catch (e) {
      AppUtil.debugLog('fetchAlerts: $e');
      rethrow;
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await _dio.post('/notifications/read-all');
    } catch (e) {
      AppUtil.debugLog('markAllAsRead: $e');
      rethrow;
    }
  }

  @override
  Future<bool> fetchUnreadAlerts() async {
    try {
      final response = await _dio.get('/notifications/read-status');
      final data = response.dataOrNull;
      if (data == null) throw Exception('No data');

      return data['hasUnread'] as bool;
    } catch (e) {
      AppUtil.debugLog('fetchUnreadAlerts: $e');
      rethrow;
    }
  }
}
