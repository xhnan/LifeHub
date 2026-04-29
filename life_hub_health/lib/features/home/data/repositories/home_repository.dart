import '../../../../shared/models/daily_summary.dart';
import '../../../../shared/models/weight_log.dart';
import '../../../../shared/services/api_service.dart';

class HomeRepository {
  final ApiService _apiService;

  HomeRepository(this._apiService);

  Future<DailySummary?> getTodaySummary() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final response = await _apiService.get('/health/daily-summaries/date/$today');

    if (response.statusCode == 200 && response.data['success'] == true) {
      if (response.data['data'] != null) {
        return DailySummary.fromJson(response.data['data']);
      }
      return null;
    }
    throw Exception(response.data['message'] ?? '获取今日汇总失败');
  }

  Future<WeightLog?> getLatestWeight() async {
    final response = await _apiService.get('/health/weight-logs/latest');

    if (response.statusCode == 200 && response.data['success'] == true) {
      if (response.data['data'] != null) {
        return WeightLog.fromJson(response.data['data']);
      }
      return null;
    }
    throw Exception(response.data['message'] ?? '获取最新体重失败');
  }
}
