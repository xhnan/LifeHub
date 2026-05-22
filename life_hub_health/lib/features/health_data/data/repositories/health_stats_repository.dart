import '../../../../shared/models/weight_log.dart';
import '../../../../shared/models/daily_summary.dart';
import '../../../../shared/models/diet_log.dart';
import '../../../../shared/services/api_service.dart';
import '../../../../core/utils/date_utils.dart';

class HealthStatsRepository {
  final ApiService _apiService;

  HealthStatsRepository(this._apiService);

  Future<List<WeightLog>> getWeightRange(int days) async {
    final now = DateTime.now();
    final start = AppDateUtils.formatDate(now.subtract(Duration(days: days)));
    final end = AppDateUtils.formatDate(now);

    final response = await _apiService.get(
      '/health/weight-logs/range',
      queryParameters: {'startDate': start, 'endDate': end},
    );
    if (response.statusCode == 200 && response.data['success'] == true) {
      final data = response.data['data'];
      if (data is List) return data.map((e) => WeightLog.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<DailySummary>> getSummaryRange(int days) async {
    final now = DateTime.now();
    final start = AppDateUtils.formatDate(now.subtract(Duration(days: days)));
    final end = AppDateUtils.formatDate(now);

    final response = await _apiService.get(
      '/health/daily-summaries/range',
      queryParameters: {'startDate': start, 'endDate': end},
    );
    if (response.statusCode == 200 && response.data['success'] == true) {
      final data = response.data['data'];
      if (data is List) return data.map((e) => DailySummary.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<DietLog>> getMyDietLogs() async {
    final response = await _apiService.get('/health/diet-logs/my');
    if (response.statusCode == 200 && response.data['success'] == true) {
      final data = response.data['data'];
      if (data is List) return data.map((e) => DietLog.fromJson(e)).toList();
    }
    return [];
  }
}
