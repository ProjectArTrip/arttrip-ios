import 'package:arttrip/core/api_endpoints.dart';
import 'package:arttrip/core/app_utils.dart';
import 'package:arttrip/core/network/dio_client.dart';
import 'package:arttrip/core/network/network.dart';
import 'package:arttrip/features/splash/data/maintenance_model.dart';

abstract class MaintenanceRepository {
  Future<MaintenanceModel?> fetchMaintenanceStatus();
}

class MaintenanceRepositoryImpl implements MaintenanceRepository {
  MaintenanceRepositoryImpl(this._dio);
  final DioClient _dio;

  @override
  Future<MaintenanceModel?> fetchMaintenanceStatus() async {
    try {
      final response = await _dio.get(ApiEndpoints.maintenance);
      final data = response.dataOrNull;
      if (data == null) return null;

      return MaintenanceModel.fromJson(data);
    } catch (e) {
      AppUtil.debugLog('fetchMaintenanceStatus: $e');
    }
    return null;
  }
}
