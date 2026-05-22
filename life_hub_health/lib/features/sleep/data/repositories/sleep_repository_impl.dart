import '../../../../shared/models/sleep_log.dart';
import '../../../../shared/services/api_service.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/repositories/sleep_repository.dart';

class SleepRepositoryImpl implements ISleepRepository {
  final ApiService _apiService;

  SleepRepositoryImpl(this._apiService);

  @override
  Future<List<SleepLog>> getMySleepLogs() async {
    final response = await _apiService.get('/health/sleep-logs/my');
    if (response.statusCode == 200 && response.data['success'] == true) {
      final data = response.data['data'];
      if (data != null && data is List) {
        return data.map((e) => SleepLog.fromJson(e)).toList();
      }
      return [];
    }
    throw Exception(response.data['message'] ?? '获取睡眠记录失败');
  }

  @override
  Future<List<SleepLog>> getSleepLogsByRange(DateTime startDate, DateTime endDate) async {
    final response = await _apiService.get(
      '/health/sleep-logs/range',
      queryParameters: {
        'startDate': AppDateUtils.formatDate(startDate),
        'endDate': AppDateUtils.formatDate(endDate),
      },
    );
    if (response.statusCode == 200 && response.data['success'] == true) {
      final data = response.data['data'];
      if (data != null && data is List) {
        return data.map((e) => SleepLog.fromJson(e)).toList();
      }
      return [];
    }
    throw Exception(response.data['message'] ?? '获取睡眠记录失败');
  }

  @override
  Future<SleepLog?> getLatestSleepLog() async {
    final response = await _apiService.get('/health/sleep-logs/latest');
    if (response.statusCode == 200 && response.data['success'] == true) {
      if (response.data['data'] != null) {
        return SleepLog.fromJson(response.data['data']);
      }
      return null;
    }
    throw Exception(response.data['message'] ?? '获取最新睡眠记录失败');
  }

  @override
  Future<SleepLog> createSleepLog({
    required DateTime sleepDate,
    DateTime? bedTime,
    DateTime? wakeTime,
    int? durationMinutes,
    int? qualityScore,
    int? deepSleepMinutes,
    int? lightSleepMinutes,
    int? awakeMinutes,
    String? notes,
  }) async {
    final body = <String, dynamic>{
      'sleepDate': AppDateUtils.formatDate(sleepDate),
    };
    if (bedTime != null) body['bedTime'] = bedTime.toIso8601String().split('.')[0];
    if (wakeTime != null) body['wakeTime'] = wakeTime.toIso8601String().split('.')[0];
    if (durationMinutes != null) body['durationMinutes'] = durationMinutes;
    if (qualityScore != null) body['qualityScore'] = qualityScore;
    if (deepSleepMinutes != null) body['deepSleepMinutes'] = deepSleepMinutes;
    if (lightSleepMinutes != null) body['lightSleepMinutes'] = lightSleepMinutes;
    if (awakeMinutes != null) body['awakeMinutes'] = awakeMinutes;
    if (notes != null) body['notes'] = notes;

    final response = await _apiService.post('/health/sleep-logs', data: body);
    if (response.statusCode == 200 && response.data['success'] == true) {
      return SleepLog.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? '创建睡眠记录失败');
  }
}
