import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../providers/user_preferences_provider.dart';

class UserPreferencesScreen extends ConsumerStatefulWidget {
  const UserPreferencesScreen({super.key});

  @override
  ConsumerState<UserPreferencesScreen> createState() => _UserPreferencesScreenState();
}

class _UserPreferencesScreenState extends ConsumerState<UserPreferencesScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedDietStyle;
  final _dislikedFoodsController = TextEditingController();
  final _exerciseTypesController = TextEditingController();
  String? _selectedSupportStyle;
  final _routinePatternController = TextEditingController();
  final _motivationTagsController = TextEditingController();

  final List<String> _dietStyles = [
    '均衡饮食',
    '素食',
    '低碳水',
    '高蛋白',
    '地中海饮食',
    '生酮饮食',
    '其他',
  ];

  final List<String> _supportStyles = [
    '鼓励型',
    '严格型',
    '数据驱动型',
    '轻松型',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final prefs = ref.read(userPreferencesProvider).preferences;
      if (prefs != null) {
        setState(() {
          _selectedDietStyle = prefs.preferredDietStyle;
          _dislikedFoodsController.text = prefs.dislikedFoods ?? '';
          _exerciseTypesController.text = prefs.preferredExerciseTypes ?? '';
          _selectedSupportStyle = prefs.preferredSupportStyle;
          _routinePatternController.text = prefs.routinePattern ?? '';
          _motivationTagsController.text = prefs.motivationTags ?? '';
        });
      }
    });
  }

  @override
  void dispose() {
    _dislikedFoodsController.dispose();
    _exerciseTypesController.dispose();
    _routinePatternController.dispose();
    _motivationTagsController.dispose();
    super.dispose();
  }

  Future<void> _savePreferences() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref.read(userPreferencesProvider.notifier).savePreferences(
        preferredDietStyle: _selectedDietStyle,
        dislikedFoods: _dislikedFoodsController.text.isNotEmpty ? _dislikedFoodsController.text : null,
        preferredExerciseTypes: _exerciseTypesController.text.isNotEmpty ? _exerciseTypesController.text : null,
        preferredSupportStyle: _selectedSupportStyle,
        routinePattern: _routinePatternController.text.isNotEmpty ? _routinePatternController.text : null,
        motivationTags: _motivationTagsController.text.isNotEmpty ? _motivationTagsController.text : null,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('偏好设置已保存')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefsState = ref.watch(userPreferencesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('AI 偏好设置'),
        actions: [
          TextButton(
            onPressed: prefsState.isLoading ? null : _savePreferences,
            child: Text('保存'),
          ),
        ],
      ),
      body: prefsState.isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('饮食偏好'),
                    SizedBox(height: 16),
                    _buildDietStyleSelector(),
                    SizedBox(height: 16),
                    _buildTextField(
                      controller: _dislikedFoodsController,
                      label: '不喜欢的食物',
                      hint: '例如：香菜、芹菜',
                      icon: Icons.no_food,
                    ),
                    SizedBox(height: 24),
                    _buildSectionTitle('运动偏好'),
                    SizedBox(height: 16),
                    _buildTextField(
                      controller: _exerciseTypesController,
                      label: '喜欢的运动类型',
                      hint: '例如：跑步、游泳、瑜伽',
                      icon: Icons.fitness_center,
                    ),
                    SizedBox(height: 24),
                    _buildSectionTitle('AI 支持风格'),
                    SizedBox(height: 16),
                    _buildSupportStyleSelector(),
                    SizedBox(height: 24),
                    _buildSectionTitle('生活习惯'),
                    SizedBox(height: 16),
                    _buildTextField(
                      controller: _routinePatternController,
                      label: '作息规律',
                      hint: '例如：早睡早起、夜猫子',
                      icon: Icons.schedule,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      controller: _motivationTagsController,
                      label: '动力标签',
                      hint: '例如：健康、减肥、增肌',
                      icon: Icons.tag,
                    ),
                    SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: prefsState.isLoading ? null : _savePreferences,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text('保存偏好设置'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildDietStyleSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _dietStyles.map((style) {
        final isSelected = _selectedDietStyle == style;
        return ChoiceChip(
          label: Text(style),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedDietStyle = selected ? style : null;
            });
          },
          selectedColor: AppColors.primary.withOpacity(0.2),
          labelStyle: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSupportStyleSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _supportStyles.map((style) {
        final isSelected = _selectedSupportStyle == style;
        return ChoiceChip(
          label: Text(style),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedSupportStyle = selected ? style : null;
            });
          },
          selectedColor: AppColors.primary.withOpacity(0.2),
          labelStyle: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary),
      ),
    );
  }
}
