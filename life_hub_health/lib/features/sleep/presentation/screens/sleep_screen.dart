import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/models/sleep_log.dart';
import '../providers/sleep_provider.dart';
import 'add_sleep_screen.dart';

class SleepScreen extends ConsumerWidget {
  const SleepScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sleepProvider);

    return Scaffold(
      appBar: AppBar(title: Text('睡眠追踪')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddSleepScreen()),
        ),
        backgroundColor: Colors.indigo,
        child: Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(sleepProvider.notifier).loadData(),
        child: state.isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCard(state),
                    SizedBox(height: 16),
                    _buildTrendChart(state.sleepLogs),
                    SizedBox(height: 16),
                    _buildRecentLogs(state.sleepLogs),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSummaryCard(SleepState state) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                icon: Icons.bedtime,
                label: '最近睡眠',
                value: state.latestLog?.durationFormatted ?? '--',
                color: Colors.indigo,
              ),
            ),
            Expanded(
              child: _buildStatItem(
                icon: Icons.timer,
                label: '平均时长',
                value: '${(state.averageDuration / 60).toStringAsFixed(1)}h',
                color: Colors.blue,
              ),
            ),
            Expanded(
              child: _buildStatItem(
                icon: Icons.star,
                label: '平均质量',
                value: '${state.averageQuality.toStringAsFixed(1)}/10',
                color: Colors.amber,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildTrendChart(List<SleepLog> logs) {
    final recentLogs = logs.take(7).toList().reversed.toList();
    if (recentLogs.length < 2) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('需要至少2条记录显示趋势图', style: TextStyle(color: AppColors.textSecondary))),
        ),
      );
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('睡眠时长趋势', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx >= 0 && idx < recentLogs.length) {
                            return Text(
                              AppDateUtils.formatMonthDay(recentLogs[idx].sleepDate),
                              style: TextStyle(fontSize: 9, color: AppColors.textSecondary),
                            );
                          }
                          return Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(recentLogs.length, (i) {
                    final hours = (recentLogs[i].durationMinutes ?? 0) / 60.0;
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: hours,
                          color: hours >= 7 ? Colors.indigo : Colors.orange,
                          width: 16,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentLogs(List<SleepLog> logs) {
    if (logs.isEmpty) {
      return Center(child: Text('暂无睡眠记录', style: TextStyle(color: AppColors.textSecondary)));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('最近记录', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        ...logs.take(10).map((log) => _buildLogTile(log)),
      ],
    );
  }

  Widget _buildLogTile(SleepLog log) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(Icons.nights_stay, color: Colors.indigo),
        title: Text(AppDateUtils.formatDate(log.sleepDate)),
        subtitle: Text(
          '时长：${log.durationFormatted}  质量：${log.qualityLabel}',
          style: TextStyle(fontSize: 12),
        ),
        trailing: log.qualityScore != null
            ? Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getQualityColor(log.qualityScore!).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${log.qualityScore}/10',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getQualityColor(log.qualityScore!),
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Color _getQualityColor(int score) {
    if (score >= 8) return AppColors.success;
    if (score >= 5) return AppColors.warning;
    return AppColors.error;
  }
}
