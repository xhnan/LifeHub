// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'psy_assessment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PsyAssessment _$PsyAssessmentFromJson(Map<String, dynamic> json) =>
    PsyAssessment(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['userId'] as num).toInt(),
      scaleName: json['scaleName'] as String,
      totalScore: (json['totalScore'] as num).toInt(),
      severityLevel: json['severityLevel'] as String?,
      resultAnalysis: json['resultAnalysis'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$PsyAssessmentToJson(PsyAssessment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'scaleName': instance.scaleName,
      'totalScore': instance.totalScore,
      'severityLevel': instance.severityLevel,
      'resultAnalysis': instance.resultAnalysis,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

AssessmentQuestion _$AssessmentQuestionFromJson(Map<String, dynamic> json) =>
    AssessmentQuestion(
      index: (json['index'] as num).toInt(),
      question: json['question'] as String,
      options: (json['options'] as List<dynamic>)
          .map((e) => AssessmentOption.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AssessmentQuestionToJson(AssessmentQuestion instance) =>
    <String, dynamic>{
      'index': instance.index,
      'question': instance.question,
      'options': instance.options,
    };

AssessmentOption _$AssessmentOptionFromJson(Map<String, dynamic> json) =>
    AssessmentOption(
      value: (json['value'] as num).toInt(),
      label: json['label'] as String,
    );

Map<String, dynamic> _$AssessmentOptionToJson(AssessmentOption instance) =>
    <String, dynamic>{
      'value': instance.value,
      'label': instance.label,
    };
