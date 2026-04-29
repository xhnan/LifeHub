import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import 'assessment_screen.dart';

class PsychologyScreen extends ConsumerWidget {
  const PsychologyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('心理健康'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMoodTracker(context),
            SizedBox(height: 16),
            _buildQuickActions(context),
            SizedBox(height: 16),
            _buildRecentMoods(),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodTracker(BuildContext context) {
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
                _buildMoodOption(context, '😊', '开心'),
                _buildMoodOption(context, '😌', '平静'),
                _buildMoodOption(context, '😔', '难过'),
                _buildMoodOption(context, '😤', '生气'),
                _buildMoodOption(context, '😰', '焦虑'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodOption(BuildContext context, String emoji, String label) {
    return InkWell(
      onTap: () {
        // TODO: Save mood
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已记录今日心情：$label')),
        );
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
            icon: Icons.edit_note,
            label: '写日记',
            color: Colors.blue,
            onTap: () {
              // TODO: Navigate to journal
            },
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            context: context,
            icon: Icons.assessment,
            label: '心理评估',
            color: Colors.purple,
            onTap: () {
              _showAssessmentOptions(context);
            },
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            context: context,
            icon: Icons.chat,
            label: '心理聊天',
            color: Colors.green,
            onTap: () {
              // TODO: Navigate to psychology chat
            },
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
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        description,
        style: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AssessmentScreen(scaleName: scaleName),
          ),
        );
      },
    );
  }

  Widget _buildRecentMoods() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '最近心情',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Icon(Icons.mood, size: 48, color: AppColors.textSecondary),
                  SizedBox(height: 8),
                  Text(
                    '暂无记录',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
