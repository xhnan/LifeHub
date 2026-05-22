// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sleep_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SleepLog _$SleepLogFromJson(Map<String, dynamic> json) => SleepLog(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['userId'] as num).toInt(),
      sleepDate: DateTime.parse(json['sleepDate'] as String),
      bedTime: json['bedTime'] == null
          ? null
          : DateTime.parse(json['bedTime'] as String),
      wakeTime: json['wakeTime'] == null
          ? null
          : DateTime.parse(json['wakeTime'] as String),
      durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
      qualityScore: (json['qualityScore'] as num?)?.toInt(),
      deepSleepMinutes: (json['deepSleepMinutes'] as num?)?.toInt(),
      lightSleepMinutes: (json['lightSleepMinutes'] as num?)?.toInt(),
      awakeMinutes: (json['awakeMinutes'] as num?)?.toInt(),
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$SleepLogToJson(SleepLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'sleepDate': instance.sleepDate.toIso8601String(),
      'bedTime': instance.bedTime?.toIso8601String(),
      'wakeTime': instance.wakeTime?.toIso8601String(),
      'durationMinutes': instance.durationMinutes,
      'qualityScore': instance.qualityScore,
      'deepSleepMinutes': instance.deepSleepMinutes,
      'lightSleepMinutes': instance.lightSleepMinutes,
      'awakeMinutes': instance.awakeMinutes,
      'notes': instance.notes,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
