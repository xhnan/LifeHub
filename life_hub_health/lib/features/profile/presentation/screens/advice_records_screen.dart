import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/models/agent_models.dart';
import '../providers/agent_provider.dart';

class AdviceRecordsScreen extends ConsumerStatefulWidget {
  const AdviceRecordsScreen({super.key});

  @override
  ConsumerState<AdviceRecordsScreen> createState() => _AdviceRecordsScreenState();
}

class _AdviceRecordsScreenState extends ConsumerState<AdviceRecordsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(agentProvider.notifier).loadAdviceRecords(activeOnly: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final agentState = ref.watch(agentProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('AI 建议'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'all') {
                ref.read(agentProvider.notifier).loadAdviceRecords();
              } else {
                ref.read(agentProvider.notifier).loadAdviceRecords(agentType: value);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'all', child: Text('全部')),
              PopupMenuItem(value: 'health_manager', child: Text('健康管理')),
              PopupMenuItem(value: 'diet_agent', child: Text('饮食建议')),
              PopupMenuItem(value: 'weight_trend_agent', child: Text('体重趋势')),
            ],
          ),
        ],
      ),
      body: agentState.isLoading
          ? Center(child: CircularProgressIndicator())
          : agentState.adviceRecords.isEmpty
              ? _buildEmptyState()
              : _buildAdviceList(agentState.adviceRecords),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome_outlined,
            size: 64,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16),
          Text(
            '暂无 AI 建议',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '开始记录健康数据，AI 将为您提供个性化建议',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceList(List<AdviceRecord> records) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return _buildAdviceCard(record);
      },
    );
  }

  Widget _buildAdviceCard(AdviceRecord record) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildAgentTypeChip(record.agentType),
                SizedBox(width: 8),
                _buildPriorityChip(record.priorityLevel),
                Spacer(),
                if (record.validUntil != null)
                  Text(
                    '有效期至 ${record.validUntil!.month}/${record.validUntil!.day}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12),
            if (record.title != null) ...[
              Text(
                record.title!,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8),
            ],
            Text(
              record.content,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
            if (record.sourceSummary != null) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: AppColors.textSecondary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        record.sourceSummary!,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAgentTypeChip(String agentType) {
    Color color;
    String label;
    switch (agentType) {
      case 'health_manager':
        color = Colors.green;
        label = '健康管理';
        break;
      case 'diet_agent':
        color = Colors.orange;
        label = '饮食建议';
        break;
      case 'weight_trend_agent':
        color = Colors.blue;
        label = '体重趋势';
        break;
      default:
        color = AppColors.textSecondary;
        label = agentType;
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

  Widget _buildPriorityChip(String? priorityLevel) {
    if (priorityLevel == null) return SizedBox.shrink();

    Color color;
    switch (priorityLevel) {
      case 'high':
        color = AppColors.error;
        break;
      case 'medium':
        color = AppColors.warning;
        break;
      case 'low':
        color = AppColors.success;
        break;
      default:
        color = AppColors.textSecondary;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        priorityLevel.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
