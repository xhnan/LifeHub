import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../providers/mood_provider.dart';

class PsychologyScreen extends ConsumerWidget {
  const PsychologyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moodState = ref.watch(moodProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('心理健康'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMoodTracker(context, ref),
            SizedBox(height: 16),
            _buildQuickActions(context),
            SizedBox(height: 16),
            _buildRecentMoods(moodState),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodTracker(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '今日心情',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMoodOption(context, ref, 8, '😊', '开心', 'happy'),
                _buildMoodOption(context, ref, 6, '😌', '平静', 'calm'),
                _buildMoodOption(context, ref, 3, '😔', '难过', 'sad'),
                _buildMoodOption(context, ref, 2, '😤', '生气', 'angry'),
                _buildMoodOption(context, ref, 4, '😰', '焦虑', 'anxious'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodOption(BuildContext context, WidgetRef ref, int score, String emoji, String label, String emotion) {
    return InkWell(
      onTap: () async {
        final success = await ref.read(moodProvider.notifier).recordMood(
          moodScore: score,
          primaryEmotion: emotion,
        );
        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('已记录今日心情：$label')),
          );
        } else if (context.mounted) {
          final error = ref.read(moodProvider).error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error ?? '记录心情失败')),
          );
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            Text(emoji, style: TextStyle(fontSize: 32)),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            context: context,
            icon: Icons.assessment,
            label: '心理评估',
            color: Colors.purple,
            onTap: () => _showAssessmentOptions(context),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            context: context,
            icon: Icons.psychology,
            label: '心理档案',
            color: Colors.blue,
            onTap: () => context.push('/profile/psy-profile'),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAssessmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '选择评估量表',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 24),
            _buildAssessmentOption(
              context: context,
              title: 'PHQ-9 抑郁筛查',
              description: '评估过去两周的抑郁症状',
              icon: Icons.sentiment_dissatisfied,
              color: Colors.orange,
              scaleName: 'PHQ-9',
            ),
            SizedBox(height: 12),
            _buildAssessmentOption(
              context: context,
              title: 'GAD-7 焦虑筛查',
              description: '评估过去两周的焦虑症状',
              icon: Icons.psychology,
              color: Colors.blue,
              scaleName: 'GAD-7',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssessmentOption({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required String scaleName,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
      subtitle: Text(description, style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
      trailing: Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: () {
        Navigator.pop(context);
        context.push('/psychology/assessment/$scaleName');
      },
    );
  }

  Widget _buildRecentMoods(MoodState moodState) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '最近心情',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            SizedBox(height: 16),
            if (moodState.isLoading)
              Center(child: CircularProgressIndicator())
            else if (moodState.moods.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(Icons.mood, size: 48, color: AppColors.textSecondary),
                    SizedBox(height: 8),
                    Text('暂无记录', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  ],
                ),
              )
            else
              ...moodState.moods.take(7).map((mood) => ListTile(
                leading: Text(_getMoodEmoji(mood.moodScore), style: TextStyle(fontSize: 28)),
                title: Text(_getMoodLabel(mood.moodScore)),
                subtitle: Text(AppDateUtils.formatRelative(mood.createdAt ?? mood.recordDate)),
                trailing: mood.primaryEmotion != null
                    ? Chip(label: Text(mood.primaryEmotion!, style: TextStyle(fontSize: 11)), visualDensity: VisualDensity.compact)
                    : null,
              )),
          ],
        ),
      ),
    );
  }

  String _getMoodEmoji(int score) {
    if (score >= 8) return '😊';
    if (score >= 6) return '😌';
    if (score >= 4) return '😐';
    if (score >= 2) return '😔';
    return '😢';
  }

  String _getMoodLabel(int score) {
    if (score >= 8) return '开心';
    if (score >= 6) return '平静';
    if (score >= 4) return '一般';
    if (score >= 2) return '难过';
    return '很差';
  }
}
