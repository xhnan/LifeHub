import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/models/diet_log.dart';

class DietCard extends StatelessWidget {
  final DietLog dietLog;

  const DietCard({super.key, required this.dietLog});

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
                color: _getMealColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getMealIcon(),
                color: _getMealColor(),
                size: 24,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getMealName(dietLog.mealType),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    dietLog.foodItems,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (dietLog.totalCalories != null)
              Text(
                '${dietLog.totalCalories!.toStringAsFixed(0)} kcal',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getMealIcon() {
    switch (dietLog.mealType) {
      case 'breakfast': return Icons.free_breakfast;
      case 'lunch': return Icons.lunch_dining;
      case 'dinner': return Icons.dinner_dining;
      case 'snack': return Icons.cookie;
      default: return Icons.restaurant;
    }
  }

  Color _getMealColor() {
    switch (dietLog.mealType) {
      case 'breakfast': return Colors.orange;
      case 'lunch': return Colors.blue;
      case 'dinner': return Colors.purple;
      case 'snack': return Colors.teal;
      default: return AppColors.primary;
    }
  }

  String _getMealName(String type) {
    switch (type) {
      case 'breakfast': return '早餐';
      case 'lunch': return '午餐';
      case 'dinner': return '晚餐';
      case 'snack': return '加餐';
      default: return type;
    }
  }
}
