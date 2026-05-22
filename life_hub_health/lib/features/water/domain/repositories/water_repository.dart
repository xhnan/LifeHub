import '../../../../shared/models/water_log.dart';

abstract class IWaterRepository {
  Future<List<WaterLog>> getTodayLogs();
  Future<int> getTodayTotal();
  Future<WaterLog> addWater({required int amountMl, String? drinkType});
}
