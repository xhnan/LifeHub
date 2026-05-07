import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../providers/health_data_provider.dart';

class AddActivityScreen extends ConsumerStatefulWidget {
  const AddActivityScreen({super.key});

  @override
  ConsumerState<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends ConsumerState<AddActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  String _activityType = 'running';
  final _durationController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _durationController.dispose();
    _caloriesController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref.read(healthDataProvider.notifier).createActivity(
      activityType: _activityType,
      durationMinutes: int.parse(_durationController.text),
      caloriesBurned: _caloriesController.text.isNotEmpty ? double.parse(_caloriesController.text) : null,
      description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
    );
    if (success && mounted) {
      context.pop();
    } else if (mounted) {
      final error = ref.read(healthDataProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? '添加运动记录失败')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(healthDataProvider);
    return Scaffold(
      appBar: AppBar(title: Text('添加运动记录')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              value: _activityType,
              decoration: InputDecoration(labelText: '运动类型', prefixIcon: Icon(Icons.sports)),
              items: [
                DropdownMenuItem(value: 'running', child: Text('跑步')),
                DropdownMenuItem(value: 'walking', child: Text('步行')),
                DropdownMenuItem(value: 'cycling', child: Text('骑行')),
                DropdownMenuItem(value: 'swimming', child: Text('游泳')),
                DropdownMenuItem(value: 'weightlifting', child: Text('举重')),
                DropdownMenuItem(value: 'yoga', child: Text('瑜伽')),
              ],
              onChanged: (v) => setState(() => _activityType = v!),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _durationController,
              decoration: InputDecoration(labelText: '时长（分钟）', prefixIcon: Icon(Icons.timer)),
              keyboardType: TextInputType.number,
              validator: (v) => v == null || v.isEmpty ? '请输入时长' : null,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _caloriesController,
              decoration: InputDecoration(labelText: '消耗卡路里（选填）', prefixIcon: Icon(Icons.local_fire_department)),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: '描述（选填）', prefixIcon: Icon(Icons.notes)),
              maxLines: 3,
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: state.isLoading ? null : _submit,
              child: state.isLoading
                  ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}
