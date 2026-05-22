import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../shared/models/water_log.dart';
import '../../../../shared/providers/providers.dart';
import '../../data/repositories/water_repository_impl.dart';
import '../../domain/repositories/water_repository.dart';

final waterRepositoryProvider = Provider<IWaterRepository>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return WaterRepositoryImpl(apiService);
});

final waterProvider = StateNotifierProvider<WaterNotifier, WaterState>((ref) {
  final repository = ref.read(waterRepositoryProvider);
  return WaterNotifier(repository);
});

class WaterState {
  final bool isLoading;
  final List<WaterLog> todayLogs;
  final int todayTotalMl;
  final int dailyGoalMl;
  final String? error;

  WaterState({
    this.isLoading = false,
    this.todayLogs = const [],
    this.todayTotalMl = 0,
    this.dailyGoalMl = 2000,
    this.error,
  });

  double get progress => (todayTotalMl / dailyGoalMl).clamp(0.0, 1.0);
  int get remaining => (dailyGoalMl - todayTotalMl).clamp(0, dailyGoalMl);
  bool get goalReached => todayTotalMl >= dailyGoalMl;

  WaterState copyWith({
    bool? isLoading,
    List<WaterLog>? todayLogs,
    int? todayTotalMl,
    int? dailyGoalMl,
    String? error,
  }) {
    return WaterState(
      isLoading: isLoading ?? this.isLoading,
      todayLogs: todayLogs ?? this.todayLogs,
      todayTotalMl: todayTotalMl ?? this.todayTotalMl,
      dailyGoalMl: dailyGoalMl ?? this.dailyGoalMl,
      error: error,
    );
  }
}

class WaterNotifier extends StateNotifier<WaterState> {
  final IWaterRepository _repository;

  WaterNotifier(this._repository) : super(WaterState()) {
    loadToday();
  }

  Future<void> loadToday() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final logs = await _repository.getTodayLogs();
      final total = logs.fold(0, (sum, log) => sum + log.amountMl);
      state = state.copyWith(isLoading: false, todayLogs: logs, todayTotalMl: total);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: ErrorHandler.getFriendlyMessage(e));
    }
  }

  Future<bool> addWater(int amountMl, {String? drinkType}) async {
    try {
      await _repository.addWater(amountMl: amountMl, drinkType: drinkType);
      await loadToday();
      return true;
    } catch (e) {
      state = state.copyWith(error: ErrorHandler.getFriendlyMessage(e));
      return false;
    }
  }

  void setDailyGoal(int ml) {
    state = state.copyWith(dailyGoalMl: ml);
  }
}
