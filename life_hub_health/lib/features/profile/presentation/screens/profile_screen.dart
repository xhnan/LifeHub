import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('个人中心'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined),
            onPressed: () => context.push('/profile/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(authState.user),
            SizedBox(height: 24),
            _buildMenuSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(dynamic user) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Icon(
                Icons.person,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.nickname ?? user?.username ?? '用户',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '查看和编辑个人资料',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Card(
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.health_and_safety,
            label: '健康档案',
            onTap: () => context.push('/profile/health-profile'),
          ),
          Divider(height: 1),
          _buildMenuItem(
            icon: Icons.psychology,
            label: '心理档案',
            onTap: () => context.push('/profile/psy-profile'),
          ),
          Divider(height: 1),
          _buildMenuItem(
            icon: Icons.flag,
            label: '健康目标',
            onTap: () {},
          ),
          Divider(height: 1),
          _buildMenuItem(
            icon: Icons.auto_awesome,
            label: 'AI 建议',
            onTap: () {
              context.push('/profile/advice-records');
            },
          ),
          Divider(height: 1),
          _buildMenuItem(
            icon: Icons.assignment,
            label: '跟踪计划',
            onTap: () {
              context.push('/profile/followup-plans');
            },
          ),
          Divider(height: 1),
          _buildMenuItem(
            icon: Icons.checklist,
            label: '打卡记录',
            onTap: () {
              context.push('/profile/checkin');
            },
          ),
          Divider(height: 1),
          _buildMenuItem(
            icon: Icons.psychology_alt,
            label: 'AI 偏好设置',
            onTap: () {
              context.push('/profile/preferences');
            },
          ),
          Divider(height: 1),
          _buildMenuItem(
            icon: Icons.privacy_tip,
            label: '隐私设置',
            onTap: () {},
          ),
          Divider(height: 1),
          _buildMenuItem(
            icon: Icons.help_outline,
            label: '帮助与反馈',
            onTap: () {},
          ),
          Divider(height: 1),
          _buildMenuItem(
            icon: Icons.info_outline,
            label: '关于',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }
}
