import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/colors.dart';

/// 五维健康雷达图：运动、饮食、睡眠、心理、体重管理
class HealthRadarChart extends StatelessWidget {
  final double exerciseScore; // 0-100
  final double dietScore;
  final double sleepScore;
  final double psychologyScore;
  final double weightScore;

  const HealthRadarChart({
    super.key,
    required this.exerciseScore,
    required this.dietScore,
    required this.sleepScore,
    required this.psychologyScore,
    required this.weightScore,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.radar, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Text('健康维度分析', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: RadarChart(
                RadarChartData(
                  radarShape: RadarShape.polygon,
                  tickCount: 4,
                  ticksTextStyle: TextStyle(fontSize: 8, color: AppColors.textSecondary),
                  tickBorderData: BorderSide(color: AppColors.divider, width: 0.5),
                  gridBorderData: BorderSide(color: AppColors.divider, width: 0.5),
                  titleTextStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  getTitle: (index, angle) {
                    switch (index) {
                      case 0: return RadarChartTitle(text: '运动');
                      case 1: return RadarChartTitle(text: '饮食');
                      case 2: return RadarChartTitle(text: '睡眠');
                      case 3: return RadarChartTitle(text: '心理');
                      case 4: return RadarChartTitle(text: '体重');
                      default: return RadarChartTitle(text: '');
                    }
                  },
                  dataSets: [
                    RadarDataSet(
                      dataEntries: [
                        RadarEntry(value: exerciseScore),
                        RadarEntry(value: dietScore),
                        RadarEntry(value: sleepScore),
                        RadarEntry(value: psychologyScore),
                        RadarEntry(value: weightScore),
                      ],
                      fillColor: AppColors.primary.withOpacity(0.2),
                      borderColor: AppColors.primary,
                      borderWidth: 2,
                      entryRadius: 3,
                    ),
                  ],
                  radarBorderData: BorderSide(color: AppColors.divider),
                  titlePositionPercentageOffset: 0.15,
                ),
              ),
            ),
            SizedBox(height: 12),
            _buildScoreLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreLegend() {
    final items = [
      _ScoreItem('运动', exerciseScore, Colors.blue),
      _ScoreItem('饮食', dietScore, Colors.orange),
      _ScoreItem('睡眠', sleepScore, Colors.indigo),
      _ScoreItem('心理', psychologyScore, Colors.purple),
      _ScoreItem('体重', weightScore, Colors.teal),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: items.map((item) {
        return Column(
          children: [
            Text(
              '${item.score.toInt()}',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: item.color),
            ),
            SizedBox(height: 2),
            Text(item.label, style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          ],
        );
      }).toList(),
    );
  }
}

class _ScoreItem {
  final String label;
  final double score;
  final Color color;
  _ScoreItem(this.label, this.score, this.color);
}
