// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthGoal _$HealthGoalFromJson(Map<String, dynamic> json) => HealthGoal(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['userId'] as num).toInt(),
      goalType: json['goalType'] as String,
      targetValue: (json['targetValue'] as num).toDouble(),
      deadline: json['deadline'] == null
          ? null
          : DateTime.parse(json['deadline'] as String),
      status: json['status'] as String? ?? 'active',
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$HealthGoalToJson(HealthGoal instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'goalType': instance.goalType,
      'targetValue': instance.targetValue,
      'deadline': instance.deadline?.toIso8601String(),
      'status': instance.status,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
