import 'package:json_annotation/json_annotation.dart';

part 'daily_summary.g.dart';

@JsonSerializable()
class DailySummary {
  final int? id;
  final int userId;
  final DateTime recordDate;
  final int totalSteps;
  final double activeCaloriesKcal;
  final double restingCaloriesKcal;
  final double totalDistanceMeters;
  final int activeMinutes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DailySummary({
    this.id,
    required this.userId,
    required this.recordDate,
    this.totalSteps = 0,
    this.activeCaloriesKcal = 0,
    this.restingCaloriesKcal = 0,
    this.totalDistanceMeters = 0,
    this.activeMinutes = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory DailySummary.fromJson(Map<String, dynamic> json) => _$DailySummaryFromJson(json);
  Map<String, dynamic> toJson() => _$DailySummaryToJson(this);
}
