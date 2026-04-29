import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../app/app.dart';
import '../../../../shared/providers/providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: Text('设置')),
      body: ListView(
        children: [
          _buildSection(
            title: '外观',
            children: [
              ListTile(
                leading: Icon(Icons.palette_outlined, color: AppColors.primary),
                title: Text('主题模式'),
                subtitle: Text(_getThemeName(themeMode)),
                trailing: Icon(Icons.chevron_right),
                onTap: () => _showThemeDialog(context, ref),
              ),
            ],
          ),
          _buildSection(
            title: '数据',
            children: [
              ListTile(
                leading: Icon(Icons.delete_outline, color: AppColors.error),
                title: Text('清除缓存'),
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('确认清除'),
                      content: Text('将清除本地缓存数据，不影响云端数据。'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('取消')),
                        TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('确定')),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await ref.read(localStorageServiceProvider).clearCache();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('缓存已清除')));
                    }
                  }
                },
              ),
            ],
          ),
          _buildSection(
            title: '账号',
            children: [
              ListTile(
                leading: Icon(Icons.logout, color: AppColors.error),
                title: Text('退出登录', style: TextStyle(color: AppColors.error)),
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('确认退出'),
                      content: Text('确定要退出登录吗？'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('取消')),
                        TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('确定')),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await ref.read(authProvider.notifier).logout();
                  }
                },
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'LifeHub Health v1.0.0',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(title, style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        ),
        Card(margin: EdgeInsets.symmetric(horizontal: 16), child: Column(children: children)),
      ],
    );
  }

  String _getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system: return '跟随系统';
      case ThemeMode.light: return '浅色';
      case ThemeMode.dark: return '深色';
    }
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text('选择主题'),
        children: [
          SimpleDialogOption(child: Text('跟随系统'), onPressed: () { ref.read(themeModeProvider.notifier).state = ThemeMode.system; Navigator.pop(ctx); }),
          SimpleDialogOption(child: Text('浅色'), onPressed: () { ref.read(themeModeProvider.notifier).state = ThemeMode.light; Navigator.pop(ctx); }),
          SimpleDialogOption(child: Text('深色'), onPressed: () { ref.read(themeModeProvider.notifier).state = ThemeMode.dark; Navigator.pop(ctx); }),
        ],
      ),
    );
  }
}
