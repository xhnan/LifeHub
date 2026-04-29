import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/models/health_activity.dart';

class ActivityCard extends StatelessWidget {
  final HealthActivity activity;

  const ActivityCard({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getActivityIcon(activity.activityType),
                color: AppColors.primary,
                size: 24,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getActivityName(activity.activityType),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${AppDateUtils.formatDuration(activity.durationMinutes)}${activity.caloriesBurned != null ? ' · ${activity.caloriesBurned!.toStringAsFixed(0)} kcal' : ''}',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (activity.startTime != null)
              Text(
                AppDateUtils.formatRelative(activity.startTime!),
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'running': return Icons.directions_run;
      case 'walking': return Icons.directions_walk;
      case 'cycling': return Icons.directions_bike;
      case 'swimming': return Icons.pool;
      case 'weightlifting': return Icons.fitness_center;
      case 'yoga': return Icons.self_improvement;
      default: return Icons.sports;
    }
  }

  String _getActivityName(String type) {
    switch (type) {
      case 'running': return '跑步';
      case 'walking': return '步行';
      case 'cycling': return '骑行';
      case 'swimming': return '游泳';
      case 'weightlifting': return '举重';
      case 'yoga': return '瑜伽';
      default: return type;
    }
  }
}
