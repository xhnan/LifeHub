import 'package:json_annotation/json_annotation.dart';

part 'water_log.g.dart';

@JsonSerializable()
class WaterLog {
  final int? id;
  final int userId;
  final DateTime recordTime;
  final int amountMl;
  final String? drinkType;
  final DateTime? createdAt;

  WaterLog({
    this.id,
    required this.userId,
    required this.recordTime,
    required this.amountMl,
    this.drinkType,
    this.createdAt,
  });

  factory WaterLog.fromJson(Map<String, dynamic> json) => _$WaterLogFromJson(json);
  Map<String, dynamic> toJson() => _$WaterLogToJson(this);

  String get drinkTypeLabel {
    switch (drinkType) {
      case 'water':
        return '白水';
      case 'tea':
        return '茶';
      case 'coffee':
        return '咖啡';
      default:
        return '其他';
    }
  }
}
