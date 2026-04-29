import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/models/weight_log.dart';

class WeightChart extends StatelessWidget {
  final List<WeightLog> weightLogs;

  const WeightChart({super.key, required this.weightLogs});

  @override
  Widget build(BuildContext context) {
    if (weightLogs.length < 2) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            '需要至少 2 条记录才能显示趋势',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final sorted = List<WeightLog>.from(weightLogs)
      ..sort((a, b) => a.recordDate.compareTo(b.recordDate));
    final spots = <FlSpot>[];
    for (var i = 0; i < sorted.length; i++) {
      spots.add(FlSpot(i.toDouble(), sorted[i].weightKg));
    }

    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 2;
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 2;

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: ((maxY - minY) / 4).ceilToDouble(),
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.divider,
              strokeWidth: 0.5,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => Text(
                  '${value.toStringAsFixed(1)}',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= sorted.length) return SizedBox();
                  if (idx % ((sorted.length / 5).ceil()) != 0 && idx != sorted.length - 1) return SizedBox();
                  return Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      '${sorted[idx].recordDate.month}/${sorted[idx].recordDate.day}',
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
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.primary,
              barWidth: 2.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(radius: 3, color: AppColors.primary),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withOpacity(0.1),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots.map((spot) {
                final log = sorted[spot.spotIndex];
                return LineTooltipItem(
                  '${log.weightKg.toStringAsFixed(1)} kg',
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
