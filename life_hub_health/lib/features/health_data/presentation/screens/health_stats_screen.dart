import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/models/weight_log.dart';
import '../../../../shared/models/daily_summary.dart';
import '../../../../shared/models/diet_log.dart';
import '../../../../shared/providers/providers.dart';
import '../../data/repositories/health_stats_repository.dart';

final _healthStatsRepoProvider = Provider((ref) {
  return HealthStatsRepository(ref.read(apiServiceProvider));
});

/// 健康数据统计可视化页面
class HealthStatsScreen extends ConsumerStatefulWidget {
  const HealthStatsScreen({super.key});

  @override
  ConsumerState<HealthStatsScreen> createState() => _HealthStatsScreenState();
}

class _HealthStatsScreenState extends ConsumerState<HealthStatsScreen> {
  bool _isLoading = true;
  List<WeightLog> _weightLogs = [];
  List<DailySummary> _summaries = [];
  List<DietLog> _dietLogs = [];
  int _days = 7;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(_healthStatsRepoProvider);
      final results = await Future.wait([
        repo.getWeightRange(_days),
        repo.getSummaryRange(_days),
        repo.getMyDietLogs(),
      ]);

      setState(() {
        _weightLogs = results[0] as List<WeightLog>;
        _summaries = results[1] as List<DailySummary>;
        _dietLogs = results[2] as List<DietLog>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('数据统计')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildPeriodSelector(),
                  SizedBox(height: 16),
                  _buildWeightTrendCard(),
                  SizedBox(height: 16),
                  _buildCalorieBalanceCard(),
                  SizedBox(height: 16),
                  _buildActivitySummaryCard(),
                  SizedBox(height: 16),
                  _buildNutritionPieChart(),
                ],
              ),
            ),
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      children: [7, 14, 30].map((d) {
        final isSelected = _days == d;
        return Padding(
          padding: EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text('${d}天'),
            selected: isSelected,
            selectedColor: AppColors.primary,
            labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary),
            onSelected: (s) {
              if (s) {
                setState(() => _days = d);
                _loadData();
              }
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWeightTrendCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.show_chart, color: Colors.teal, size: 20),
                SizedBox(width: 8),
                Text('体重趋势', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 16),
            if (_weightLogs.length < 2)
              Center(child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('数据不足', style: TextStyle(color: AppColors.textSecondary)),
              ))
            else
              SizedBox(height: 180, child: LineChart(_weightLineData())),
            if (_weightLogs.length >= 2) ...[
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('最低：${_weightLogs.map((w) => w.weightKg).reduce((a, b) => a < b ? a : b).toStringAsFixed(1)} kg',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  Text('最高：${_weightLogs.map((w) => w.weightKg).reduce((a, b) => a > b ? a : b).toStringAsFixed(1)} kg',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  LineChartData _weightLineData() {
    final spots = <FlSpot>[];
    for (int i = 0; i < _weightLogs.length; i++) {
      spots.add(FlSpot(i.toDouble(), _weightLogs[i].weightKg));
    }
    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 1;
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 1;

    return LineChartData(
      gridData: FlGridData(show: true, drawVerticalLine: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: (_weightLogs.length / 5).ceilToDouble().clamp(1, double.infinity),
            getTitlesWidget: (value, meta) {
              final idx = value.toInt();
              if (idx >= 0 && idx < _weightLogs.length) {
                return Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(AppDateUtils.formatMonthDay(_weightLogs[idx].recordDate),
                      style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                );
              }
              return Text('');
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.teal,
          barWidth: 2.5,
          dotData: FlDotData(show: spots.length <= 14),
          belowBarData: BarAreaData(show: true, color: Colors.teal.withOpacity(0.1)),
        ),
      ],
      minY: minY,
      maxY: maxY,
    );
  }

  Widget _buildCalorieBalanceCard() {
    final intake = _dietLogs.fold<double>(0, (sum, log) => sum + (log.totalCalories ?? 0));
    final burned = _summaries.fold<double>(0, (sum, s) => sum + s.activeCaloriesKcal);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.balance, color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Text('卡路里收支', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildCalorieItem('摄入', intake.toInt(), Colors.orange, Icons.restaurant)),
                SizedBox(width: 12),
                Expanded(child: _buildCalorieItem('消耗', burned.toInt(), Colors.green, Icons.local_fire_department)),
                SizedBox(width: 12),
                Expanded(child: _buildCalorieItem('净值', (intake - burned).toInt(),
                    intake > burned ? Colors.red : Colors.green, Icons.show_chart)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieItem(String label, int value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        SizedBox(height: 8),
        Text('$value', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        SizedBox(height: 4),
        Text('$label kcal', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildActivitySummaryCard() {
    final totalSteps = _summaries.fold<int>(0, (sum, s) => sum + s.totalSteps);
    final totalMinutes = _summaries.fold<int>(0, (sum, s) => sum + s.activeMinutes);
    final totalDistance = _summaries.fold<double>(0, (sum, s) => sum + s.totalDistanceMeters);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.directions_run, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                Text('运动汇总（$_days天）', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatBox('总步数', '$totalSteps', Colors.blue)),
                Expanded(child: _buildStatBox('运动时长', AppDateUtils.formatDuration(totalMinutes), Colors.green)),
                Expanded(child: _buildStatBox('总距离', '${(totalDistance / 1000).toStringAsFixed(1)} km', Colors.purple)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildNutritionPieChart() {
    final totalProtein = _dietLogs.fold<double>(0, (sum, l) => sum + (l.proteinG ?? 0));
    final totalCarbs = _dietLogs.fold<double>(0, (sum, l) => sum + (l.carbsG ?? 0));
    final totalFat = _dietLogs.fold<double>(0, (sum, l) => sum + (l.fatG ?? 0));
    final total = totalProtein + totalCarbs + totalFat;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pie_chart, color: Colors.purple, size: 20),
                SizedBox(width: 8),
                Text('营养摄入分布', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 16),
            if (total == 0)
              Center(child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('暂无营养数据', style: TextStyle(color: AppColors.textSecondary)),
              ))
            else
              Row(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: PieChart(PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 30,
                      sections: [
                        PieChartSectionData(
                          value: totalProtein, color: Colors.red.shade300,
                          title: '${(totalProtein / total * 100).toInt()}%',
                          titleStyle: TextStyle(fontSize: 10, color: Colors.white), radius: 25,
                        ),
                        PieChartSectionData(
                          value: totalCarbs, color: Colors.blue.shade300,
                          title: '${(totalCarbs / total * 100).toInt()}%',
                          titleStyle: TextStyle(fontSize: 10, color: Colors.white), radius: 25,
                        ),
                        PieChartSectionData(
                          value: totalFat, color: Colors.amber.shade300,
                          title: '${(totalFat / total * 100).toInt()}%',
                          titleStyle: TextStyle(fontSize: 10, color: Colors.white), radius: 25,
                        ),
                      ],
                    )),
                  ),
                  SizedBox(width: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegend('蛋白质', '${totalProtein.toInt()}g', Colors.red.shade300),
                      SizedBox(height: 8),
                      _buildLegend('碳水', '${totalCarbs.toInt()}g', Colors.blue.shade300),
                      SizedBox(height: 8),
                      _buildLegend('脂肪', '${totalFat.toInt()}g', Colors.amber.shade300),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(String label, String value, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        SizedBox(width: 8),
        Text('$label: $value', style: TextStyle(fontSize: 13)),
      ],
    );
  }
}
