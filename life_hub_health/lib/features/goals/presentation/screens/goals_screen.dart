import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/models/health_goal.dart';
import '../providers/goals_provider.dart';
import 'add_goal_screen.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(goalsProvider);

    return Scaffold(
      appBar: AppBar(title: Text('健康目标')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddGoalScreen()),
        ),
        backgroundColor: AppColors.primary,
        child: Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(goalsProvider.notifier).loadGoals(),
        child: state.isLoading
            ? Center(child: CircularProgressIndicator())
            : state.goals.isEmpty
                ? _buildEmptyState()
                : ListView(
                    padding: EdgeInsets.all(16),
                    children: [
                      if (state.activeGoals.isNotEmpty) ...[
                        _buildSectionHeader('进行中'),
                        ...state.activeGoals.map((g) => _buildGoalCard(context, ref, g)),
                        SizedBox(height: 16),
                      ],
                      if (state.achievedGoals.isNotEmpty) ...[
                        _buildSectionHeader('已达成'),
                        ...state.achievedGoals.map((g) => _buildGoalCard(context, ref, g)),
                      ],
                    ],
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.flag_outlined, size: 64, color: AppColors.textSecondary),
          SizedBox(height: 16),
          Text('还没有设定健康目标', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
          SizedBox(height: 8),
          Text('点击右下角 + 号创建第一个目标', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
    );
  }

  Widget _buildGoalCard(BuildContext context, WidgetRef ref, HealthGoal goal) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getGoalIcon(goal.goalType), color: _getGoalColor(goal.goalType), size: 22),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    goal.goalTypeLabel,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: goal.status == 'achieved'
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    goal.statusLabel,
                    style: TextStyle(
                      fontSize: 11,
                      color: goal.status == 'achieved' ? AppColors.success : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              '目标值：${goal.targetValue}',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            if (goal.deadline != null) ...[
              SizedBox(height: 4),
              Text(
                '截止日期：${AppDateUtils.formatDate(goal.deadline!)}',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
            if (goal.status == 'active') ...[
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => ref.read(goalsProvider.notifier).updateStatus(goal.id!, 'achieved'),
                    child: Text('标记达成', style: TextStyle(color: AppColors.success)),
                  ),
                  SizedBox(width: 8),
                  TextButton(
                    onPressed: () => ref.read(goalsProvider.notifier).updateStatus(goal.id!, 'abandoned'),
                    child: Text('放弃', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getGoalIcon(String goalType) {
    switch (goalType) {
      case 'weight_loss': return Icons.trending_down;
      case 'weight_gain': return Icons.trending_up;
      case 'exercise': return Icons.fitness_center;
      case 'diet': return Icons.restaurant;
      case 'sleep': return Icons.bedtime;
      default: return Icons.flag;
    }
  }

  Color _getGoalColor(String goalType) {
    switch (goalType) {
      case 'weight_loss': return Colors.green;
      case 'weight_gain': return Colors.blue;
      case 'exercise': return Colors.orange;
      case 'diet': return Colors.purple;
      case 'sleep': return Colors.indigo;
      default: return AppColors.primary;
    }
  }
}
