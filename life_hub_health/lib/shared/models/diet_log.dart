import 'package:json_annotation/json_annotation.dart';

part 'diet_log.g.dart';

@JsonSerializable()
class DietLog {
  final int? id;
  final int userId;
  final DateTime mealTime;
  final String mealType;
  final String foodItems;
  final double? totalCalories;
  final double? proteinG;
  final double? carbsG;
  final double? fatG;
  final DateTime? createdAt;

  DietLog({
    this.id,
    required this.userId,
    required this.mealTime,
    required this.mealType,
    required this.foodItems,
    this.totalCalories,
    this.proteinG,
    this.carbsG,
    this.fatG,
    this.createdAt,
  });

  factory DietLog.fromJson(Map<String, dynamic> json) => _$DietLogFromJson(json);
  Map<String, dynamic> toJson() => _$DietLogToJson(this);
}
