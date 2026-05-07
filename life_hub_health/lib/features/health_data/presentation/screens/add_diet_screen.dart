import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../providers/health_data_provider.dart';

class AddDietScreen extends ConsumerStatefulWidget {
  const AddDietScreen({super.key});

  @override
  ConsumerState<AddDietScreen> createState() => _AddDietScreenState();
}

class _AddDietScreenState extends ConsumerState<AddDietScreen> {
  final _formKey = GlobalKey<FormState>();
  String _mealType = 'lunch';
  final _foodController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();

  @override
  void dispose() {
    _foodController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref.read(healthDataProvider.notifier).createDietLog(
      mealTime: DateTime.now(),
      mealType: _mealType,
      foodItems: _foodController.text,
      totalCalories: _caloriesController.text.isNotEmpty ? double.parse(_caloriesController.text) : null,
      proteinG: _proteinController.text.isNotEmpty ? double.parse(_proteinController.text) : null,
      carbsG: _carbsController.text.isNotEmpty ? double.parse(_carbsController.text) : null,
      fatG: _fatController.text.isNotEmpty ? double.parse(_fatController.text) : null,
    );
    if (success && mounted) {
      context.pop();
    } else if (mounted) {
      final error = ref.read(healthDataProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? '添加饮食记录失败')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(healthDataProvider);
    return Scaffold(
      appBar: AppBar(title: Text('添加饮食记录')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              value: _mealType,
              decoration: InputDecoration(labelText: '餐次', prefixIcon: Icon(Icons.restaurant)),
              items: [
                DropdownMenuItem(value: 'breakfast', child: Text('早餐')),
                DropdownMenuItem(value: 'lunch', child: Text('午餐')),
                DropdownMenuItem(value: 'dinner', child: Text('晚餐')),
                DropdownMenuItem(value: 'snack', child: Text('加餐')),
              ],
              onChanged: (v) => setState(() => _mealType = v!),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _foodController,
              decoration: InputDecoration(labelText: '食物描述', prefixIcon: Icon(Icons.fastfood)),
              validator: (v) => v == null || v.isEmpty ? '请输入食物描述' : null,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _caloriesController,
              decoration: InputDecoration(labelText: '总卡路里（选填）', prefixIcon: Icon(Icons.local_fire_department)),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _proteinController,
                    decoration: InputDecoration(labelText: '蛋白质(g)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _carbsController,
                    decoration: InputDecoration(labelText: '碳水(g)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _fatController,
                    decoration: InputDecoration(labelText: '脂肪(g)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
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
