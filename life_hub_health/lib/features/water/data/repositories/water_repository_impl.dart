import '../../../../shared/models/water_log.dart';
import '../../../../shared/services/api_service.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/repositories/water_repository.dart';

class WaterRepositoryImpl implements IWaterRepository {
  final ApiService _apiService;

  WaterRepositoryImpl(this._apiService);

  @override
  Future<List<WaterLog>> getTodayLogs() async {
    final today = AppDateUtils.formatDate(DateTime.now());
    final response = await _apiService.get('/health/water-logs/date/$today');
    if (response.statusCode == 200 && response.data['success'] == true) {
      final data = response.data['data'];
      if (data != null && data is List) {
        return data.map((e) => WaterLog.fromJson(e)).toList();
      }
      return [];
    }
    throw Exception(response.data['message'] ?? '获取饮水记录失败');
  }

  @override
  Future<int> getTodayTotal() async {
    final logs = await getTodayLogs();
    return logs.fold<int>(0, (sum, log) => sum + log.amountMl);
  }

  @override
  Future<WaterLog> addWater({required int amountMl, String? drinkType}) async {
    final response = await _apiService.post('/health/water-logs', data: {
      'recordTime': DateTime.now().toIso8601String().split('.')[0],
      'amountMl': amountMl,
      'drinkType': drinkType ?? 'water',
    });
    if (response.statusCode == 200 && response.data['success'] == true) {
      return WaterLog.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? '记录饮水失败');
  }
}
