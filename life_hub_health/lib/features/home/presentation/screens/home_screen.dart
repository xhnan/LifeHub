import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../providers/home_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('首页'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(homeProvider.notifier).loadDashboard(),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(),
              SizedBox(height: 16),
              if (homeState.error != null)
                Card(
                  color: AppColors.error.withOpacity(0.1),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: AppColors.error),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            homeState.error!,
                            style: TextStyle(color: AppColors.error, fontSize: 14),
                          ),
                        ),
                        TextButton(
                          onPressed: () => ref.read(homeProvider.notifier).loadDashboard(),
                          child: Text('重试'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                _buildTodaySummary(homeState),
              SizedBox(height: 16),
              _buildQuickActions(context),
              SizedBox(height: 16),
              _buildAiAdviceCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Icon(
                Icons.person,
                size: 30,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${AppDateUtils.getGreeting()}！',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '今天也要保持健康的生活方式',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySummary(HomeState homeState) {
    final summary = homeState.todaySummary;
    final weight = homeState.latestWeight;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '今日概览',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16),
            homeState.isLoading
                ? Center(child: CircularProgressIndicator())
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryItem(
                        Icons.directions_walk,
                        '步数',
                        '${summary?.totalSteps ?? 0}',
                      ),
                      _buildSummaryItem(
                        Icons.local_fire_department,
                        '卡路里',
                        '${summary?.activeCaloriesKcal ?? 0} kcal',
                      ),
                      _buildSummaryItem(
                        Icons.timer,
                        '活动',
                        '${summary?.activeMinutes ?? 0} 分钟',
                      ),
                      _buildSummaryItem(
                        Icons.water_drop,
                        '体重',
                        weight != null ? '${weight.weightKg} kg' : '-- kg',
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 28),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            context: context,
            icon: Icons.restaurant,
            label: '记录饮食',
            color: Colors.orange,
            onTap: () => context.push('/health-data/add-diet'),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            context: context,
            icon: Icons.fitness_center,
            label: '记录运动',
            color: Colors.blue,
            onTap: () => context.push('/health-data/add-activity'),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            context: context,
            icon: Icons.monitor_weight,
            label: '记录体重',
            color: Colors.green,
            onTap: () => context.push('/health-data/add-weight'),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAiAdviceCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'AI 建议',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              '开始记录您的健康数据，AI 将为您提供个性化建议。',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
