import 'package:json_annotation/json_annotation.dart';

part 'health_report.g.dart';

@JsonSerializable(explicitToJson: true)
class HealthReport {
  final String period;
  final DateTime startDate;
  final DateTime endDate;
  final int overallScore;
  final DimensionScores scores;
  final ReportMetrics metrics;
  final String? aiNarrative;
  final List<String>? keyInsights;
  final List<String>? recommendations;
  final TrendComparison? trends;

  HealthReport({
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.overallScore,
    required this.scores,
    required this.metrics,
    this.aiNarrative,
    this.keyInsights,
    this.recommendations,
    this.trends,
  });

  factory HealthReport.fromJson(Map<String, dynamic> json) => _$HealthReportFromJson(json);
  Map<String, dynamic> toJson() => _$HealthReportToJson(this);
}

@JsonSerializable()
class DimensionScores {
  final int? exercise;
  final int? diet;
  final int? sleep;
  final int? psychology;
  final int? weight;

  DimensionScores({this.exercise, this.diet, this.sleep, this.psychology, this.weight});

  factory DimensionScores.fromJson(Map<String, dynamic> json) => _$DimensionScoresFromJson(json);
  Map<String, dynamic> toJson() => _$DimensionScoresToJson(this);
}

@JsonSerializable()
class ReportMetrics {
  final int? totalSteps;
  final double? totalActiveCalories;
  final int? totalActiveMinutes;
  final int? activityCount;
  final int? dietLogCount;
  final double? avgCaloriesIntake;
  final int? weightLogCount;
  final double? weightChange;
  final double? currentWeight;
  final int? moodLogCount;
  final double? avgMoodScore;
  final int? sleepLogCount;
  final double? avgSleepHours;
  final double? avgSleepQuality;

  ReportMetrics({
    this.totalSteps,
    this.totalActiveCalories,
    this.totalActiveMinutes,
    this.activityCount,
    this.dietLogCount,
    this.avgCaloriesIntake,
    this.weightLogCount,
    this.weightChange,
    this.currentWeight,
    this.moodLogCount,
    this.avgMoodScore,
    this.sleepLogCount,
    this.avgSleepHours,
    this.avgSleepQuality,
  });

  factory ReportMetrics.fromJson(Map<String, dynamic> json) => _$ReportMetricsFromJson(json);
  Map<String, dynamic> toJson() => _$ReportMetricsToJson(this);
}

@JsonSerializable()
class TrendComparison {
  final String? stepsTrend;
  final double? stepsChangePercent;
  final String? moodTrend;
  final double? moodChangePercent;
  final String? weightTrend;
  final double? weightChangeKg;

  TrendComparison({
    this.stepsTrend,
    this.stepsChangePercent,
    this.moodTrend,
    this.moodChangePercent,
    this.weightTrend,
    this.weightChangeKg,
  });

  factory TrendComparison.fromJson(Map<String, dynamic> json) => _$TrendComparisonFromJson(json);
  Map<String, dynamic> toJson() => _$TrendComparisonToJson(this);
}
