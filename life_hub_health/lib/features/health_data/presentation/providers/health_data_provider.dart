import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../shared/models/health_activity.dart';
import '../../../../shared/models/diet_log.dart';
import '../../../../shared/models/weight_log.dart';
import '../../../../shared/models/daily_summary.dart';
import '../../../../shared/providers/providers.dart';
import '../../domain/repositories/health_data_repository.dart';
import '../../data/repositories/health_data_repository.dart';

final healthDataRepositoryProvider = Provider<IHealthDataRepository>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return HealthDataRepository(apiService);
});

final healthDataProvider = StateNotifierProvider<HealthDataNotifier, HealthDataState>((ref) {
  final repository = ref.read(healthDataRepositoryProvider);
  return HealthDataNotifier(repository);
});

const _sentinel = Object();

class HealthDataState {
  final bool isLoading;
  final bool isLoadingMore;
  final List<HealthActivity> activities;
  final List<DietLog> dietLogs;
  final List<WeightLog> weightLogs;
  final DailySummary? todaySummary;
  final List<DailySummary> summaryHistory;
  final String? error;
  final bool hasMoreActivities;
  final bool hasMoreDietLogs;

  HealthDataState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.activities = const [],
    this.dietLogs = const [],
    this.weightLogs = const [],
    this.todaySummary,
    this.summaryHistory = const [],
    this.error,
    this.hasMoreActivities = true,
    this.hasMoreDietLogs = true,
  });

  HealthDataState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<HealthActivity>? activities,
    List<DietLog>? dietLogs,
    List<WeightLog>? weightLogs,
    Object? todaySummary = _sentinel,
    List<DailySummary>? summaryHistory,
    String? error,
    bool? hasMoreActivities,
    bool? hasMoreDietLogs,
  }) {
    return HealthDataState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      activities: activities ?? this.activities,
      dietLogs: dietLogs ?? this.dietLogs,
      weightLogs: weightLogs ?? this.weightLogs,
      todaySummary: todaySummary == _sentinel ? this.todaySummary : todaySummary as DailySummary?,
      summaryHistory: summaryHistory ?? this.summaryHistory,
      error: error,
      hasMoreActivities: hasMoreActivities ?? this.hasMoreActivities,
      hasMoreDietLogs: hasMoreDietLogs ?? this.hasMoreDietLogs,
    );
  }
}

class HealthDataNotifier extends StateNotifier<HealthDataState> {
  final IHealthDataRepository _repository;

  HealthDataNotifier(this._repository) : super(HealthDataState());

  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(Duration(days: 6));
      final results = await Future.wait([
        _repository.getActivities(),
        _repository.getDietLogs(),
        _repository.getWeightLogs(),
        _repository.getDailySummary(now),
        _repository.getDailySummariesByRange(sevenDaysAgo, now),
      ]);
      state = state.copyWith(
        isLoading: false,
        activities: results[0] as List<HealthActivity>,
        dietLogs: results[1] as List<DietLog>,
        weightLogs: results[2] as List<WeightLog>,
        todaySummary: results[3] as DailySummary?,
        summaryHistory: results[4] as List<DailySummary>,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: ErrorHandler.getFriendlyMessage(e));
    }
  }

  Future<bool> createActivity({
    required String activityType,
    required int durationMinutes,
    double? caloriesBurned,
    String? description,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.createActivity(
        activityType: activityType,
        durationMinutes: durationMinutes,
        caloriesBurned: caloriesBurned,
        description: description,
      );
      await loadAll();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: ErrorHandler.getFriendlyMessage(e));
      return false;
    }
  }

  Future<bool> createDietLog({
    required DateTime mealTime,
    required String mealType,
    required String foodItems,
    double? totalCalories,
    double? proteinG,
    double? carbsG,
    double? fatG,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.createDietLog(
        mealTime: mealTime,
        mealType: mealType,
        foodItems: foodItems,
        totalCalories: totalCalories,
        proteinG: proteinG,
        carbsG: carbsG,
        fatG: fatG,
      );
      await loadAll();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: ErrorHandler.getFriendlyMessage(e));
      return false;
    }
  }

  Future<bool> createWeightLog({
    required double weightKg,
    double? bodyFatPercentage,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final bmi = bodyFatPercentage != null ? null : null; // BMI calculated server-side
      await _repository.createWeightLog(
        recordDate: DateTime.now(),
        weightKg: weightKg,
        bodyFatPercentage: bodyFatPercentage,
        bmi: bmi,
      );
      await loadAll();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: ErrorHandler.getFriendlyMessage(e));
      return false;
    }
  }
}
