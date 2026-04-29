// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_mood.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyMood _$DailyMoodFromJson(Map<String, dynamic> json) => DailyMood(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['userId'] as num).toInt(),
      moodScore: (json['moodScore'] as num).toInt(),
      primaryEmotion: json['primaryEmotion'] as String?,
      journalText: json['journalText'] as String?,
      recordDate: DateTime.parse(json['recordDate'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$DailyMoodToJson(DailyMood instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'moodScore': instance.moodScore,
      'primaryEmotion': instance.primaryEmotion,
      'journalText': instance.journalText,
      'recordDate': instance.recordDate.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
    };
