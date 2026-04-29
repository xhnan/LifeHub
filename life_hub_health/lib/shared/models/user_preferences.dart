import 'package:json_annotation/json_annotation.dart';

part 'user_preferences.g.dart';

@JsonSerializable()
class UserPreferences {
  final int? id;
  final int userId;
  final String? preferredDietStyle;
  final String? dislikedFoods;
  final String? preferredExerciseTypes;
  final String? preferredSupportStyle;
  final String? routinePattern;
  final String? motivationTags;
  final Map<String, dynamic>? habitProfile;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserPreferences({
    this.id,
    required this.userId,
    this.preferredDietStyle,
    this.dislikedFoods,
    this.preferredExerciseTypes,
    this.preferredSupportStyle,
    this.routinePattern,
    this.motivationTags,
    this.habitProfile,
    this.createdAt,
    this.updatedAt,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) => _$UserPreferencesFromJson(json);
  Map<String, dynamic> toJson() => _$UserPreferencesToJson(this);
}
