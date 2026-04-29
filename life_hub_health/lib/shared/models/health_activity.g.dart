// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthActivity _$HealthActivityFromJson(Map<String, dynamic> json) =>
    HealthActivity(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['userId'] as num).toInt(),
      activityType: json['activityType'] as String,
      startTime: json['startTime'] == null
          ? null
          : DateTime.parse(json['startTime'] as String),
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      caloriesBurned: (json['caloriesBurned'] as num?)?.toDouble(),
      description: json['description'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$HealthActivityToJson(HealthActivity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'activityType': instance.activityType,
      'startTime': instance.startTime?.toIso8601String(),
      'durationMinutes': instance.durationMinutes,
      'caloriesBurned': instance.caloriesBurned,
      'description': instance.description,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
