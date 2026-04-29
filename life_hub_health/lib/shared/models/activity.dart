import 'package:json_annotation/json_annotation.dart';

part 'activity.g.dart';

@JsonSerializable()
class Activity {
  final int? id;
  final int userId;
  final String activityType;
  final DateTime? startTime;
  final int durationMinutes;
  final double? caloriesBurned;
  final String? description;
  final DateTime? createdAt;

  Activity({
    this.id,
    required this.userId,
    required this.activityType,
    this.startTime,
    required this.durationMinutes,
    this.caloriesBurned,
    this.description,
    this.createdAt,
  });

  factory Activity.fromJson(Map<String, dynamic> json) => _$ActivityFromJson(json);
  Map<String, dynamic> toJson() => _$ActivityToJson(this);
}
