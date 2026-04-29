import '../../../../shared/models/health_activity.dart';
import '../../../../shared/models/diet_log.dart';
import '../../../../shared/models/weight_log.dart';
import '../../../../shared/models/daily_summary.dart';
import '../../../../shared/services/api_service.dart';
import '../../domain/repositories/health_data_repository.dart';

class HealthDataRepository implements IHealthDataRepository {
  final ApiService _apiService;

  HealthDataRepository(this._apiService);

  @override
  Future<List<HealthActivity>> getActivities({String? activityType}) async {
    final queryParams = <String, dynamic>{};
    if (activityType != null) queryParams['activityType'] = activityType;

    final response = await _apiService.get(
      '/health/activities/my',
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      final List<dynamic> data = response.data['data'];
      return data.map((json) => HealthActivity.fromJson(json)).toList();
    }
    throw Exception(response.data['message'] ?? '获取运动记录失败');
  }

  @override
  Future<bool> createActivity({
    required String activityType,
    DateTime? startTime,
    required int durationMinutes,
    double? caloriesBurned,
    String? description,
  }) async {
    final response = await _apiService.post(
      '/health/activities',
      data: {
        'activityType': activityType,
        'startTime': startTime?.toIso8601String(),
        'durationMinutes': durationMinutes,
        'caloriesBurned': caloriesBurned,
        'description': description,
      },
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return true;
    }
    throw Exception(response.data['message'] ?? '添加运动记录失败');
  }

  @override
  Future<List<DietLog>> getDietLogs({String? mealType}) async {
    final queryParams = <String, dynamic>{};
    if (mealType != null) queryParams['mealType'] = mealType;

    final response = await _apiService.get(
      '/health/diet-logs/my',
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      final List<dynamic> data = response.data['data'];
      return data.map((json) => DietLog.fromJson(json)).toList();
    }
    throw Exception(response.data['message'] ?? '获取饮食记录失败');
  }

  @override
  Future<List<DietLog>> getDietLogsByDate(DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];
    final response = await _apiService.get('/health/diet-logs/date/$dateStr');

    if (response.statusCode == 200 && response.data['success'] == true) {
      final List<dynamic> data = response.data['data'];
      return data.map((json) => DietLog.fromJson(json)).toList();
    }
    throw Exception(response.data['message'] ?? '获取饮食记录失败');
  }

  @override
  Future<bool> createDietLog({
    required DateTime mealTime,
    required String mealType,
    required String foodItems,
    double? totalCalories,
    double? proteinG,
    double? carbsG,
    double? fatG,
  }) async {
    final response = await _apiService.post(
      '/health/diet-logs',
      data: {
        'mealTime': mealTime.toIso8601String(),
        'mealType': mealType,
        'foodItems': foodItems,
        'totalCalories': totalCalories,
        'proteinG': proteinG,
        'carbsG': carbsG,
        'fatG': fatG,
      },
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return true;
    }
    throw Exception(response.data['message'] ?? '添加饮食记录失败');
  }

  @override
  Future<List<WeightLog>> getWeightLogs() async {
    final response = await _apiService.get('/health/weight-logs/my');

    if (response.statusCode == 200 && response.data['success'] == true) {
      final List<dynamic> data = response.data['data'];
      return data.map((json) => WeightLog.fromJson(json)).toList();
    }
    throw Exception(response.data['message'] ?? '获取体重记录失败');
  }

  @override
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

  @override
  Future<List<WeightLog>> getWeightLogsByRange(DateTime start, DateTime end) async {
    final startStr = start.toIso8601String().split('T')[0];
    final endStr = end.toIso8601String().split('T')[0];
    final response = await _apiService.get(
      '/health/weight-logs/range',
      queryParameters: {'startDate': startStr, 'endDate': endStr},
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      final List<dynamic> data = response.data['data'];
      return data.map((json) => WeightLog.fromJson(json)).toList();
    }
    throw Exception(response.data['message'] ?? '获取体重记录失败');
  }

  @override
  Future<bool> createWeightLog({
    required DateTime recordDate,
    required double weightKg,
    double? bodyFatPercentage,
    double? bmi,
  }) async {
    final response = await _apiService.post(
      '/health/weight-logs',
      data: {
        'recordDate': recordDate.toIso8601String().split('T')[0],
        'weightKg': weightKg,
        'bodyFatPercentage': bodyFatPercentage,
        'bmi': bmi,
      },
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return true;
    }
    throw Exception(response.data['message'] ?? '添加体重记录失败');
  }

  @override
  Future<DailySummary?> getDailySummary(DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];
    final response = await _apiService.get('/health/daily-summaries/date/$dateStr');

    if (response.statusCode == 200 && response.data['success'] == true) {
      if (response.data['data'] != null) {
        return DailySummary.fromJson(response.data['data']);
      }
      return null;
    }
    throw Exception(response.data['message'] ?? '获取每日汇总失败');
  }

  @override
  Future<List<DailySummary>> getDailySummaries() async {
    final response = await _apiService.get('/health/daily-summaries/my');

    if (response.statusCode == 200 && response.data['success'] == true) {
      final List<dynamic> data = response.data['data'];
      return data.map((json) => DailySummary.fromJson(json)).toList();
    }
    throw Exception(response.data['message'] ?? '获取每日汇总失败');
  }

  @override
  Future<List<DailySummary>> getDailySummariesByRange(DateTime start, DateTime end) async {
    final startStr = start.toIso8601String().split('T')[0];
    final endStr = end.toIso8601String().split('T')[0];
    final response = await _apiService.get(
      '/health/daily-summaries/range',
      queryParameters: {'startDate': startStr, 'endDate': endStr},
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      final List<dynamic> data = response.data['data'];
      return data.map((json) => DailySummary.fromJson(json)).toList();
    }
    throw Exception(response.data['message'] ?? '获取每日汇总失败');
  }
}
