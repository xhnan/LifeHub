import 'package:json_annotation/json_annotation.dart';

part 'daily_mood.g.dart';

@JsonSerializable()
class DailyMood {
  final int? id;
  final int userId;
  final int moodScore;
  final String? primaryEmotion;
  final String? journalText;
  final DateTime recordDate;
  final DateTime? createdAt;

  DailyMood({
    this.id,
    required this.userId,
    required this.moodScore,
    this.primaryEmotion,
    this.journalText,
    required this.recordDate,
    this.createdAt,
  });

  factory DailyMood.fromJson(Map<String, dynamic> json) => _$DailyMoodFromJson(json);
  Map<String, dynamic> toJson() => _$DailyMoodToJson(this);
}
