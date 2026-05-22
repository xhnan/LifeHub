import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/models/health_report.dart';
import '../../../../shared/providers/providers.dart';
import '../widgets/health_radar_chart.dart';

class HealthReportScreen extends ConsumerStatefulWidget {
  const HealthReportScreen({super.key});

  @override
  ConsumerState<HealthReportScreen> createState() => _HealthReportScreenState();
}

class _HealthReportScreenState extends ConsumerState<HealthReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  HealthReport? _weeklyReport;
  HealthReport? _monthlyReport;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadReports();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final api = ref.read(apiServiceProvider);
      final results = await Future.wait([
        api.get('/health/agent/reports', queryParameters: {'period': 'weekly'}),
        api.get('/health/agent/reports', queryParameters: {'period': 'monthly'}),
      ]);

      setState(() {
        if (results[0].data['success'] == true && results[0].data['data'] != null) {
          _weeklyReport = HealthReport.fromJson(results[0].data['data']);
        }
        if (results[1].data['success'] == true && results[1].data['data'] != null) {
          _monthlyReport = HealthReport.fromJson(results[1].data['data']);
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = '生成报告失败：$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.auto_awesome, size: 18),
            SizedBox(width: 8),
            Text('AI 健康报告'),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [Tab(text: '周报'), Tab(text: '月报')],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadReports,
            tooltip: '重新生成',
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoading()
          : _error != null
              ? _buildError()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildReport(_weeklyReport, '本周'),
                    _buildReport(_monthlyReport, '本月'),
                  ],
                ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('AI 正在生成报告...', style: TextStyle(color: AppColors.textSecondary)),
          SizedBox(height: 4),
          Text('数据聚合 + AI 解读，预计 5-10 秒',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          SizedBox(height: 12),
          Text(_error ?? '加载失败', style: TextStyle(color: AppColors.error)),
          SizedBox(height: 16),
          ElevatedButton(onPressed: _loadReports, child: Text('重试')),
        ],
      ),
    );
  }

  Widget _buildReport(HealthReport? report, String period) {
    if (report == null) {
      return Center(
        child: Text('暂无$period报告', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReports,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverallCard(report),
            SizedBox(height: 16),
            if (report.aiNarrative != null && report.aiNarrative!.isNotEmpty)
              _buildAiNarrativeCard(report.aiNarrative!),
            if (report.aiNarrative != null && report.aiNarrative!.isNotEmpty)
              SizedBox(height: 16),
            HealthRadarChart(
              exerciseScore: (report.scores.exercise ?? 0).toDouble(),
              dietScore: (report.scores.diet ?? 0).toDouble(),
              sleepScore: (report.scores.sleep ?? 0).toDouble(),
              psychologyScore: (report.scores.psychology ?? 0).toDouble(),
              weightScore: (report.scores.weight ?? 0).toDouble(),
            ),
            SizedBox(height: 16),
            if (report.keyInsights != null && report.keyInsights!.isNotEmpty)
              _buildInsightsCard('关键洞察', report.keyInsights!, Icons.lightbulb_outline, Colors.amber),
            if (report.keyInsights != null && report.keyInsights!.isNotEmpty)
              SizedBox(height: 16),
            if (report.recommendations != null && report.recommendations!.isNotEmpty)
              _buildInsightsCard('AI 建议', report.recommendations!, Icons.tips_and_updates, AppColors.primary),
            if (report.recommendations != null && report.recommendations!.isNotEmpty)
              SizedBox(height: 16),
            _buildMetricsCard(report.metrics, period),
            SizedBox(height: 16),
            if (report.trends != null) _buildTrendCard(report.trends!),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallCard(HealthReport report) {
    final score = report.overallScore;
    final color = _scoreColor(score);
    final comment = _scoreComment(score);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.15), color.withOpacity(0.03)],
          ),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text('${AppDateUtils.formatDate(report.startDate)} ~ ${AppDateUtils.formatDate(report.endDate)}',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('$score', style: TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: color)),
                Padding(
                  padding: EdgeInsets.only(bottom: 12, left: 4),
                  child: Text('/ 100', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                ),
              ],
            ),
            Text(comment, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildAiNarrativeCard(String narrative) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.auto_awesome, color: AppColors.secondary, size: 16),
                ),
                SizedBox(width: 8),
                Text('AI 解读', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 12),
            Text(
              narrative,
              style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsCard(String title, List<String> items, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 18),
                SizedBox(width: 8),
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 12),
            ...items.map((item) => Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 6),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(item, style: TextStyle(fontSize: 13, height: 1.5)),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsCard(ReportMetrics m, String period) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart, color: AppColors.primary, size: 18),
                SizedBox(width: 8),
                Text('$period数据', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 12),
            _metricRow('总步数', '${m.totalSteps ?? 0} 步'),
            _metricRow('运动时长', '${m.totalActiveMinutes ?? 0} 分钟（${m.activityCount ?? 0} 次）'),
            _metricRow('消耗卡路里', '${m.totalActiveCalories?.toStringAsFixed(0) ?? '0'} kcal'),
            _metricRow('饮食记录', '${m.dietLogCount ?? 0} 次（平均 ${m.avgCaloriesIntake?.toStringAsFixed(0) ?? '0'} kcal）'),
            _metricRow('当前体重', m.currentWeight != null ? '${m.currentWeight!.toStringAsFixed(1)} kg' : '--'),
            _metricRow('体重变化',
                m.weightChange != null ? '${m.weightChange! > 0 ? '+' : ''}${m.weightChange!.toStringAsFixed(1)} kg' : '--'),
            _metricRow('心情记录', '${m.moodLogCount ?? 0} 次（平均 ${m.avgMoodScore?.toStringAsFixed(1) ?? '--'} / 10）'),
            _metricRow('睡眠时长', m.avgSleepHours != null && m.avgSleepHours! > 0 ? '平均 ${m.avgSleepHours!.toStringAsFixed(1)} 小时' : '无记录'),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendCard(TrendComparison trends) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: Colors.purple, size: 18),
                SizedBox(width: 8),
                Text('对比上个周期', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 12),
            _trendRow('步数', trends.stepsTrend, '${trends.stepsChangePercent?.toStringAsFixed(1) ?? '0'}%'),
            _trendRow('心情', trends.moodTrend, '${trends.moodChangePercent?.toStringAsFixed(1) ?? '0'}%'),
            _trendRow('体重', trends.weightTrend,
                trends.weightChangeKg != null ? '${trends.weightChangeKg! > 0 ? '+' : ''}${trends.weightChangeKg!.toStringAsFixed(1)} kg' : '--'),
          ],
        ),
      ),
    );
  }

  Widget _metricRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _trendRow(String label, String? trend, String value) {
    IconData icon;
    Color color;
    switch (trend) {
      case 'up':
        icon = Icons.arrow_upward;
        color = Colors.green;
        break;
      case 'down':
        icon = Icons.arrow_downward;
        color = Colors.red;
        break;
      default:
        icon = Icons.remove;
        color = AppColors.textSecondary;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              SizedBox(width: 4),
              Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
            ],
          ),
        ],
      ),
    );
  }

  Color _scoreColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.primary;
    if (score >= 40) return AppColors.warning;
    return AppColors.error;
  }

  String _scoreComment(int score) {
    if (score >= 85) return '表现优秀，继续保持 💪';
    if (score >= 70) return '状态不错，还有提升空间';
    if (score >= 50) return '基础尚可，多记录多运动';
    return '需要关注健康，重新出发';
  }
}
