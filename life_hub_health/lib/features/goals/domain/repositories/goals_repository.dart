import '../../../../shared/models/health_goal.dart';

abstract class IGoalsRepository {
  Future<List<HealthGoal>> getMyGoals({String? status, String? goalType});
  Future<HealthGoal> createGoal({
    required String goalType,
    required double targetValue,
    DateTime? deadline,
  });
  Future<void> updateGoalStatus(int goalId, String status);
}
