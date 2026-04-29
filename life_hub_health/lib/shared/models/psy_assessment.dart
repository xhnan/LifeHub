import 'package:json_annotation/json_annotation.dart';

part 'psy_assessment.g.dart';

@JsonSerializable()
class PsyAssessment {
  final int? id;
  final int userId;
  final String scaleName;
  final int totalScore;
  final String? severityLevel;
  final String? resultAnalysis;
  final DateTime? createdAt;

  PsyAssessment({
    this.id,
    required this.userId,
    required this.scaleName,
    required this.totalScore,
    this.severityLevel,
    this.resultAnalysis,
    this.createdAt,
  });

  factory PsyAssessment.fromJson(Map<String, dynamic> json) => _$PsyAssessmentFromJson(json);
  Map<String, dynamic> toJson() => _$PsyAssessmentToJson(this);
}

@JsonSerializable()
class AssessmentQuestion {
  final int index;
  final String question;
  final List<AssessmentOption> options;

  AssessmentQuestion({
    required this.index,
    required this.question,
    required this.options,
  });

  factory AssessmentQuestion.fromJson(Map<String, dynamic> json) => _$AssessmentQuestionFromJson(json);
  Map<String, dynamic> toJson() => _$AssessmentQuestionToJson(this);
}

@JsonSerializable()
class AssessmentOption {
  final int value;
  final String label;

  AssessmentOption({
    required this.value,
    required this.label,
  });

  factory AssessmentOption.fromJson(Map<String, dynamic> json) => _$AssessmentOptionFromJson(json);
  Map<String, dynamic> toJson() => _$AssessmentOptionToJson(this);
}
