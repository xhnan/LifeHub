import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../providers/health_data_provider.dart';

class AddWeightScreen extends ConsumerStatefulWidget {
  const AddWeightScreen({super.key});

  @override
  ConsumerState<AddWeightScreen> createState() => _AddWeightScreenState();
}

class _AddWeightScreenState extends ConsumerState<AddWeightScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _bodyFatController = TextEditingController();

  @override
  void dispose() {
    _weightController.dispose();
    _bodyFatController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref.read(healthDataProvider.notifier).createWeightLog(
      weightKg: double.parse(_weightController.text),
      bodyFatPercentage: _bodyFatController.text.isNotEmpty ? double.parse(_bodyFatController.text) : null,
    );
    if (success && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(healthDataProvider);
    return Scaffold(
      appBar: AppBar(title: Text('记录体重')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _weightController,
              decoration: InputDecoration(
                labelText: '体重 (kg)',
                prefixIcon: Icon(Icons.monitor_weight),
                suffixText: 'kg',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.isEmpty) return '请输入体重';
                if (double.tryParse(v) == null) return '请输入有效数字';
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _bodyFatController,
              decoration: InputDecoration(
                labelText: '体脂率（选填）',
                prefixIcon: Icon(Icons.percent),
                suffixText: '%',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
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
