// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diet_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DietLog _$DietLogFromJson(Map<String, dynamic> json) => DietLog(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['userId'] as num).toInt(),
      mealTime: DateTime.parse(json['mealTime'] as String),
      mealType: json['mealType'] as String,
      foodItems: json['foodItems'] as String,
      totalCalories: (json['totalCalories'] as num?)?.toDouble(),
      proteinG: (json['proteinG'] as num?)?.toDouble(),
      carbsG: (json['carbsG'] as num?)?.toDouble(),
      fatG: (json['fatG'] as num?)?.toDouble(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$DietLogToJson(DietLog instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'mealTime': instance.mealTime.toIso8601String(),
      'mealType': instance.mealType,
      'foodItems': instance.foodItems,
      'totalCalories': instance.totalCalories,
      'proteinG': instance.proteinG,
      'carbsG': instance.carbsG,
      'fatG': instance.fatG,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
