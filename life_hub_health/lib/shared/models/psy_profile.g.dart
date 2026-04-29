// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'psy_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PsyProfile _$PsyProfileFromJson(Map<String, dynamic> json) => PsyProfile(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['userId'] as num).toInt(),
      mbtiType: json['mbtiType'] as String?,
      enneagramType: json['enneagramType'] as String?,
      baselineStressLevel: (json['baselineStressLevel'] as num?)?.toInt(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PsyProfileToJson(PsyProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'mbtiType': instance.mbtiType,
      'enneagramType': instance.enneagramType,
      'baselineStressLevel': instance.baselineStressLevel,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
