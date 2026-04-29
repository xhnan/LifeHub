import 'package:json_annotation/json_annotation.dart';

part 'health_activity.g.dart';

@JsonSerializable()
class HealthActivity {
  final int? id;
  final int userId;
  final String activityType;
  final DateTime? startTime;
  final int durationMinutes;
  final double? caloriesBurned;
  final String? description;
  final DateTime? createdAt;

  HealthActivity({
    this.id,
    required this.userId,
    required this.activityType,
    this.startTime,
    required this.durationMinutes,
    this.caloriesBurned,
    this.description,
    this.createdAt,
  });

  factory HealthActivity.fromJson(Map<String, dynamic> json) => _$HealthActivityFromJson(json);
  Map<String, dynamic> toJson() => _$HealthActivityToJson(this);
}
