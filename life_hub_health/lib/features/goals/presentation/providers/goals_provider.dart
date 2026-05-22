import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../shared/models/health_goal.dart';
import '../../../../shared/providers/providers.dart';
import '../../data/repositories/goals_repository_impl.dart';
import '../../domain/repositories/goals_repository.dart';

final goalsRepositoryProvider = Provider<IGoalsRepository>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return GoalsRepositoryImpl(apiService);
});

final goalsProvider = StateNotifierProvider<GoalsNotifier, GoalsState>((ref) {
  final repository = ref.read(goalsRepositoryProvider);
  return GoalsNotifier(repository);
});

class GoalsState {
  final bool isLoading;
  final List<HealthGoal> goals;
  final String? error;
  final bool isCreating;

  GoalsState({
    this.isLoading = false,
    this.goals = const [],
    this.error,
    this.isCreating = false,
  });

  List<HealthGoal> get activeGoals => goals.where((g) => g.status == 'active').toList();
  List<HealthGoal> get achievedGoals => goals.where((g) => g.status == 'achieved').toList();

  GoalsState copyWith({
    bool? isLoading,
    List<HealthGoal>? goals,
    String? error,
    bool? isCreating,
  }) {
    return GoalsState(
      isLoading: isLoading ?? this.isLoading,
      goals: goals ?? this.goals,
      error: error,
      isCreating: isCreating ?? this.isCreating,
    );
  }
}

class GoalsNotifier extends StateNotifier<GoalsState> {
  final IGoalsRepository _repository;

  GoalsNotifier(this._repository) : super(GoalsState()) {
    loadGoals();
  }

  Future<void> loadGoals() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final goals = await _repository.getMyGoals();
      state = state.copyWith(isLoading: false, goals: goals);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ErrorHandler.getFriendlyMessage(e),
      );
    }
  }

  Future<bool> createGoal({
    required String goalType,
    required double targetValue,
    DateTime? deadline,
  }) async {
    state = state.copyWith(isCreating: true);
    try {
      await _repository.createGoal(
        goalType: goalType,
        targetValue: targetValue,
        deadline: deadline,
      );
      await loadGoals();
      return true;
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        error: ErrorHandler.getFriendlyMessage(e),
      );
      return false;
    }
  }

  Future<void> updateStatus(int goalId, String status) async {
    try {
      await _repository.updateGoalStatus(goalId, status);
      await loadGoals();
    } catch (e) {
      state = state.copyWith(error: ErrorHandler.getFriendlyMessage(e));
    }
  }
}
