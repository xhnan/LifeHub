import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';

class QuickMoodCard extends StatelessWidget {
  final bool hasMoodToday;
  final int? todayMoodScore;
  final ValueChanged<int>? onMoodSelected;

  const QuickMoodCard({
    super.key,
    required this.hasMoodToday,
    this.todayMoodScore,
    this.onMoodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.mood, color: AppColors.warning, size: 20),
                const SizedBox(width: 8),
                Text(
                  '今日心情',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (hasMoodToday)
              _buildMoodRecorded()
            else
              _buildMoodSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodRecorded() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(
            _getMoodEmoji(todayMoodScore ?? 5),
            style: TextStyle(fontSize: 28),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '今日已记录',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
              Text(
                '心情分数：${todayMoodScore ?? '-'}/10',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          const Spacer(),
          Icon(Icons.check_circle, color: AppColors.success, size: 24),
        ],
      ),
    );
  }

  Widget _buildMoodSelector() {
    final moods = [
      _MoodOption(emoji: '😢', label: '很差', score: 2),
      _MoodOption(emoji: '😔', label: '不好', score: 4),
      _MoodOption(emoji: '😐', label: '一般', score: 5),
      _MoodOption(emoji: '😊', label: '不错', score: 7),
      _MoodOption(emoji: '😄', label: '很棒', score: 9),
    ];

    return Column(
      children: [
        Text(
          '今天感觉怎么样？',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: moods.map((mood) => _buildMoodButton(mood)).toList(),
        ),
      ],
    );
  }

  Widget _buildMoodButton(_MoodOption mood) {
    return GestureDetector(
      onTap: () => onMoodSelected?.call(mood.score),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(mood.emoji, style: TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            mood.label,
            style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  String _getMoodEmoji(int score) {
    if (score >= 9) return '😄';
    if (score >= 7) return '😊';
    if (score >= 5) return '😐';
    if (score >= 3) return '😔';
    return '😢';
  }
}

class _MoodOption {
  final String emoji;
  final String label;
  final int score;

  const _MoodOption({
    required this.emoji,
    required this.label,
    required this.score,
  });
}
