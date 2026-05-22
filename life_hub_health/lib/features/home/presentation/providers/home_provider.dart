import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../shared/models/daily_summary.dart';
import '../../../../shared/models/weight_log.dart';
import '../../../../shared/models/daily_mood.dart';
import '../../../../shared/models/agent_models.dart';
import '../../../../shared/providers/providers.dart';
import '../../domain/repositories/home_repository.dart';
import '../../data/repositories/home_repository.dart';

final homeRepositoryProvider = Provider<IHomeRepository>((ref) {
  final apiService = ref.read(apiServiceProvider);
  final cacheService = ref.read(offlineCacheServiceProvider);
  return HomeRepository(apiService, cacheService);
});

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  final repository = ref.read(homeRepositoryProvider);
  return HomeNotifier(repository);
});

const _sentinel = Object();

class HomeState {
  final bool isLoading;
  final DailySummary? todaySummary;
  final WeightLog? latestWeight;
  final List<WeightLog> weightTrend;
  final List<DailyMood> moodTrend;
  final List<AdviceRecord> activeAdvice;
  final List<Checkin> todayCheckins;
  final List<FollowupPlan> activePlans;
  final DailyMood? latestMood;
  final String? error;

  HomeState({
    this.isLoading = false,
    this.todaySummary,
    this.latestWeight,
    this.weightTrend = const [],
    this.moodTrend = const [],
    this.activeAdvice = const [],
    this.todayCheckins = const [],
    this.activePlans = const [],
    this.latestMood,
    this.error,
  });

  /// 今日打卡完成率
  double get checkinCompletionRate {
    if (activePlans.isEmpty) return 0;
    if (todayCheckins.isEmpty) return 0;
    final completed = todayCheckins.where((c) => c.completionStatus == 'completed').length;
    return completed / activePlans.length;
  }

  /// 是否今日已记录心情
  bool get hasMoodToday {
    if (latestMood == null) return false;
    final now = DateTime.now();
    return latestMood!.recordDate.year == now.year &&
        latestMood!.recordDate.month == now.month &&
        latestMood!.recordDate.day == now.day;
  }

  HomeState copyWith({
    bool? isLoading,
    Object? todaySummary = _sentinel,
    Object? latestWeight = _sentinel,
    List<WeightLog>? weightTrend,
    List<DailyMood>? moodTrend,
    List<AdviceRecord>? activeAdvice,
    List<Checkin>? todayCheckins,
    List<FollowupPlan>? activePlans,
    Object? latestMood = _sentinel,
    String? error,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      todaySummary: todaySummary == _sentinel ? this.todaySummary : todaySummary as DailySummary?,
      latestWeight: latestWeight == _sentinel ? this.latestWeight : latestWeight as WeightLog?,
      weightTrend: weightTrend ?? this.weightTrend,
      moodTrend: moodTrend ?? this.moodTrend,
      activeAdvice: activeAdvice ?? this.activeAdvice,
      todayCheckins: todayCheckins ?? this.todayCheckins,
      activePlans: activePlans ?? this.activePlans,
      latestMood: latestMood == _sentinel ? this.latestMood : latestMood as DailyMood?,
      error: error,
    );
  }
}

class HomeNotifier extends StateNotifier<HomeState> {
  final IHomeRepository _repository;

  HomeNotifier(this._repository) : super(HomeState()) {
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, error: null);

    // 独立容错：每个请求失败不影响其他
    final results = await Future.wait([
      _safe(() => _repository.getTodaySummary()),
      _safe(() => _repository.getLatestWeight()),
      _safe(() => _repository.getWeightTrend(7)),
      _safe(() => _repository.getMoodTrend(7)),
      _safe(() => _repository.getActiveAdvice()),
      _safe(() => _repository.getTodayCheckins()),
      _safe(() => _repository.getActivePlans()),
      _safe(() => _repository.getLatestMood()),
    ]);

    state = state.copyWith(
      isLoading: false,
      todaySummary: results[0] as DailySummary?,
      latestWeight: results[1] as WeightLog?,
      weightTrend: (results[2] as List<WeightLog>?) ?? [],
      moodTrend: (results[3] as List<DailyMood>?) ?? [],
      activeAdvice: (results[4] as List<AdviceRecord>?) ?? [],
      todayCheckins: (results[5] as List<Checkin>?) ?? [],
      activePlans: (results[6] as List<FollowupPlan>?) ?? [],
      latestMood: results[7] as DailyMood?,
    );
  }

  /// 包装异步调用，失败时返回 null 而非抛异常
  Future<T?> _safe<T>(Future<T> Function() fn) async {
    try {
      return await fn();
    } catch (_) {
      return null;
    }
  }
}
