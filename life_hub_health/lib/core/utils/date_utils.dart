import 'package:intl/intl.dart';

class AppDateUtils {
  static final DateFormat _dateFmt = DateFormat('yyyy-MM-dd');
  static final DateFormat _dateTimeFmt = DateFormat('yyyy-MM-dd HH:mm');
  static final DateFormat _timeFmt = DateFormat('HH:mm');
  static final DateFormat _monthDayFmt = DateFormat('MM/dd');
  static final DateFormat _fullFmt = DateFormat('yyyy年MM月dd日 HH:mm');

  static String formatDate(DateTime date) => _dateFmt.format(date);

  static String formatDateTime(DateTime date) => _dateTimeFmt.format(date);

  static String formatTime(DateTime date) => _timeFmt.format(date);

  static String formatMonthDay(DateTime date) => _monthDayFmt.format(date);

  static String formatFull(DateTime date) => _fullFmt.format(date);

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}周前';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}个月前';
    return '${(diff.inDays / 365).floor()}年前';
  }

  static String formatDuration(int minutes) {
    if (minutes < 60) return '$minutes分钟';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) return '$hours小时';
    return '$hours小时$mins分钟';
  }

  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return '凌晨好';
    if (hour < 12) return '早上好';
    if (hour < 14) return '中午好';
    if (hour < 18) return '下午好';
    return '晚上好';
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static DateTime today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
}
