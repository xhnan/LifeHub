import '../../../../shared/models/daily_summary.dart';
import '../../../../shared/models/weight_log.dart';

abstract class IHomeRepository {
  Future<DailySummary?> getTodaySummary();
  Future<WeightLog?> getLatestWeight();
}
