import 'package:json_annotation/json_annotation.dart';

part 'agent_models.g.dart';

@JsonSerializable()
class AdviceRecord {
  final int? id;
  final int userId;
  final String agentType;
  final String adviceType;
  final String? title;
  final String content;
  final String? sourceSummary;
  final String? priorityLevel;
  final String status;
  final DateTime? validUntil;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AdviceRecord({
    this.id,
    required this.userId,
    required this.agentType,
    required this.adviceType,
    this.title,
    required this.content,
    this.sourceSummary,
    this.priorityLevel,
    this.status = 'active',
    this.validUntil,
    this.createdAt,
    this.updatedAt,
  });

  factory AdviceRecord.fromJson(Map<String, dynamic> json) => _$AdviceRecordFromJson(json);
  Map<String, dynamic> toJson() => _$AdviceRecordToJson(this);
}

@JsonSerializable()
class FollowupPlan {
  final int? id;
  final int userId;
  final String planType;
  final String title;
  final Map<String, dynamic> planJson;
  final String? goalSummary;
  final int? relatedAdviceId;
  final String status;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FollowupPlan({
    this.id,
    required this.userId,
    required this.planType,
    required this.title,
    required this.planJson,
    this.goalSummary,
    this.relatedAdviceId,
    this.status = 'active',
    this.startDate,
    this.endDate,
    this.createdAt,
    this.updatedAt,
  });

  factory FollowupPlan.fromJson(Map<String, dynamic> json) => _$FollowupPlanFromJson(json);
  Map<String, dynamic> toJson() => _$FollowupPlanToJson(this);
}

@JsonSerializable()
class Checkin {
  final int? id;
  final int userId;
  final int? adviceRecordId;
  final int? followupPlanId;
  final DateTime checkinDate;
  final String completionStatus;
  final int? adherenceScore;
  final int? effectScore;
  final String? userFeedback;
  final String? blockerReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Checkin({
    this.id,
    required this.userId,
    this.adviceRecordId,
    this.followupPlanId,
    required this.checkinDate,
    this.completionStatus = 'pending',
    this.adherenceScore,
    this.effectScore,
    this.userFeedback,
    this.blockerReason,
    this.createdAt,
    this.updatedAt,
  });

  factory Checkin.fromJson(Map<String, dynamic> json) => _$CheckinFromJson(json);
  Map<String, dynamic> toJson() => _$CheckinToJson(this);
}
