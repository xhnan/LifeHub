// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdviceRecord _$AdviceRecordFromJson(Map<String, dynamic> json) => AdviceRecord(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['userId'] as num).toInt(),
      agentType: json['agentType'] as String,
      adviceType: json['adviceType'] as String,
      title: json['title'] as String?,
      content: json['content'] as String,
      sourceSummary: json['sourceSummary'] as String?,
      priorityLevel: json['priorityLevel'] as String?,
      status: json['status'] as String? ?? 'active',
      validUntil: json['validUntil'] == null
          ? null
          : DateTime.parse(json['validUntil'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AdviceRecordToJson(AdviceRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'agentType': instance.agentType,
      'adviceType': instance.adviceType,
      'title': instance.title,
      'content': instance.content,
      'sourceSummary': instance.sourceSummary,
      'priorityLevel': instance.priorityLevel,
      'status': instance.status,
      'validUntil': instance.validUntil?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

FollowupPlan _$FollowupPlanFromJson(Map<String, dynamic> json) => FollowupPlan(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['userId'] as num).toInt(),
      planType: json['planType'] as String,
      title: json['title'] as String,
      planJson: json['planJson'] as Map<String, dynamic>,
      goalSummary: json['goalSummary'] as String?,
      relatedAdviceId: (json['relatedAdviceId'] as num?)?.toInt(),
      status: json['status'] as String? ?? 'active',
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$FollowupPlanToJson(FollowupPlan instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'planType': instance.planType,
      'title': instance.title,
      'planJson': instance.planJson,
      'goalSummary': instance.goalSummary,
      'relatedAdviceId': instance.relatedAdviceId,
      'status': instance.status,
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

Checkin _$CheckinFromJson(Map<String, dynamic> json) => Checkin(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['userId'] as num).toInt(),
      adviceRecordId: (json['adviceRecordId'] as num?)?.toInt(),
      followupPlanId: (json['followupPlanId'] as num?)?.toInt(),
      checkinDate: DateTime.parse(json['checkinDate'] as String),
      completionStatus: json['completionStatus'] as String? ?? 'pending',
      adherenceScore: (json['adherenceScore'] as num?)?.toInt(),
      effectScore: (json['effectScore'] as num?)?.toInt(),
      userFeedback: json['userFeedback'] as String?,
      blockerReason: json['blockerReason'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CheckinToJson(Checkin instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'adviceRecordId': instance.adviceRecordId,
      'followupPlanId': instance.followupPlanId,
      'checkinDate': instance.checkinDate.toIso8601String(),
      'completionStatus': instance.completionStatus,
      'adherenceScore': instance.adherenceScore,
      'effectScore': instance.effectScore,
      'userFeedback': instance.userFeedback,
      'blockerReason': instance.blockerReason,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
