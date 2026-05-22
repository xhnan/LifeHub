import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../shared/services/api_service.dart';
import '../../../../shared/providers/providers.dart';

final achievementsProvider = StateNotifierProvider<AchievementsNotifier, AchievementsState>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return AchievementsNotifier(apiService);
});

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.isUnlocked = false,
    this.unlockedAt,
  });
}

class AchievementsState {
  final bool isLoading;
  final int currentStreak;
  final int longestStreak;
  final List<Achievement> achievements;
  final String? error;

  AchievementsState({
    this.isLoading = false,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.achievements = const [],
    this.error,
  });

  int get unlockedCount => achievements.where((a) => a.isUnlocked).length;

  AchievementsState copyWith({
    bool? isLoading,
    int? currentStreak,
    int? longestStreak,
    List<Achievement>? achievements,
    String? error,
  }) {
    return AchievementsState(
      isLoading: isLoading ?? this.isLoading,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      achievements: achievements ?? this.achievements,
      error: error,
    );
  }
}

class AchievementsNotifier extends StateNotifier<AchievementsState> {
  final ApiService _apiService;

  AchievementsNotifier(this._apiService) : super(AchievementsState()) {
    loadAchievements();
  }

  Future<void> loadAchievements() async {
    state = state.copyWith(isLoading: true);
    try {
      // 并行加载打卡、心情、活动数据
      final results = await Future.wait([
        _apiService.get('/health/agent/checkins/my'),
        _apiService.get('/health/psychology/daily-moods/my'),
        _apiService.get('/health/activities/my'),
        _apiService.get('/health/weight-logs/my'),
        _apiService.get('/health/diet-logs/my'),
      ]);

      final checkinData = _extractList(results[0]);
      final moodData = _extractList(results[1]);
      final activityData = _extractList(results[2]);
      final weightData = _extractList(results[3]);
      final dietData = _extractList(results[4]);

      // 计算打卡连续天数
      final streakResult = _calculateStreak(checkinData);
      final currentStreak = streakResult['current'] ?? 0;
      final longestStreak = streakResult['longest'] ?? 0;

      // 计算心情连续记录天数
      final moodStreak = _calculateMoodStreak(moodData);

      // 检查早起鸟
      final earlyBirdDays = _countEarlyBirdDays(activityData);

      // 检查是否用过所有功能
      final hasUsedAll = checkinData.isNotEmpty &&
          moodData.isNotEmpty &&
          activityData.isNotEmpty &&
          weightData.isNotEmpty &&
          dietData.isNotEmpty;

      // 生成成就列表
      final achievements = _generateAchievements(
        totalCheckins: checkinData.length,
        longestStreak: longestStreak,
        moodStreak: moodStreak,
        earlyBirdDays: earlyBirdDays,
        hasUsedAll: hasUsedAll,
        totalActivities: activityData.length,
        totalWeightLogs: weightData.length,
      );

      state = state.copyWith(
        isLoading: false,
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        achievements: achievements,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ErrorHandler.getFriendlyMessage(e),
        achievements: _generateAchievements(),
      );
    }
  }

  List<dynamic> _extractList(dynamic response) {
    if (response.statusCode == 200 && response.data['success'] == true) {
      final data = response.data['data'];
      if (data is List) return data;
    }
    return [];
  }

  Map<String, int> _calculateStreak(List<dynamic> checkinData) {
    if (checkinData.isEmpty) return {'current': 0, 'longest': 0};

    final dates = checkinData
        .map((e) {
          final dateStr = e['checkinDate']?.toString();
          if (dateStr == null) return null;
          return DateTime.tryParse(dateStr);
        })
        .where((d) => d != null)
        .map((d) => DateTime(d!.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort();

    if (dates.isEmpty) return {'current': 0, 'longest': 0};

    int streak = 1;
    int maxStreak = 1;
    for (int i = 1; i < dates.length; i++) {
      if (dates[i].difference(dates[i - 1]).inDays == 1) {
        streak++;
        if (streak > maxStreak) maxStreak = streak;
      } else {
        streak = 1;
      }
    }

    // 检查当前连续是否包含今天或昨天
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final yesterday = todayDate.subtract(Duration(days: 1));
    int currentStreak = 0;
    if (dates.last == todayDate || dates.last == yesterday) {
      currentStreak = streak;
    }

    return {'current': currentStreak, 'longest': maxStreak};
  }

  int _calculateMoodStreak(List<dynamic> moodData) {
    if (moodData.isEmpty) return 0;

    final dates = moodData
        .map((e) {
          final dateStr = e['recordDate']?.toString() ?? e['createdAt']?.toString();
          if (dateStr == null) return null;
          return DateTime.tryParse(dateStr);
        })
        .where((d) => d != null)
        .map((d) => DateTime(d!.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort();

    if (dates.isEmpty) return 0;

    int maxStreak = 1;
    int streak = 1;
    for (int i = 1; i < dates.length; i++) {
      if (dates[i].difference(dates[i - 1]).inDays == 1) {
        streak++;
        if (streak > maxStreak) maxStreak = streak;
      } else {
        streak = 1;
      }
    }
    return maxStreak;
  }

  int _countEarlyBirdDays(List<dynamic> activityData) {
    int count = 0;
    for (final activity in activityData) {
      final timeStr = activity['startTime']?.toString() ?? activity['createdAt']?.toString();
      if (timeStr != null) {
        final time = DateTime.tryParse(timeStr);
        if (time != null && time.hour < 6) {
          count++;
        }
      }
    }
    return count;
  }

  List<Achievement> _generateAchievements({
    int totalCheckins = 0,
    int longestStreak = 0,
    int moodStreak = 0,
    int earlyBirdDays = 0,
    bool hasUsedAll = false,
    int totalActivities = 0,
    int totalWeightLogs = 0,
  }) {
    return [
      Achievement(
        id: 'first_checkin',
        title: '初次打卡',
        description: '完成第一次打卡',
        icon: Icons.flag,
        color: Colors.green,
        isUnlocked: totalCheckins > 0,
      ),
      Achievement(
        id: 'streak_7',
        title: '坚持一周',
        description: '连续打卡 7 天',
        icon: Icons.looks_one,
        color: Colors.blue,
        isUnlocked: longestStreak >= 7,
      ),
      Achievement(
        id: 'streak_30',
        title: '月度坚持',
        description: '连续打卡 30 天',
        icon: Icons.military_tech,
        color: Colors.orange,
        isUnlocked: longestStreak >= 30,
      ),
      Achievement(
        id: 'streak_100',
        title: '百日达人',
        description: '连续打卡 100 天',
        icon: Icons.star,
        color: Colors.amber,
        isUnlocked: longestStreak >= 100,
      ),
      Achievement(
        id: 'checkins_50',
        title: '半百记录',
        description: '累计打卡 50 次',
        icon: Icons.check_circle,
        color: Colors.teal,
        isUnlocked: totalCheckins >= 50,
      ),
      Achievement(
        id: 'checkins_200',
        title: '记录大师',
        description: '累计打卡 200 次',
        icon: Icons.workspace_premium,
        color: Colors.purple,
        isUnlocked: totalCheckins >= 200,
      ),
      Achievement(
        id: 'early_bird',
        title: '早起鸟',
        description: '5 次 6 点前记录运动',
        icon: Icons.wb_sunny,
        color: Colors.orange.shade300,
        isUnlocked: earlyBirdDays >= 5,
      ),
      Achievement(
        id: 'health_explorer',
        title: '健康探索者',
        description: '使用所有功能模块',
        icon: Icons.explore,
        color: Colors.indigo,
        isUnlocked: hasUsedAll,
      ),
      Achievement(
        id: 'mood_tracker',
        title: '情绪记录者',
        description: '连续记录心情 7 天',
        icon: Icons.mood,
        color: Colors.pink,
        isUnlocked: moodStreak >= 7,
      ),
      Achievement(
        id: 'fitness_starter',
        title: '运动新手',
        description: '累计记录 10 次运动',
        icon: Icons.fitness_center,
        color: Colors.blue.shade700,
        isUnlocked: totalActivities >= 10,
      ),
      Achievement(
        id: 'weight_watcher',
        title: '体重关注者',
        description: '累计记录体重 20 次',
        icon: Icons.monitor_weight,
        color: Colors.green.shade700,
        isUnlocked: totalWeightLogs >= 20,
      ),
    ];
  }
}
