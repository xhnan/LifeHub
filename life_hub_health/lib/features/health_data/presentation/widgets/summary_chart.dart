import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/models/daily_summary.dart';

class SummaryChart extends StatelessWidget {
  final List<DailySummary> summaries;

  const SummaryChart({super.key, required this.summaries});

  @override
  Widget build(BuildContext context) {
    if (summaries.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            '暂无汇总数据',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final sorted = List<DailySummary>.from(summaries)
      ..sort((a, b) => a.recordDate.compareTo(b.recordDate));
    final last7 = sorted.length > 7 ? sorted.sublist(sorted.length - 7) : sorted;

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: last7.map((s) => s.totalSteps).reduce((a, b) => a > b ? a : b).toDouble() * 1.2,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.divider,
              strokeWidth: 0.5,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45,
                getTitlesWidget: (value, meta) => Text(
                  '${(value / 1000).toStringAsFixed(0)}k',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= last7.length) return SizedBox();
                  return Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      '${last7[idx].recordDate.month}/${last7[idx].recordDate.day}',
                      style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    ),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: last7.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.totalSteps.toDouble(),
                  color: AppColors.primary,
                  width: 20,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }).toList(),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final summary = last7[group.x];
                return BarTooltipItem(
                  '${summary.totalSteps} 步\n${summary.activeCaloriesKcal.toStringAsFixed(0)} kcal',
                  TextStyle(color: Colors.white, fontSize: 12),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
