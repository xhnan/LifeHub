// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeightLog _$WeightLogFromJson(Map<String, dynamic> json) => WeightLog(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['userId'] as num).toInt(),
      recordDate: DateTime.parse(json['recordDate'] as String),
      weightKg: (json['weightKg'] as num).toDouble(),
      bodyFatPercentage: (json['bodyFatPercentage'] as num?)?.toDouble(),
      bmi: (json['bmi'] as num?)?.toDouble(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$WeightLogToJson(WeightLog instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'recordDate': instance.recordDate.toIso8601String(),
      'weightKg': instance.weightKg,
      'bodyFatPercentage': instance.bodyFatPercentage,
      'bmi': instance.bmi,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
