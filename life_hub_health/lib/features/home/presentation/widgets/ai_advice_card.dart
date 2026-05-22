import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/models/agent_models.dart';

class AiAdviceCard extends StatelessWidget {
  final List<AdviceRecord> adviceList;
  final VoidCallback? onViewAll;

  const AiAdviceCard({
    super.key,
    required this.adviceList,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.auto_awesome, color: AppColors.secondary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'AI 健康建议',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (adviceList.isNotEmpty && onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    child: Text('查看全部', style: TextStyle(fontSize: 12)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (adviceList.isEmpty)
              _buildEmptyState()
            else
              ...adviceList.take(3).map((advice) => _buildAdviceItem(advice)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '持续记录健康数据，AI 将为您生成个性化建议',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceItem(AdviceRecord advice) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _getAgentColor(advice.agentType).withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _getAgentColor(advice.agentType).withOpacity(0.2),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _getAgentIcon(advice.agentType),
              color: _getAgentColor(advice.agentType),
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (advice.title != null)
                    Text(
                      advice.title!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  Text(
                    advice.content,
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (advice.createdAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      AppDateUtils.formatRelative(advice.createdAt!),
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary.withOpacity(0.7)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getAgentIcon(String agentType) {
    switch (agentType) {
      case 'diet':
        return Icons.restaurant;
      case 'exercise':
        return Icons.fitness_center;
      case 'psychology':
        return Icons.psychology;
      case 'sleep':
        return Icons.bedtime;
      default:
        return Icons.health_and_safety;
    }
  }

  Color _getAgentColor(String agentType) {
    switch (agentType) {
      case 'diet':
        return Colors.orange;
      case 'exercise':
        return Colors.blue;
      case 'psychology':
        return Colors.purple;
      case 'sleep':
        return Colors.indigo;
      default:
        return AppColors.primary;
    }
  }
}
