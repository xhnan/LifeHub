import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';

@JsonSerializable()
class UserProfile {
  final int? id;
  final int userId;
  final DateTime? birthDate;
  final String? gender;
  final double? heightCm;
  final double? baselineWeightKg;
  final double? targetWeightKg;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfile({
    this.id,
    required this.userId,
    this.birthDate,
    this.gender,
    this.heightCm,
    this.baselineWeightKg,
    this.targetWeightKg,
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
}
