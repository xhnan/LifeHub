import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/providers/providers.dart';
import '../providers/home_provider.dart';

/// AI 综合分析触发按钮
/// 点击后调用后端 /health/agent/analyze 接口，让 AI 基于近期数据生成建议
class AiAnalyzeButton extends ConsumerStatefulWidget {
  const AiAnalyzeButton({super.key});

  @override
  ConsumerState<AiAnalyzeButton> createState() => _AiAnalyzeButtonState();
}

class _AiAnalyzeButtonState extends ConsumerState<AiAnalyzeButton> {
  bool _isAnalyzing = false;
  String _selectedType = 'general';

  final _types = const [
    {'value': 'general', 'label': '综合', 'icon': Icons.health_and_safety},
    {'value': 'diet', 'label': '饮食', 'icon': Icons.restaurant},
    {'value': 'exercise', 'label': '运动', 'icon': Icons.fitness_center},
    {'value': 'psychology', 'label': '心理', 'icon': Icons.psychology},
    {'value': 'sleep', 'label': '睡眠', 'icon': Icons.bedtime},
  ];

  Future<void> _analyze() async {
    if (_isAnalyzing) return;
    setState(() => _isAnalyzing = true);

    try {
      final api = ref.read(apiServiceProvider);
      final response = await api.post(
        '/health/agent/analyze?agentType=$_selectedType',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final list = response.data['data'] as List?;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✨ AI 已生成 ${list?.length ?? 0} 条新建议'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          // 刷新首页数据
          await ref.read(homeProvider.notifier).loadDashboard();
        }
      } else {
        throw Exception(response.data['message'] ?? '分析失败');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('分析失败：$e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [AppColors.secondary.withOpacity(0.1), AppColors.primary.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: AppColors.secondary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'AI 健康分析',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                if (_isAnalyzing)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.secondary),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '基于近 7 天数据生成个性化建议',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            // 维度选择
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _types.map((type) {
                  final isSelected = _selectedType == type['value'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            type['icon'] as IconData,
                            size: 14,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(type['label'] as String, style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.secondary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                      onSelected: _isAnalyzing
                          ? null
                          : (s) {
                              if (s) setState(() => _selectedType = type['value'] as String);
                            },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : _analyze,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: Icon(_isAnalyzing ? Icons.hourglass_top : Icons.bolt, size: 18),
                label: Text(_isAnalyzing ? '分析中...' : '生成 AI 建议'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
