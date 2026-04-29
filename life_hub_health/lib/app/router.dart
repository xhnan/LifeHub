import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/health_data/presentation/screens/health_data_screen.dart';
import '../features/ai_chat/presentation/screens/ai_chat_screen.dart';
import '../features/psychology/presentation/screens/psychology_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';

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
          ),
          GoRoute(
            path: '/ai-chat',
            builder: (context, state) => AiChatScreen(),
          ),
          GoRoute(
            path: '/psychology',
            builder: (context, state) => PsychologyScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => ProfileScreen(),
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
