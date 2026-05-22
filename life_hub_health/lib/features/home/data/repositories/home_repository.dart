import '../../../../shared/models/daily_summary.dart';
import '../../../../shared/models/weight_log.dart';
import '../../../../shared/models/daily_mood.dart';
import '../../../../shared/models/agent_models.dart';
import '../../../../shared/services/api_service.dart';
import '../../../../shared/services/offline_cache_service.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/repositories/home_repository.dart';

class HomeRepository implements IHomeRepository {
  final ApiService _apiService;
  final OfflineCacheService _cache;

  HomeRepository(this._apiService, this._cache);

  @override
  Future<DailySummary?> getTodaySummary() async {
    final today = AppDateUtils.formatDate(DateTime.now());
    final key = OfflineCacheService.cacheKey('/health/daily-summaries/date/$today');

    final response = await _apiService.get('/health/daily-summaries/date/$today');
    if (response.statusCode == 200 && response.data['success'] == true) {
      final data = response.data['data'];
      if (data != null) {
        await _cache.cacheResponse(key, data, ttl: Duration(minutes: 5));
        return DailySummary.fromJson(data);
      }
      return null;
    }

    // 网络失败时尝试缓存
    final cached = _cache.getCachedResponse(key);
    if (cached != null) return DailySummary.fromJson(cached);
    throw Exception(response.data['message'] ?? '获取今日汇总失败');
  }

  @override
  Future<WeightLog?> getLatestWeight() async {
    const key = '/health/weight-logs/latest';

    try {
      final response = await _apiService.get(key);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data != null) {
          await _cache.cacheResponse(key, data, ttl: Duration(minutes: 30));
          return WeightLog.fromJson(data);
        }
        return null;
      }
    } catch (_) {}

    final cached = _cache.getCachedResponse(key);
    if (cached != null) return WeightLog.fromJson(cached);
    return null;
  }

  @override
  Future<List<WeightLog>> getWeightTrend(int days) async {
    final now = DateTime.now();
    final startDate = AppDateUtils.formatDate(now.subtract(Duration(days: days)));
    final endDate = AppDateUtils.formatDate(now);
    final key = OfflineCacheService.cacheKey('/health/weight-logs/range', params: {'startDate': startDate, 'endDate': endDate});

    try {
      final response = await _apiService.get(
        '/health/weight-logs/range',
        queryParameters: {'startDate': startDate, 'endDate': endDate},
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data != null && data is List) {
          await _cache.cacheResponse(key, data, ttl: Duration(minutes: 15));
          return data.map((e) => WeightLog.fromJson(e)).toList();
        }
        return [];
      }
    } catch (_) {}

    final cached = _cache.getCachedResponse(key);
    if (cached != null && cached is List) {
      return cached.map((e) => WeightLog.fromJson(e)).toList();
    }
    return [];
  }

  @override
  Future<List<DailyMood>> getMoodTrend(int days) async {
    final now = DateTime.now();
    final startDate = AppDateUtils.formatDate(now.subtract(Duration(days: days)));
    final endDate = AppDateUtils.formatDate(now);
    final key = OfflineCacheService.cacheKey('/health/psychology/daily-moods/range', params: {'startDate': startDate, 'endDate': endDate});

    try {
      final response = await _apiService.get(
        '/health/psychology/daily-moods/range',
        queryParameters: {'startDate': startDate, 'endDate': endDate},
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data != null && data is List) {
          await _cache.cacheResponse(key, data, ttl: Duration(minutes: 15));
          return data.map((e) => DailyMood.fromJson(e)).toList();
        }
        return [];
      }
    } catch (_) {}

    final cached = _cache.getCachedResponse(key);
    if (cached != null && cached is List) {
      return cached.map((e) => DailyMood.fromJson(e)).toList();
    }
    return [];
  }

  @override
  Future<List<AdviceRecord>> getActiveAdvice() async {
    const key = '/health/agent/advice-records/my?activeOnly=true';

    try {
      final response = await _apiService.get(
        '/health/agent/advice-records/my',
        queryParameters: {'activeOnly': 'true'},
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data != null && data is List) {
          await _cache.cacheResponse(key, data, ttl: Duration(minutes: 10));
          return data.map((e) => AdviceRecord.fromJson(e)).toList();
        }
        return [];
      }
    } catch (_) {}

    final cached = _cache.getCachedResponse(key);
    if (cached != null && cached is List) {
      return cached.map((e) => AdviceRecord.fromJson(e)).toList();
    }
    return [];
  }

  @override
  Future<List<Checkin>> getTodayCheckins() async {
    const key = '/health/agent/checkins/my';

    try {
      final response = await _apiService.get(key);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data != null && data is List) {
          final today = DateTime.now();
          final todayCheckins = data
              .map((e) => Checkin.fromJson(e))
              .where((c) =>
                  c.checkinDate.year == today.year &&
                  c.checkinDate.month == today.month &&
                  c.checkinDate.day == today.day)
              .toList();
          return todayCheckins;
        }
        return [];
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<List<FollowupPlan>> getActivePlans() async {
    const key = '/health/agent/followup-plans/my?activeOnly=true';

    try {
      final response = await _apiService.get(
        '/health/agent/followup-plans/my',
        queryParameters: {'activeOnly': 'true'},
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data != null && data is List) {
          await _cache.cacheResponse(key, data, ttl: Duration(minutes: 10));
          return data.map((e) => FollowupPlan.fromJson(e)).toList();
        }
        return [];
      }
    } catch (_) {}

    final cached = _cache.getCachedResponse(key);
    if (cached != null && cached is List) {
      return cached.map((e) => FollowupPlan.fromJson(e)).toList();
    }
    return [];
  }

  @override
  Future<DailyMood?> getLatestMood() async {
    const key = '/health/psychology/daily-moods/latest';

    try {
      final response = await _apiService.get(key);
      if (response.statusCode == 200 && response.data['success'] == true) {
        if (response.data['data'] != null) {
          await _cache.cacheResponse(key, response.data['data'], ttl: Duration(minutes: 10));
          return DailyMood.fromJson(response.data['data']);
        }
        return null;
      }
    } catch (_) {}

    final cached = _cache.getCachedResponse(key);
    if (cached != null) return DailyMood.fromJson(cached);
    return null;
  }
}
