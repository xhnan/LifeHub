import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../providers/water_provider.dart';

class WaterScreen extends ConsumerWidget {
  const WaterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(waterProvider);

    return Scaffold(
      appBar: AppBar(title: Text('饮水追踪')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(waterProvider.notifier).loadToday(),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              _buildProgressCard(state),
              SizedBox(height: 20),
              _buildQuickAddButtons(context, ref),
              SizedBox(height: 20),
              _buildTodayHistory(state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard(WaterState state) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            SizedBox(
              width: 160,
              height: 160,
              child: CustomPaint(
                painter: _WaterProgressPainter(progress: state.progress),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.water_drop, color: Colors.blue, size: 28),
                      SizedBox(height: 4),
                      Text(
                        '${state.todayTotalMl}',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      Text('/ ${state.dailyGoalMl} ml', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            if (state.goalReached)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: AppColors.success, size: 18),
                  SizedBox(width: 6),
                  Text('今日目标已达成！', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600)),
                ],
              )
            else
              Text('还需喝 ${state.remaining} ml', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAddButtons(BuildContext context, WidgetRef ref) {
    final amounts = [
      {'ml': 150, 'label': '小杯', 'icon': Icons.local_cafe},
      {'ml': 250, 'label': '一杯', 'icon': Icons.water_drop},
      {'ml': 500, 'label': '大杯', 'icon': Icons.local_drink},
      {'ml': 0, 'label': '自定义', 'icon': Icons.edit},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('快捷记录', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        Row(
          children: amounts.map((item) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: _buildQuickButton(
                  context: context,
                  ref: ref,
                  icon: item['icon'] as IconData,
                  label: item['label'] as String,
                  ml: item['ml'] as int,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickButton({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required String label,
    required int ml,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          if (ml > 0) {
            _addWater(context, ref, ml);
          } else {
            _showCustomDialog(context, ref);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: Colors.blue, size: 24),
              SizedBox(height: 6),
              Text(label, style: TextStyle(fontSize: 12)),
              if (ml > 0)
                Text('${ml}ml', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addWater(BuildContext context, WidgetRef ref, int ml) async {
    final success = await ref.read(waterProvider.notifier).addWater(ml);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已记录 ${ml}ml 💧'), behavior: SnackBarBehavior.floating, duration: Duration(seconds: 1)),
      );
    }
  }

  Future<void> _showCustomDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('自定义饮水量'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: '输入毫升数', suffixText: 'ml'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('取消')),
          TextButton(
            onPressed: () {
              final ml = int.tryParse(controller.text);
              Navigator.pop(ctx, ml);
            },
            child: Text('确定'),
          ),
        ],
      ),
    );
    if (result != null && result > 0) {
      _addWater(context, ref, result);
    }
  }

  Widget _buildTodayHistory(WaterState state) {
    if (state.todayLogs.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: 24),
        child: Center(child: Text('今天还没有记录', style: TextStyle(color: AppColors.textSecondary))),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('今日记录', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        ...state.todayLogs.reversed.map((log) => Card(
              margin: EdgeInsets.only(bottom: 6),
              child: ListTile(
                leading: Icon(Icons.water_drop, color: Colors.blue.shade300, size: 20),
                title: Text('${log.amountMl} ml'),
                subtitle: Text(log.drinkTypeLabel, style: TextStyle(fontSize: 12)),
                trailing: Text(
                  AppDateUtils.formatTime(log.recordTime),
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
            )),
      ],
    );
  }
}

class _WaterProgressPainter extends CustomPainter {
  final double progress;

  _WaterProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Background
    final bgPaint = Paint()
      ..color = Colors.blue.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress
    final progressPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress.clamp(0.0, 1.0),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _WaterProgressPainter oldDelegate) => oldDelegate.progress != progress;
}
