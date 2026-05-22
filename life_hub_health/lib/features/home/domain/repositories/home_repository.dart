import '../../../../shared/models/daily_summary.dart';
import '../../../../shared/models/weight_log.dart';
import '../../../../shared/models/daily_mood.dart';
import '../../../../shared/models/agent_models.dart';

abstract class IHomeRepository {
  Future<DailySummary?> getTodaySummary();
  Future<WeightLog?> getLatestWeight();
  Future<List<WeightLog>> getWeightTrend(int days);
  Future<List<DailyMood>> getMoodTrend(int days);
  Future<List<AdviceRecord>> getActiveAdvice();
  Future<List<Checkin>> getTodayCheckins();
  Future<List<FollowupPlan>> getActivePlans();
  Future<DailyMood?> getLatestMood();
}
