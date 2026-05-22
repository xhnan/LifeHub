import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

/// 本地通知服务
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _plugin.initialize(settings);
    _initialized = true;
  }

  /// 请求通知权限 (Android 13+)
  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    return true; // iOS handles via initialization
  }

  /// 取消所有通知
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// 取消指定 ID 的通知
  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  /// 调度周期性饮水提醒
  Future<void> scheduleWaterReminder({required int intervalHours}) async {
    await _cancelGroup(_waterReminderBaseId, 12);

    final now = DateTime.now();
    // 从早8点到晚10点每隔 intervalHours 提醒
    int notificationId = _waterReminderBaseId;
    for (int hour = 8; hour <= 22; hour += intervalHours) {
      var scheduledTime = DateTime(now.year, now.month, now.day, hour, 0);
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(Duration(days: 1));
      }

      await _plugin.zonedSchedule(
        notificationId++,
        '💧 该喝水了',
        '记得补充水分，保持身体水分充足',
        tz.TZDateTime.from(scheduledTime, tz.local),
        _defaultDetails('water_reminder'),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  /// 调度运动提醒
  Future<void> scheduleExerciseReminder({required TimeOfDay time}) async {
    await cancel(_exerciseReminderId);

    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      _exerciseReminderId,
      '🏃 运动时间到',
      '该起来活动活动了，坚持运动让身体更健康',
      tz.TZDateTime.from(scheduledTime, tz.local),
      _defaultDetails('exercise_reminder'),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// 调度睡眠提醒
  Future<void> scheduleSleepReminder({required TimeOfDay time}) async {
    await cancel(_sleepReminderId);

    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      _sleepReminderId,
      '🌙 该睡觉了',
      '早睡早起身体好，放下手机准备入睡吧',
      tz.TZDateTime.from(scheduledTime, tz.local),
      _defaultDetails('sleep_reminder'),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// 调度打卡提醒
  Future<void> scheduleCheckinReminder({required TimeOfDay time}) async {
    await cancel(_checkinReminderId);

    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      _checkinReminderId,
      '✅ 打卡提醒',
      '别忘了完成今天的健康打卡',
      tz.TZDateTime.from(scheduledTime, tz.local),
      _defaultDetails('checkin_reminder'),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// 取消饮水提醒
  Future<void> cancelWaterReminder() async {
    await _cancelGroup(_waterReminderBaseId, 12);
  }

  /// 取消运动提醒
  Future<void> cancelExerciseReminder() async {
    await cancel(_exerciseReminderId);
  }

  /// 取消睡眠提醒
  Future<void> cancelSleepReminder() async {
    await cancel(_sleepReminderId);
  }

  /// 取消打卡提醒
  Future<void> cancelCheckinReminder() async {
    await cancel(_checkinReminderId);
  }

  // --- IDs ---
  static const int _waterReminderBaseId = 1000;
  static const int _exerciseReminderId = 2000;
  static const int _sleepReminderId = 3000;
  static const int _checkinReminderId = 4000;

  Future<void> _cancelGroup(int baseId, int count) async {
    for (int i = 0; i < count; i++) {
      await cancel(baseId + i);
    }
  }

  NotificationDetails _defaultDetails(String channelId) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        'LifeHub Health',
        channelDescription: '健康提醒通知',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }
}
