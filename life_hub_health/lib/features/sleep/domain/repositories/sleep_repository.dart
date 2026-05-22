import '../../../../shared/models/sleep_log.dart';

abstract class ISleepRepository {
  Future<List<SleepLog>> getMySleepLogs();
  Future<List<SleepLog>> getSleepLogsByRange(DateTime startDate, DateTime endDate);
  Future<SleepLog?> getLatestSleepLog();
  Future<SleepLog> createSleepLog({
    required DateTime sleepDate,
    DateTime? bedTime,
    DateTime? wakeTime,
    int? durationMinutes,
    int? qualityScore,
    int? deepSleepMinutes,
    int? lightSleepMinutes,
    int? awakeMinutes,
    String? notes,
  });
}
