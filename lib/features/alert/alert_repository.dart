import 'package:arttrip/core/app_utils.dart';
import 'package:arttrip/core/network/dio_client.dart';
import 'package:arttrip/features/alert/alert_detail_model.dart';

abstract class AlertRepository {
  Future<AlertDetailModel> fetchAlerts({
    required int cursor,
    required int size,
  });
}

class AlertRepositoryImpl implements AlertRepository {
  AlertRepositoryImpl(this._dio);
  final DioClient _dio;

  @override
  Future<AlertDetailModel> fetchAlerts({
    required int cursor,
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
}
