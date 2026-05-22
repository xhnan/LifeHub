// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthReport _$HealthReportFromJson(Map<String, dynamic> json) => HealthReport(
      period: json['period'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      overallScore: (json['overallScore'] as num).toInt(),
      scores: DimensionScores.fromJson(json['scores'] as Map<String, dynamic>),
      metrics: ReportMetrics.fromJson(json['metrics'] as Map<String, dynamic>),
      aiNarrative: json['aiNarrative'] as String?,
      keyInsights: (json['keyInsights'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      recommendations: (json['recommendations'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      trends: json['trends'] == null
          ? null
          : TrendComparison.fromJson(json['trends'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$HealthReportToJson(HealthReport instance) =>
    <String, dynamic>{
      'period': instance.period,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'overallScore': instance.overallScore,
      'scores': instance.scores.toJson(),
      'metrics': instance.metrics.toJson(),
      'aiNarrative': instance.aiNarrative,
      'keyInsights': instance.keyInsights,
      'recommendations': instance.recommendations,
      'trends': instance.trends?.toJson(),
    };

DimensionScores _$DimensionScoresFromJson(Map<String, dynamic> json) =>
    DimensionScores(
      exercise: (json['exercise'] as num?)?.toInt(),
      diet: (json['diet'] as num?)?.toInt(),
      sleep: (json['sleep'] as num?)?.toInt(),
      psychology: (json['psychology'] as num?)?.toInt(),
      weight: (json['weight'] as num?)?.toInt(),
    );

Map<String, dynamic> _$DimensionScoresToJson(DimensionScores instance) =>
    <String, dynamic>{
      'exercise': instance.exercise,
      'diet': instance.diet,
      'sleep': instance.sleep,
      'psychology': instance.psychology,
      'weight': instance.weight,
    };

ReportMetrics _$ReportMetricsFromJson(Map<String, dynamic> json) =>
    ReportMetrics(
      totalSteps: (json['totalSteps'] as num?)?.toInt(),
      totalActiveCalories: (json['totalActiveCalories'] as num?)?.toDouble(),
      totalActiveMinutes: (json['totalActiveMinutes'] as num?)?.toInt(),
      activityCount: (json['activityCount'] as num?)?.toInt(),
      dietLogCount: (json['dietLogCount'] as num?)?.toInt(),
      avgCaloriesIntake: (json['avgCaloriesIntake'] as num?)?.toDouble(),
      weightLogCount: (json['weightLogCount'] as num?)?.toInt(),
      weightChange: (json['weightChange'] as num?)?.toDouble(),
      currentWeight: (json['currentWeight'] as num?)?.toDouble(),
      moodLogCount: (json['moodLogCount'] as num?)?.toInt(),
      avgMoodScore: (json['avgMoodScore'] as num?)?.toDouble(),
      sleepLogCount: (json['sleepLogCount'] as num?)?.toInt(),
      avgSleepHours: (json['avgSleepHours'] as num?)?.toDouble(),
      avgSleepQuality: (json['avgSleepQuality'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ReportMetricsToJson(ReportMetrics instance) =>
    <String, dynamic>{
      'totalSteps': instance.totalSteps,
      'totalActiveCalories': instance.totalActiveCalories,
      'totalActiveMinutes': instance.totalActiveMinutes,
      'activityCount': instance.activityCount,
      'dietLogCount': instance.dietLogCount,
      'avgCaloriesIntake': instance.avgCaloriesIntake,
      'weightLogCount': instance.weightLogCount,
      'weightChange': instance.weightChange,
      'currentWeight': instance.currentWeight,
      'moodLogCount': instance.moodLogCount,
      'avgMoodScore': instance.avgMoodScore,
      'sleepLogCount': instance.sleepLogCount,
      'avgSleepHours': instance.avgSleepHours,
      'avgSleepQuality': instance.avgSleepQuality,
    };

TrendComparison _$TrendComparisonFromJson(Map<String, dynamic> json) =>
    TrendComparison(
      stepsTrend: json['stepsTrend'] as String?,
      stepsChangePercent: (json['stepsChangePercent'] as num?)?.toDouble(),
      moodTrend: json['moodTrend'] as String?,
      moodChangePercent: (json['moodChangePercent'] as num?)?.toDouble(),
      weightTrend: json['weightTrend'] as String?,
      weightChangeKg: (json['weightChangeKg'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$TrendComparisonToJson(TrendComparison instance) =>
    <String, dynamic>{
      'stepsTrend': instance.stepsTrend,
      'stepsChangePercent': instance.stepsChangePercent,
      'moodTrend': instance.moodTrend,
      'moodChangePercent': instance.moodChangePercent,
      'weightTrend': instance.weightTrend,
      'weightChangeKg': instance.weightChangeKg,
    };
