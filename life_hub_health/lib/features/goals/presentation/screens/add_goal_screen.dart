import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../providers/goals_provider.dart';

class AddGoalScreen extends ConsumerStatefulWidget {
  const AddGoalScreen({super.key});

  @override
  ConsumerState<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends ConsumerState<AddGoalScreen> {
  String _selectedType = 'weight_loss';
  final _targetController = TextEditingController();
  DateTime? _deadline;

  final _goalTypes = [
    {'value': 'weight_loss', 'label': '减重 (kg)', 'icon': Icons.trending_down},
    {'value': 'weight_gain', 'label': '增重 (kg)', 'icon': Icons.trending_up},
    {'value': 'exercise', 'label': '运动 (分钟/周)', 'icon': Icons.fitness_center},
    {'value': 'diet', 'label': '饮食 (千卡/天)', 'icon': Icons.restaurant},
    {'value': 'sleep', 'label': '睡眠 (小时/天)', 'icon': Icons.bedtime},
    {'value': 'other', 'label': '其他', 'icon': Icons.flag},
  ];

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(goalsProvider);

    return Scaffold(
      appBar: AppBar(title: Text('创建目标')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('目标类型', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _goalTypes.map((type) {
                final isSelected = _selectedType == type['value'];
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(type['icon'] as IconData, size: 16,
                          color: isSelected ? Colors.white : AppColors.textSecondary),
                      SizedBox(width: 6),
                      Text(type['label'] as String),
                    ],
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedType = type['value'] as String);
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 24),
            Text('目标值', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 12),
            TextField(
              controller: _targetController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: '请输入目标数值',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            SizedBox(height: 24),
            Text('截止日期（可选）', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 12),
            InkWell(
              onTap: _pickDeadline,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 18, color: AppColors.textSecondary),
                    SizedBox(width: 12),
                    Text(
                      _deadline != null ? AppDateUtils.formatDate(_deadline!) : '选择截止日期',
                      style: TextStyle(
                        fontSize: 14,
                        color: _deadline != null ? AppColors.textPrimary : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: state.isCreating ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: state.isCreating
                    ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text('创建目标', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365 * 2)),
    );
    if (date != null) {
      setState(() => _deadline = date);
    }
  }

  Future<void> _submit() async {
    final target = double.tryParse(_targetController.text.trim());
    if (target == null || target <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请输入有效的目标值'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    final success = await ref.read(goalsProvider.notifier).createGoal(
      goalType: _selectedType,
      targetValue: target,
      deadline: _deadline,
    );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('目标创建成功 ✓'), behavior: SnackBarBehavior.floating),
      );
    }
  }
}
