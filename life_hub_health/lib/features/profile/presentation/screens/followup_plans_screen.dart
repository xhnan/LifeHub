import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/models/agent_models.dart';
import '../providers/profile_providers.dart';

class FollowupPlansScreen extends ConsumerStatefulWidget {
  const FollowupPlansScreen({super.key});

  @override
  ConsumerState<FollowupPlansScreen> createState() => _FollowupPlansScreenState();
}

class _FollowupPlansScreenState extends ConsumerState<FollowupPlansScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(followupPlansProvider.notifier).loadPlans(activeOnly: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(followupPlansProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('跟踪计划'),
      ),
      body: state.isLoading
          ? Center(child: CircularProgressIndicator())
          : state.error != null && state.plans.isEmpty
              ? _buildErrorState(state.error!, () => ref.read(followupPlansProvider.notifier).loadPlans(activeOnly: true))
              : state.plans.isEmpty
                  ? _buildEmptyState()
                  : _buildPlanList(state.plans),
    );
  }

  Widget _buildErrorState(String error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(error, style: TextStyle(fontSize: 14, color: AppColors.error), textAlign: TextAlign.center),
          ),
          SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: Text('重试')),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16),
          Text(
            '暂无跟踪计划',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'AI 将根据您的健康数据生成个性化计划',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanList(List<FollowupPlan> plans) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: plans.length,
      itemBuilder: (context, index) {
        final plan = plans[index];
        return _buildPlanCard(plan);
      },
    );
  }

  Widget _buildPlanCard(FollowupPlan plan) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildPlanTypeChip(plan.planType),
                Spacer(),
                _buildStatusChip(plan.status),
              ],
            ),
            SizedBox(height: 12),
            Text(
              plan.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            if (plan.goalSummary != null) ...[
              SizedBox(height: 8),
              Text(
                plan.goalSummary!,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            SizedBox(height: 12),
            if (plan.startDate != null && plan.endDate != null)
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
                  SizedBox(width: 8),
                  Text(
                    '${_formatDate(plan.startDate!)} - ${_formatDate(plan.endDate!)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            SizedBox(height: 16),
            _buildPlanDetails(plan.planJson),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanDetails(Map<String, dynamic> planJson) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '计划详情',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          ...planJson.entries.map((entry) => Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.key}: ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Expanded(
                  child: Text(
                    entry.value.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildPlanTypeChip(String planType) {
    Color color;
    String label;
    switch (planType) {
      case 'exercise':
        color = Colors.blue;
        label = '运动计划';
        break;
      case 'diet':
        color = Colors.orange;
        label = '饮食计划';
        break;
      case 'weight':
        color = Colors.green;
        label = '体重管理';
        break;
      default:
        color = AppColors.textSecondary;
        label = planType;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    switch (status) {
      case 'active':
        color = AppColors.success;
        label = '进行中';
        break;
      case 'completed':
        color = AppColors.info;
        label = '已完成';
        break;
      case 'paused':
        color = AppColors.warning;
        label = '已暂停';
        break;
      default:
        color = AppColors.textSecondary;
        label = status;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}
