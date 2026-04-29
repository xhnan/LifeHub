import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/daily_summary.dart';
import '../../../../shared/models/weight_log.dart';
import '../../../../shared/providers/providers.dart';
import '../../domain/repositories/home_repository.dart';
import '../../data/repositories/home_repository.dart';

final homeRepositoryProvider = Provider<IHomeRepository>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return HomeRepository(apiService);
});

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  final repository = ref.read(homeRepositoryProvider);
  return HomeNotifier(repository);
});

class HomeState {
  final bool isLoading;
  final DailySummary? todaySummary;
  final WeightLog? latestWeight;
  final String? error;

  HomeState({
    this.isLoading = false,
    this.todaySummary,
    this.latestWeight,
    this.error,
  });

  HomeState copyWith({
    bool? isLoading,
    DailySummary? todaySummary,
    WeightLog? latestWeight,
    String? error,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      todaySummary: todaySummary ?? this.todaySummary,
      latestWeight: latestWeight ?? this.latestWeight,
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
    try {
      final summary = await _repository.getTodaySummary();
      final weight = await _repository.getLatestWeight();
      state = state.copyWith(
        isLoading: false,
        todaySummary: summary,
        latestWeight: weight,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}
