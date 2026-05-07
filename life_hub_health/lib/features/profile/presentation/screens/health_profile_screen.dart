import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/models/user_profile.dart';
import '../../../../shared/providers/providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class HealthProfileScreen extends ConsumerStatefulWidget {
  const HealthProfileScreen({super.key});

  @override
  ConsumerState<HealthProfileScreen> createState() => _HealthProfileScreenState();
}

class _HealthProfileScreenState extends ConsumerState<HealthProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _heightController = TextEditingController();
  final _targetWeightController = TextEditingController();
  String? _gender;
  DateTime? _birthDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _heightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final api = ref.read(apiServiceProvider);
      await api.post('/health/user-profiles/init', data: {
        'birthDate': _birthDate?.toIso8601String().split('T')[0],
        'gender': _gender,
        'heightCm': double.tryParse(_heightController.text),
        'targetWeightKg': double.tryParse(_targetWeightController.text),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('保存成功')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ErrorHandler.getFriendlyMessage(e))));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('健康档案')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              value: _gender,
              decoration: InputDecoration(labelText: '性别', prefixIcon: Icon(Icons.person)),
              items: [
                DropdownMenuItem(value: 'male', child: Text('男')),
                DropdownMenuItem(value: 'female', child: Text('女')),
              ],
              onChanged: (v) => setState(() => _gender = v),
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.cake, color: AppColors.primary),
              title: Text(_birthDate != null ? '出生日期: ${_birthDate!.year}-${_birthDate!.month}-${_birthDate!.day}' : '选择出生日期'),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime(1990),
                  firstDate: DateTime(1920),
                  lastDate: DateTime.now(),
                );
                if (date != null) setState(() => _birthDate = date);
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _heightController,
              decoration: InputDecoration(labelText: '身高 (cm)', prefixIcon: Icon(Icons.height), suffixText: 'cm'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _targetWeightController,
              decoration: InputDecoration(labelText: '目标体重 (kg)', prefixIcon: Icon(Icons.flag), suffixText: 'kg'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _save,
              child: _isLoading
                  ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}
