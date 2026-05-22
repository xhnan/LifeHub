import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/models/daily_mood.dart';

/// 心情热力日历 — 按日显示颜色深浅
class MoodHeatmapCalendar extends StatelessWidget {
  final List<DailyMood> moods;
  final DateTime month;

  const MoodHeatmapCalendar({
    super.key,
    required this.moods,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7; // 0=Sunday

    // Build mood map: day -> score
    final moodMap = <int, int>{};
    for (final mood in moods) {
      if (mood.recordDate.year == month.year && mood.recordDate.month == month.month) {
        moodMap[mood.recordDate.day] = mood.moodScore;
      }
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_month, color: AppColors.secondary, size: 20),
                SizedBox(width: 8),
                Text(
                  '${month.year}年${month.month}月 心情日历',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 12),
            // 星期标题
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['日', '一', '二', '三', '四', '五', '六']
                  .map((d) => SizedBox(
                        width: 32,
                        child: Center(
                          child: Text(d, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ),
                      ))
                  .toList(),
            ),
            SizedBox(height: 8),
            // 日历格子
            ...List.generate(((daysInMonth + startWeekday) / 7).ceil(), (week) {
              return Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(7, (weekday) {
                    final dayIndex = week * 7 + weekday - startWeekday + 1;
                    if (dayIndex < 1 || dayIndex > daysInMonth) {
                      return SizedBox(width: 32, height: 32);
                    }
                    final score = moodMap[dayIndex];
                    return _buildDayCell(dayIndex, score);
                  }),
                ),
              );
            }),
            SizedBox(height: 12),
            // 图例
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('低', _getMoodColor(2)),
                SizedBox(width: 12),
                _buildLegendItem('中', _getMoodColor(5)),
                SizedBox(width: 12),
                _buildLegendItem('高', _getMoodColor(8)),
                SizedBox(width: 12),
                _buildLegendItem('无', Colors.grey.shade200),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCell(int day, int? score) {
    final today = DateTime.now();
    final isToday = today.year == month.year && today.month == month.month && today.day == day;

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: score != null ? _getMoodColor(score) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
        border: isToday ? Border.all(color: AppColors.primary, width: 2) : null,
      ),
      child: Center(
        child: Text(
          '$day',
          style: TextStyle(
            fontSize: 11,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            color: score != null && score >= 6 ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }

  Color _getMoodColor(int score) {
    if (score >= 8) return Colors.green.shade600;
    if (score >= 6) return Colors.green.shade300;
    if (score >= 4) return Colors.amber.shade300;
    if (score >= 2) return Colors.orange.shade300;
    return Colors.red.shade300;
  }
}
