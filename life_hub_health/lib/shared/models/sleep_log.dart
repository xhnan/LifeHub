import 'package:json_annotation/json_annotation.dart';

part 'sleep_log.g.dart';

@JsonSerializable()
class SleepLog {
  final int? id;
  final int userId;
  final DateTime sleepDate;
  final DateTime? bedTime;
  final DateTime? wakeTime;
  final int? durationMinutes;
  final int? qualityScore;
  final int? deepSleepMinutes;
  final int? lightSleepMinutes;
  final int? awakeMinutes;
  final String? notes;
  final DateTime? createdAt;

  SleepLog({
    this.id,
    required this.userId,
    required this.sleepDate,
    this.bedTime,
    this.wakeTime,
    this.durationMinutes,
    this.qualityScore,
    this.deepSleepMinutes,
    this.lightSleepMinutes,
    this.awakeMinutes,
    this.notes,
    this.createdAt,
  });

  factory SleepLog.fromJson(Map<String, dynamic> json) => _$SleepLogFromJson(json);
  Map<String, dynamic> toJson() => _$SleepLogToJson(this);

  String get qualityLabel {
    if (qualityScore == null) return '未评价';
    if (qualityScore! >= 8) return '优秀';
    if (qualityScore! >= 6) return '良好';
    if (qualityScore! >= 4) return '一般';
    return '较差';
  }

  String get durationFormatted {
    if (durationMinutes == null) return '--';
    final h = durationMinutes! ~/ 60;
    final m = durationMinutes! % 60;
    if (m == 0) return '${h}h';
    return '${h}h${m}m';
  }
}
