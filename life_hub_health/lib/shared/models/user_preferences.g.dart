// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPreferences _$UserPreferencesFromJson(Map<String, dynamic> json) =>
    UserPreferences(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['userId'] as num).toInt(),
      preferredDietStyle: json['preferredDietStyle'] as String?,
      dislikedFoods: json['dislikedFoods'] as String?,
      preferredExerciseTypes: json['preferredExerciseTypes'] as String?,
      preferredSupportStyle: json['preferredSupportStyle'] as String?,
      routinePattern: json['routinePattern'] as String?,
      motivationTags: json['motivationTags'] as String?,
      habitProfile: json['habitProfile'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$UserPreferencesToJson(UserPreferences instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'preferredDietStyle': instance.preferredDietStyle,
      'dislikedFoods': instance.dislikedFoods,
      'preferredExerciseTypes': instance.preferredExerciseTypes,
      'preferredSupportStyle': instance.preferredSupportStyle,
      'routinePattern': instance.routinePattern,
      'motivationTags': instance.motivationTags,
      'habitProfile': instance.habitProfile,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
