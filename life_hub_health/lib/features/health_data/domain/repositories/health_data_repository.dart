import '../../../../shared/models/health_activity.dart';
import '../../../../shared/models/diet_log.dart';
import '../../../../shared/models/weight_log.dart';
import '../../../../shared/models/daily_summary.dart';

abstract class IHealthDataRepository {
  // Activities
  Future<List<HealthActivity>> getActivities({String? activityType});
  Future<bool> createActivity({
    required String activityType,
    DateTime? startTime,
    required int durationMinutes,
    double? caloriesBurned,
    String? description,
  });

  // Diet logs
  Future<List<DietLog>> getDietLogs({String? mealType});
  Future<List<DietLog>> getDietLogsByDate(DateTime date);
  Future<bool> createDietLog({
    required DateTime mealTime,
    required String mealType,
    required String foodItems,
    double? totalCalories,
    double? proteinG,
    double? carbsG,
    double? fatG,
  });

  // Weight logs
  Future<List<WeightLog>> getWeightLogs();
  Future<WeightLog?> getLatestWeight();
  Future<List<WeightLog>> getWeightLogsByRange(DateTime start, DateTime end);
  Future<bool> createWeightLog({
    required DateTime recordDate,
    required double weightKg,
    double? bodyFatPercentage,
    double? bmi,
  });

  // Daily summaries
  Future<DailySummary?> getDailySummary(DateTime date);
  Future<List<DailySummary>> getDailySummaries();
  Future<List<DailySummary>> getDailySummariesByRange(DateTime start, DateTime end);
}
