import 'package:json_annotation/json_annotation.dart';

part 'weight_log.g.dart';

@JsonSerializable()
class WeightLog {
  final int? id;
  final int userId;
  final DateTime recordDate;
  final double weightKg;
  final double? bodyFatPercentage;
  final double? bmi;
  final DateTime? createdAt;

  WeightLog({
    this.id,
    required this.userId,
    required this.recordDate,
    required this.weightKg,
    this.bodyFatPercentage,
    this.bmi,
    this.createdAt,
  });

  factory WeightLog.fromJson(Map<String, dynamic> json) => _$WeightLogFromJson(json);
  Map<String, dynamic> toJson() => _$WeightLogToJson(this);
}
