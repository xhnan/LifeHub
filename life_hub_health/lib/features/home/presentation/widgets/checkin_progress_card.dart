import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/theme/colors.dart';
import '../../../../shared/models/agent_models.dart';

class CheckinProgressCard extends StatelessWidget {
  final List<Checkin> todayCheckins;
  final List<FollowupPlan> activePlans;
  final double completionRate;
  final VoidCallback? onTap;

  const CheckinProgressCard({
    super.key,
    required this.todayCheckins,
    required this.activePlans,
    required this.completionRate,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildProgressRing(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '今日打卡',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getStatusText(),
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (activePlans.isNotEmpty) _buildPlanChips(),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressRing() {
    return SizedBox(
      width: 60,
      height: 60,
      child: CustomPaint(
        painter: _ProgressRingPainter(
          progress: completionRate,
          backgroundColor: AppColors.divider,
          progressColor: completionRate >= 1.0 ? AppColors.success : AppColors.primary,
        ),
        child: Center(
          child: Text(
            '${(completionRate * 100).toInt()}%',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: completionRate >= 1.0 ? AppColors.success : AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  String _getStatusText() {
    if (activePlans.isEmpty) {
      return '暂无进行中的计划';
    }
    final completed = todayCheckins.where((c) => c.completionStatus == 'completed').length;
    return '已完成 $completed / ${activePlans.length} 项';
  }

  Widget _buildPlanChips() {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: activePlans.take(3).map((plan) {
        final isCheckedIn = todayCheckins.any((c) => c.followupPlanId == plan.id);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isCheckedIn
                ? AppColors.success.withOpacity(0.1)
                : AppColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isCheckedIn ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 12,
                color: isCheckedIn ? AppColors.success : AppColors.warning,
              ),
              const SizedBox(width: 4),
              Text(
                plan.title,
                style: TextStyle(
                  fontSize: 11,
                  color: isCheckedIn ? AppColors.success : AppColors.warning,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;

  _ProgressRingPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    final strokeWidth = 6.0;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor;
  }
}
