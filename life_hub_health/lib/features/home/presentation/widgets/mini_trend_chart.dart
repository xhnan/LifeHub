import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/models/weight_log.dart';
import '../../../../shared/models/daily_mood.dart';

class MiniTrendChart extends StatelessWidget {
  final List<WeightLog> weightTrend;
  final List<DailyMood> moodTrend;

  const MiniTrendChart({
    super.key,
    required this.weightTrend,
    required this.moodTrend,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '7 天趋势',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildWeightChart()),
                const SizedBox(width: 16),
                Expanded(child: _buildMoodChart()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightChart() {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '体重 (kg)',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: weightTrend.length < 2
              ? Center(
                  child: Text(
                    '数据不足',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                )
              : LineChart(_buildWeightLineChart()),
        ),
        if (weightTrend.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            '${weightTrend.last.weightKg.toStringAsFixed(1)} kg',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMoodChart() {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '心情',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: moodTrend.length < 2
              ? Center(
                  child: Text(
                    '数据不足',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                )
              : LineChart(_buildMoodLineChart()),
        ),
        if (moodTrend.isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _getMoodEmoji(moodTrend.last.moodScore),
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 4),
              Text(
                '${moodTrend.last.moodScore}/10',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  LineChartData _buildWeightLineChart() {
    final spots = <FlSpot>[];
    for (int i = 0; i < weightTrend.length; i++) {
      spots.add(FlSpot(i.toDouble(), weightTrend[i].weightKg));
    }

    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 0.5;
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 0.5;

    return LineChartData(
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineTouchData: LineTouchData(enabled: false),
      minY: minY,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: AppColors.primary,
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.primary.withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  LineChartData _buildMoodLineChart() {
    final spots = <FlSpot>[];
    for (int i = 0; i < moodTrend.length; i++) {
      spots.add(FlSpot(i.toDouble(), moodTrend[i].moodScore.toDouble()));
    }

    return LineChartData(
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineTouchData: LineTouchData(enabled: false),
      minY: 0,
      maxY: 10,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: AppColors.secondary,
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.secondary.withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  String _getMoodEmoji(int score) {
    if (score >= 9) return '😄';
    if (score >= 7) return '😊';
    if (score >= 5) return '😐';
    if (score >= 3) return '😔';
    return '😢';
  }
}
