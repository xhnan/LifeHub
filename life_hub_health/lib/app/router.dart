import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/health_data/presentation/screens/health_data_screen.dart';
import '../features/health_data/presentation/screens/add_activity_screen.dart';
import '../features/health_data/presentation/screens/add_diet_screen.dart';
import '../features/health_data/presentation/screens/add_weight_screen.dart';
import '../features/health_data/presentation/screens/health_stats_screen.dart';
import '../features/ai_chat/presentation/screens/ai_chat_screen.dart';
import '../features/psychology/presentation/screens/psychology_screen.dart';
import '../features/psychology/presentation/screens/assessment_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/profile/presentation/screens/advice_records_screen.dart';
import '../features/profile/presentation/screens/followup_plans_screen.dart';
import '../features/profile/presentation/screens/checkin_screen.dart';
import '../features/profile/presentation/screens/user_preferences_screen.dart';
import '../features/profile/presentation/screens/settings_screen.dart';
import '../features/profile/presentation/screens/health_profile_screen.dart';
import '../features/profile/presentation/screens/psy_profile_view_screen.dart';
import '../features/profile/presentation/screens/data_export_screen.dart';
import '../features/goals/presentation/screens/goals_screen.dart';
import '../features/goals/presentation/screens/add_goal_screen.dart';
import '../features/sleep/presentation/screens/sleep_screen.dart';
import '../features/sleep/presentation/screens/add_sleep_screen.dart';
import '../features/water/presentation/screens/water_screen.dart';
import '../features/reports/presentation/screens/health_report_screen.dart';
import '../features/achievements/presentation/screens/achievements_screen.dart';
import '../features/notifications/presentation/screens/reminders_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isLoginRoute = state.uri.path == '/login';

      if (!isLoggedIn && !isLoginRoute) {
        return '/login';
      }
      if (isLoggedIn && isLoginRoute) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(),
      ),
        ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => HomeScreen(),
          ),
          GoRoute(
            path: '/health-data',
            builder: (context, state) => HealthDataScreen(),
            routes: [
              GoRoute(
                path: 'add-activity',
                builder: (context, state) => AddActivityScreen(),
              ),
              GoRoute(
                path: 'add-diet',
                builder: (context, state) => AddDietScreen(),
              ),
              GoRoute(
                path: 'add-weight',
                builder: (context, state) => AddWeightScreen(),
              ),
              GoRoute(
                path: 'stats',
                builder: (context, state) => HealthStatsScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/ai-chat',
            builder: (context, state) => AiChatScreen(),
          ),
          GoRoute(
            path: '/psychology',
            builder: (context, state) => PsychologyScreen(),
            routes: [
              GoRoute(
                path: 'assessment/:scaleName',
                builder: (context, state) => AssessmentScreen(
                  scaleName: state.pathParameters['scaleName']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => ProfileScreen(),
            routes: [
              GoRoute(
                path: 'advice-records',
                builder: (context, state) => AdviceRecordsScreen(),
              ),
              GoRoute(
                path: 'followup-plans',
                builder: (context, state) => FollowupPlansScreen(),
              ),
              GoRoute(
                path: 'checkin',
                builder: (context, state) => CheckinScreen(),
              ),
              GoRoute(
                path: 'preferences',
                builder: (context, state) => UserPreferencesScreen(),
              ),
              GoRoute(
                path: 'settings',
                builder: (context, state) => SettingsScreen(),
              ),
              GoRoute(
                path: 'health-profile',
                builder: (context, state) => HealthProfileScreen(),
              ),
              GoRoute(
                path: 'psy-profile',
                builder: (context, state) => PsyProfileViewScreen(),
              ),
              GoRoute(
                path: 'goals',
                builder: (context, state) => GoalsScreen(),
              ),
              GoRoute(
                path: 'goals/add',
                builder: (context, state) => AddGoalScreen(),
              ),
              GoRoute(
                path: 'sleep',
                builder: (context, state) => SleepScreen(),
              ),
              GoRoute(
                path: 'sleep/add',
                builder: (context, state) => AddSleepScreen(),
              ),
              GoRoute(
                path: 'water',
                builder: (context, state) => WaterScreen(),
              ),
              GoRoute(
                path: 'reports',
                builder: (context, state) => HealthReportScreen(),
              ),
              GoRoute(
                path: 'achievements',
                builder: (context, state) => AchievementsScreen(),
              ),
              GoRoute(
                path: 'reminders',
                builder: (context, state) => RemindersScreen(),
              ),
              GoRoute(
                path: 'data-export',
                builder: (context, state) => DataExportScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _getCurrentIndex(context),
        onTap: (index) => _onItemTapped(context, index),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.health_and_safety),
            label: '健康数据',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'AI 助手',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology),
            label: '心理健康',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/health-data')) return 1;
    if (location.startsWith('/ai-chat')) return 2;
    if (location.startsWith('/psychology')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/health-data');
        break;
      case 2:
        context.go('/ai-chat');
        break;
      case 3:
        context.go('/psychology');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }
}
