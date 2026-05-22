import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../providers/health_data_provider.dart';
import '../widgets/activity_card.dart';
import '../widgets/diet_card.dart';
import '../widgets/weight_chart.dart';
import '../widgets/summary_chart.dart';

class HealthDataScreen extends ConsumerStatefulWidget {
  const HealthDataScreen({super.key});

  @override
  ConsumerState<HealthDataScreen> createState() => _HealthDataScreenState();
}

class _HealthDataScreenState extends ConsumerState<HealthDataScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(healthDataProvider.notifier).loadAll();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('添加记录', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            ListTile(
              leading: CircleAvatar(backgroundColor: Colors.blue.withOpacity(0.1), child: Icon(Icons.directions_run, color: Colors.blue)),
              title: Text('运动记录'),
              onTap: () { Navigator.pop(context); context.push('/health-data/add-activity'); },
            ),
            ListTile(
              leading: CircleAvatar(backgroundColor: Colors.orange.withOpacity(0.1), child: Icon(Icons.restaurant, color: Colors.orange)),
              title: Text('饮食记录'),
              onTap: () { Navigator.pop(context); context.push('/health-data/add-diet'); },
            ),
            ListTile(
              leading: CircleAvatar(backgroundColor: Colors.green.withOpacity(0.1), child: Icon(Icons.monitor_weight, color: Colors.green)),
              title: Text('体重记录'),
              onTap: () { Navigator.pop(context); context.push('/health-data/add-weight'); },
            ),
            ListTile(
              leading: CircleAvatar(backgroundColor: Colors.indigo.withOpacity(0.1), child: Icon(Icons.bedtime, color: Colors.indigo)),
              title: Text('睡眠记录'),
              onTap: () { Navigator.pop(context); context.push('/profile/sleep/add'); },
            ),
            ListTile(
              leading: CircleAvatar(backgroundColor: Colors.blue.withOpacity(0.1), child: Icon(Icons.water_drop, color: Colors.blue)),
              title: Text('饮水记录'),
              onTap: () { Navigator.pop(context); context.push('/profile/water'); },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(healthDataProvider);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('健康数据'),
          actions: [
            IconButton(
              icon: Icon(Icons.bar_chart),
              tooltip: '数据统计',
              onPressed: () => context.push('/health-data/stats'),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: '运动'),
              Tab(text: '饮食'),
              Tab(text: '体重'),
              Tab(text: '汇总'),
            ],
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
          ),
        ),
        body: state.error != null && state.activities.isEmpty && state.dietLogs.isEmpty && state.weightLogs.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: AppColors.error),
                    SizedBox(height: 16),
                    Text(state.error!, style: TextStyle(fontSize: 14, color: AppColors.error), textAlign: TextAlign.center),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.read(healthDataProvider.notifier).loadAll(),
                      child: Text('重试'),
                    ),
                  ],
                ),
              )
            : state.isLoading && state.activities.isEmpty
                ? Center(child: CircularProgressIndicator())
                : TabBarView(
                controller: _tabController,
                children: [
                  _buildActivitiesTab(state),
                  _buildDietTab(state),
                  _buildWeightTab(state),
                  _buildSummaryTab(state),
                ],
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddOptions,
          backgroundColor: AppColors.primary,
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildActivitiesTab(HealthDataState state) {
    if (state.activities.isEmpty) {
      return _buildEmptyState(Icons.directions_run, '暂无运动记录', '点击右下角按钮添加');
    }
    return RefreshIndicator(
      onRefresh: () => ref.read(healthDataProvider.notifier).loadAll(),
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: state.activities.length,
        itemBuilder: (context, index) => ActivityCard(activity: state.activities[index]),
      ),
    );
  }

  Widget _buildDietTab(HealthDataState state) {
    if (state.dietLogs.isEmpty) {
      return _buildEmptyState(Icons.restaurant, '暂无饮食记录', '点击右下角按钮添加');
    }
    return RefreshIndicator(
      onRefresh: () => ref.read(healthDataProvider.notifier).loadAll(),
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: state.dietLogs.length,
        itemBuilder: (context, index) => DietCard(dietLog: state.dietLogs[index]),
      ),
    );
  }

  Widget _buildWeightTab(HealthDataState state) {
    if (state.weightLogs.isEmpty) {
      return _buildEmptyState(Icons.monitor_weight, '暂无体重记录', '点击右下角按钮添加');
    }
    return RefreshIndicator(
      onRefresh: () => ref.read(healthDataProvider.notifier).loadAll(),
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('体重趋势', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  WeightChart(weightLogs: state.weightLogs),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          ...state.weightLogs.map((log) => Card(
            margin: EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(Icons.monitor_weight, color: AppColors.primary),
              title: Text('${log.weightKg.toStringAsFixed(1)} kg'),
              subtitle: Text('${log.recordDate.month}/${log.recordDate.day}'),
              trailing: log.bodyFatPercentage != null
                  ? Text('${log.bodyFatPercentage!.toStringAsFixed(1)}%', style: TextStyle(color: AppColors.textSecondary))
                  : null,
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSummaryTab(HealthDataState state) {
    if (state.todaySummary == null) {
      return _buildEmptyState(Icons.summarize, '暂无汇总数据', '开始记录健康数据后查看');
    }
    return RefreshIndicator(
      onRefresh: () => ref.read(healthDataProvider.notifier).loadAll(),
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('今日概览', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryItem(Icons.directions_walk, '步数', '${state.todaySummary!.totalSteps}'),
                      _buildSummaryItem(Icons.local_fire_department, '卡路里', '${state.todaySummary!.activeCaloriesKcal.toStringAsFixed(0)} kcal'),
                      _buildSummaryItem(Icons.timer, '活动', '${state.todaySummary!.activeMinutes} 分钟'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('步数趋势', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  if (state.summaryHistory.isNotEmpty)
                    SummaryChart(summaries: state.summaryHistory)
                  else
                    SummaryChart(summaries: [state.todaySummary!]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 28),
        SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildEmptyState(IconData icon, String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textSecondary),
          SizedBox(height: 16),
          Text(title, style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
          SizedBox(height: 8),
          Text(subtitle, style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
