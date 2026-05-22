import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../../../shared/services/notification_service.dart';

final remindersProvider = StateNotifierProvider<RemindersNotifier, RemindersState>((ref) {
  return RemindersNotifier();
});

class RemindersState {
  final bool waterReminderEnabled;
  final int waterIntervalHours;
  final bool exerciseReminderEnabled;
  final TimeOfDay exerciseReminderTime;
  final bool sleepReminderEnabled;
  final TimeOfDay sleepReminderTime;
  final bool checkinReminderEnabled;
  final TimeOfDay checkinReminderTime;

  RemindersState({
    this.waterReminderEnabled = false,
    this.waterIntervalHours = 2,
    this.exerciseReminderEnabled = false,
    this.exerciseReminderTime = const TimeOfDay(hour: 18, minute: 0),
    this.sleepReminderEnabled = false,
    this.sleepReminderTime = const TimeOfDay(hour: 22, minute: 30),
    this.checkinReminderEnabled = false,
    this.checkinReminderTime = const TimeOfDay(hour: 21, minute: 0),
  });

  RemindersState copyWith({
    bool? waterReminderEnabled,
    int? waterIntervalHours,
    bool? exerciseReminderEnabled,
    TimeOfDay? exerciseReminderTime,
    bool? sleepReminderEnabled,
    TimeOfDay? sleepReminderTime,
    bool? checkinReminderEnabled,
    TimeOfDay? checkinReminderTime,
  }) {
    return RemindersState(
      waterReminderEnabled: waterReminderEnabled ?? this.waterReminderEnabled,
      waterIntervalHours: waterIntervalHours ?? this.waterIntervalHours,
      exerciseReminderEnabled: exerciseReminderEnabled ?? this.exerciseReminderEnabled,
      exerciseReminderTime: exerciseReminderTime ?? this.exerciseReminderTime,
      sleepReminderEnabled: sleepReminderEnabled ?? this.sleepReminderEnabled,
      sleepReminderTime: sleepReminderTime ?? this.sleepReminderTime,
      checkinReminderEnabled: checkinReminderEnabled ?? this.checkinReminderEnabled,
      checkinReminderTime: checkinReminderTime ?? this.checkinReminderTime,
    );
  }
}

class RemindersNotifier extends StateNotifier<RemindersState> {
  final NotificationService _notificationService = NotificationService();
  static const _boxName = 'reminders_settings';

  RemindersNotifier() : super(RemindersState()) {
    _init();
  }

  Future<void> _init() async {
    await _notificationService.initialize();
    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final box = await Hive.openBox(_boxName);
      state = RemindersState(
        waterReminderEnabled: box.get('waterEnabled', defaultValue: false),
        waterIntervalHours: box.get('waterInterval', defaultValue: 2),
        exerciseReminderEnabled: box.get('exerciseEnabled', defaultValue: false),
        exerciseReminderTime: TimeOfDay(
          hour: box.get('exerciseHour', defaultValue: 18),
          minute: box.get('exerciseMinute', defaultValue: 0),
        ),
        sleepReminderEnabled: box.get('sleepEnabled', defaultValue: false),
        sleepReminderTime: TimeOfDay(
          hour: box.get('sleepHour', defaultValue: 22),
          minute: box.get('sleepMinute', defaultValue: 30),
        ),
        checkinReminderEnabled: box.get('checkinEnabled', defaultValue: false),
        checkinReminderTime: TimeOfDay(
          hour: box.get('checkinHour', defaultValue: 21),
          minute: box.get('checkinMinute', defaultValue: 0),
        ),
      );
    } catch (_) {
      // Use defaults on error
    }
  }

  Future<void> _saveSettings() async {
    try {
      final box = await Hive.openBox(_boxName);
      await box.putAll({
        'waterEnabled': state.waterReminderEnabled,
        'waterInterval': state.waterIntervalHours,
        'exerciseEnabled': state.exerciseReminderEnabled,
        'exerciseHour': state.exerciseReminderTime.hour,
        'exerciseMinute': state.exerciseReminderTime.minute,
        'sleepEnabled': state.sleepReminderEnabled,
        'sleepHour': state.sleepReminderTime.hour,
        'sleepMinute': state.sleepReminderTime.minute,
        'checkinEnabled': state.checkinReminderEnabled,
        'checkinHour': state.checkinReminderTime.hour,
        'checkinMinute': state.checkinReminderTime.minute,
      });
    } catch (_) {}
  }

  void toggleWaterReminder(bool enabled) {
    state = state.copyWith(waterReminderEnabled: enabled);
    if (enabled) {
      _notificationService.scheduleWaterReminder(intervalHours: state.waterIntervalHours);
    } else {
      _notificationService.cancelWaterReminder();
    }
    _saveSettings();
  }

  void setWaterInterval(int hours) {
    state = state.copyWith(waterIntervalHours: hours);
    if (state.waterReminderEnabled) {
      _notificationService.scheduleWaterReminder(intervalHours: hours);
    }
    _saveSettings();
  }

  void toggleExerciseReminder(bool enabled) {
    state = state.copyWith(exerciseReminderEnabled: enabled);
    if (enabled) {
      _notificationService.scheduleExerciseReminder(time: state.exerciseReminderTime);
    } else {
      _notificationService.cancelExerciseReminder();
    }
    _saveSettings();
  }

  void setExerciseTime(TimeOfDay time) {
    state = state.copyWith(exerciseReminderTime: time);
    if (state.exerciseReminderEnabled) {
      _notificationService.scheduleExerciseReminder(time: time);
    }
    _saveSettings();
  }

  void toggleSleepReminder(bool enabled) {
    state = state.copyWith(sleepReminderEnabled: enabled);
    if (enabled) {
      _notificationService.scheduleSleepReminder(time: state.sleepReminderTime);
    } else {
      _notificationService.cancelSleepReminder();
    }
    _saveSettings();
  }

  void setSleepTime(TimeOfDay time) {
    state = state.copyWith(sleepReminderTime: time);
    if (state.sleepReminderEnabled) {
      _notificationService.scheduleSleepReminder(time: time);
    }
    _saveSettings();
  }

  void toggleCheckinReminder(bool enabled) {
    state = state.copyWith(checkinReminderEnabled: enabled);
    if (enabled) {
      _notificationService.scheduleCheckinReminder(time: state.checkinReminderTime);
    } else {
      _notificationService.cancelCheckinReminder();
    }
    _saveSettings();
  }

  void setCheckinTime(TimeOfDay time) {
    state = state.copyWith(checkinReminderTime: time);
    if (state.checkinReminderEnabled) {
      _notificationService.scheduleCheckinReminder(time: time);
    }
    _saveSettings();
  }
}
