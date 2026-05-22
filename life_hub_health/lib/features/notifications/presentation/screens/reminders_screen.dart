import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../providers/reminders_provider.dart';

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(remindersProvider);

    return Scaffold(
      appBar: AppBar(title: Text('提醒设置')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildReminderCard(
            icon: Icons.water_drop,
            title: '饮水提醒',
            subtitle: state.waterReminderEnabled ? '每${state.waterIntervalHours}小时提醒一次' : '未开启',
            color: Colors.blue,
            enabled: state.waterReminderEnabled,
            onToggle: (v) => ref.read(remindersProvider.notifier).toggleWaterReminder(v),
            onTap: () => _showIntervalPicker(context, ref, 'water'),
          ),
          SizedBox(height: 12),
          _buildReminderCard(
            icon: Icons.fitness_center,
            title: '运动提醒',
            subtitle: state.exerciseReminderEnabled
                ? '每天 ${state.exerciseReminderTime.format(context)} 提醒'
                : '未开启',
            color: Colors.orange,
            enabled: state.exerciseReminderEnabled,
            onToggle: (v) => ref.read(remindersProvider.notifier).toggleExerciseReminder(v),
            onTap: () => _pickTime(context, ref, 'exercise'),
          ),
          SizedBox(height: 12),
          _buildReminderCard(
            icon: Icons.bedtime,
            title: '睡眠提醒',
            subtitle: state.sleepReminderEnabled
                ? '每晚 ${state.sleepReminderTime.format(context)} 提醒入睡'
                : '未开启',
            color: Colors.indigo,
            enabled: state.sleepReminderEnabled,
            onToggle: (v) => ref.read(remindersProvider.notifier).toggleSleepReminder(v),
            onTap: () => _pickTime(context, ref, 'sleep'),
          ),
          SizedBox(height: 12),
          _buildReminderCard(
            icon: Icons.check_circle_outline,
            title: '打卡提醒',
            subtitle: state.checkinReminderEnabled
                ? '每天 ${state.checkinReminderTime.format(context)} 提醒打卡'
                : '未开启',
            color: AppColors.primary,
            enabled: state.checkinReminderEnabled,
            onToggle: (v) => ref.read(remindersProvider.notifier).toggleCheckinReminder(v),
            onTap: () => _pickTime(context, ref, 'checkin'),
          ),
          SizedBox(height: 24),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 18, color: AppColors.textSecondary),
                      SizedBox(width: 8),
                      Text('提示', style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '提醒功能依赖系统通知权限，请确保已授权通知权限。',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool enabled,
    required ValueChanged<bool> onToggle,
    VoidCallback? onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    SizedBox(height: 3),
                    Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Switch(
                value: enabled,
                onChanged: onToggle,
                activeColor: color,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showIntervalPicker(BuildContext context, WidgetRef ref, String type) {
    showDialog(
      context: context,
      builder: (ctx) {
        int selected = ref.read(remindersProvider).waterIntervalHours;
        return AlertDialog(
          title: Text('选择提醒间隔'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [1, 2, 3, 4].map((h) {
                  return RadioListTile<int>(
                    title: Text('每 $h 小时'),
                    value: h,
                    groupValue: selected,
                    onChanged: (v) => setDialogState(() => selected = v!),
                  );
                }).toList(),
              );
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('取消')),
            TextButton(
              onPressed: () {
                ref.read(remindersProvider.notifier).setWaterInterval(selected);
                Navigator.pop(ctx);
              },
              child: Text('确定'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickTime(BuildContext context, WidgetRef ref, String type) async {
    final state = ref.read(remindersProvider);
    final initial = type == 'exercise'
        ? state.exerciseReminderTime
        : type == 'sleep'
            ? state.sleepReminderTime
            : state.checkinReminderTime;

    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      final notifier = ref.read(remindersProvider.notifier);
      switch (type) {
        case 'exercise':
          notifier.setExerciseTime(picked);
          break;
        case 'sleep':
          notifier.setSleepTime(picked);
          break;
        case 'checkin':
          notifier.setCheckinTime(picked);
          break;
      }
    }
  }
}
