import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../shared/providers/providers.dart';
import '../providers/home_provider.dart';
import '../widgets/ai_advice_card.dart';
import '../widgets/ai_analyze_button.dart';
import '../widgets/checkin_progress_card.dart';
import '../widgets/mini_trend_chart.dart';
import '../widgets/quick_mood_card.dart';
import '../../../water/presentation/screens/water_screen.dart';
import '../../../sleep/presentation/screens/sleep_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('LifeHub Health'),
        centerTitle: false,
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
        child: homeState.isLoading && homeState.todaySummary == null
            ? HomeSkeleton()
            : SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 欢迎卡片
                    _buildWelcomeCard(),
                    const SizedBox(height: 14),

                    // 错误提示
                    if (homeState.error != null) ...[
                      _buildErrorBanner(homeState.error!, ref),
                      const SizedBox(height: 14),
                    ],

                    // 今日概览
                    _buildTodaySummary(homeState),
                    const SizedBox(height: 14),

                    // 快捷操作
                    _buildQuickActions(context),
                    const SizedBox(height: 14),

                    // 今日心情快捷记录
                    QuickMoodCard(
                      hasMoodToday: homeState.hasMoodToday,
                      todayMoodScore: homeState.latestMood?.moodScore,
                      onMoodSelected: (score) => _onQuickMood(context, ref, score),
                    ),
                    const SizedBox(height: 14),

                    // 打卡进度
                    CheckinProgressCard(
                      todayCheckins: homeState.todayCheckins,
                      activePlans: homeState.activePlans,
                      completionRate: homeState.checkinCompletionRate,
                      onTap: () => context.push('/profile/checkin'),
                    ),
                    const SizedBox(height: 14),

                    // 7天趋势
                    MiniTrendChart(
                      weightTrend: homeState.weightTrend,
                      moodTrend: homeState.moodTrend,
                    ),
                    const SizedBox(height: 14),

                    // AI 建议
                    AiAdviceCard(
                      adviceList: homeState.activeAdvice,
                      onViewAll: () => context.push('/profile/advice-records'),
                    ),
                    const SizedBox(height: 14),

                    // AI 综合分析触发
                    const AiAnalyzeButton(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [AppColors.primary.withOpacity(0.1), AppColors.primaryDark.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.primary.withOpacity(0.2),
              child: Icon(Icons.person, size: 26, color: AppColors.primary),
            ),
            SizedBox(width: 14),
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
                    AppDateUtils.formatFull(DateTime.now()).split(' ')[0],
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String error, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(error, style: TextStyle(color: AppColors.error, fontSize: 13)),
          ),
          TextButton(
            onPressed: () => ref.read(homeProvider.notifier).loadDashboard(),
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            ),
            child: Text('重试', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySummary(HomeState homeState) {
    final summary = homeState.todaySummary;
    final weight = homeState.latestWeight;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.dashboard, size: 18, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  '今日概览',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    icon: Icons.directions_walk,
                    color: Colors.blue,
                    value: '${summary?.totalSteps ?? 0}',
                    label: '步数',
                  ),
                ),
                Expanded(
                  child: _buildMetricTile(
                    icon: Icons.local_fire_department,
                    color: Colors.orange,
                    value: '${(summary?.activeCaloriesKcal ?? 0).toInt()}',
                    label: '千卡',
                  ),
                ),
                Expanded(
                  child: _buildMetricTile(
                    icon: Icons.timer,
                    color: AppColors.primary,
                    value: '${summary?.activeMinutes ?? 0}',
                    label: '分钟',
                  ),
                ),
                Expanded(
                  child: _buildMetricTile(
                    icon: Icons.monitor_weight_outlined,
                    color: Colors.teal,
                    value: weight != null ? weight.weightKg.toStringAsFixed(1) : '--',
                    label: 'kg',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionChip(
            context: context,
            icon: Icons.restaurant,
            label: '饮食',
            color: Colors.orange,
            onTap: () => context.push('/health-data/add-diet'),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _buildActionChip(
            context: context,
            icon: Icons.fitness_center,
            label: '运动',
            color: Colors.blue,
            onTap: () => context.push('/health-data/add-activity'),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _buildActionChip(
            context: context,
            icon: Icons.water_drop,
            label: '饮水',
            color: Colors.cyan,
            onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const WaterScreen())),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _buildActionChip(
            context: context,
            icon: Icons.bedtime,
            label: '睡眠',
            color: Colors.indigo,
            onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const SleepScreen())),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _buildActionChip(
            context: context,
            icon: Icons.chat_bubble_outline,
            label: 'AI',
            color: AppColors.secondary,
            onTap: () => context.go('/ai-chat'),
          ),
        ),
      ],
    );
  }

  Widget _buildActionChip({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Icon(icon, color: color, size: 26),
              SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(fontSize: 11, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onQuickMood(BuildContext context, WidgetRef ref, int score) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.post('/health/psychology/daily-moods', data: {
        'moodScore': score,
      });
      // 刷新首页数据
      await ref.read(homeProvider.notifier).loadDashboard();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('心情已记录 ✓'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('记录失败，请稍后重试'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
