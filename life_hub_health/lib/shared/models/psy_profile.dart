import 'package:json_annotation/json_annotation.dart';

part 'psy_profile.g.dart';

@JsonSerializable()
class PsyProfile {
  final int? id;
  final int userId;
  final String? mbtiType;
  final String? enneagramType;
  final int? baselineStressLevel;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PsyProfile({
    this.id,
    required this.userId,
    this.mbtiType,
    this.enneagramType,
    this.baselineStressLevel,
    this.createdAt,
    this.updatedAt,
  });

  factory PsyProfile.fromJson(Map<String, dynamic> json) => _$PsyProfileFromJson(json);
  Map<String, dynamic> toJson() => _$PsyProfileToJson(this);
}
