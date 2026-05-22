// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'water_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WaterLog _$WaterLogFromJson(Map<String, dynamic> json) => WaterLog(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['userId'] as num).toInt(),
      recordTime: DateTime.parse(json['recordTime'] as String),
      amountMl: (json['amountMl'] as num).toInt(),
      drinkType: json['drinkType'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$WaterLogToJson(WaterLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'recordTime': instance.recordTime.toIso8601String(),
      'amountMl': instance.amountMl,
      'drinkType': instance.drinkType,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
