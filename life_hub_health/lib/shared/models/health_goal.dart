import 'package:json_annotation/json_annotation.dart';

part 'health_goal.g.dart';

@JsonSerializable()
class HealthGoal {
  final int? id;
  final int userId;
  final String goalType;
  final double targetValue;
  final DateTime? deadline;
  final String status;
  final DateTime? createdAt;

  HealthGoal({
    this.id,
    required this.userId,
    required this.goalType,
    required this.targetValue,
    this.deadline,
    this.status = 'active',
    this.createdAt,
  });

  factory HealthGoal.fromJson(Map<String, dynamic> json) => _$HealthGoalFromJson(json);
  Map<String, dynamic> toJson() => _$HealthGoalToJson(this);

  String get goalTypeLabel {
    switch (goalType) {
      case 'weight_loss':
        return '减重';
      case 'weight_gain':
        return '增重';
      case 'exercise':
        return '运动';
      case 'diet':
        return '饮食';
      case 'sleep':
        return '睡眠';
      default:
        return '其他';
    }
  }

  String get statusLabel {
    switch (status) {
      case 'active':
        return '进行中';
      case 'achieved':
        return '已达成';
      case 'abandoned':
        return '已放弃';
      default:
        return status;
    }
  }
}
