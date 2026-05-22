import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../providers/achievements_provider.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(achievementsProvider);

    return Scaffold(
      appBar: AppBar(title: Text('成就墙')),
      body: state.isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStreakCard(state),
                  SizedBox(height: 16),
                  _buildAchievementGrid(state),
                ],
              ),
            ),
    );
  }

  Widget _buildStreakCard(AchievementsState state) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.orange.withOpacity(0.1), Colors.red.withOpacity(0.05)],
          ),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.local_fire_department, color: Colors.orange, size: 40),
            SizedBox(height: 8),
            Text(
              '${state.currentStreak}',
              style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.orange),
            ),
            Text('天连续打卡', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emoji_events, color: Colors.amber, size: 16),
                SizedBox(width: 6),
                Text('历史最长：${state.longestStreak} 天',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementGrid(AchievementsState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('成就列表', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          childAspectRatio: 0.85,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: state.achievements.map((a) => _buildAchievementTile(a)).toList(),
        ),
      ],
    );
  }

  Widget _buildAchievementTile(Achievement achievement) {
    final isUnlocked = achievement.isUnlocked;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isUnlocked ? null : Colors.grey.shade100,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? achievement.color.withOpacity(0.15)
                    : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                achievement.icon,
                color: isUnlocked ? achievement.color : Colors.grey,
                size: 24,
              ),
            ),
            SizedBox(height: 8),
            Text(
              achievement.title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isUnlocked ? AppColors.textPrimary : Colors.grey,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (isUnlocked)
              Text('✓', style: TextStyle(fontSize: 12, color: AppColors.success)),
          ],
        ),
      ),
    );
  }
}
