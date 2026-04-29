// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailySummary _$DailySummaryFromJson(Map<String, dynamic> json) => DailySummary(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['userId'] as num).toInt(),
      recordDate: DateTime.parse(json['recordDate'] as String),
      totalSteps: (json['totalSteps'] as num?)?.toInt() ?? 0,
      activeCaloriesKcal: (json['activeCaloriesKcal'] as num?)?.toDouble() ?? 0,
      restingCaloriesKcal:
          (json['restingCaloriesKcal'] as num?)?.toDouble() ?? 0,
      totalDistanceMeters:
          (json['totalDistanceMeters'] as num?)?.toDouble() ?? 0,
      activeMinutes: (json['activeMinutes'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$DailySummaryToJson(DailySummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'recordDate': instance.recordDate.toIso8601String(),
      'totalSteps': instance.totalSteps,
      'activeCaloriesKcal': instance.activeCaloriesKcal,
      'restingCaloriesKcal': instance.restingCaloriesKcal,
      'totalDistanceMeters': instance.totalDistanceMeters,
      'activeMinutes': instance.activeMinutes,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
