import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/providers/providers.dart';
import '../../../psychology/domain/repositories/psychology_repository.dart';
import '../../../psychology/data/repositories/psychology_repository.dart';

final _psyRepoProvider = Provider<IPsychologyRepository>((ref) {
  return PsychologyRepository(ref.read(apiServiceProvider));
});

final _psyProfileProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(_psyRepoProvider).getMyProfile();
});

class PsyProfileViewScreen extends ConsumerWidget {
  const PsyProfileViewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(_psyProfileProvider);

    return Scaffold(
      appBar: AppBar(title: Text('心理档案')),
      body: profileAsync.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败: $e')),
        data: (profile) {
          if (profile == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.psychology_outlined, size: 64, color: AppColors.textSecondary),
                  SizedBox(height: 16),
                  Text('暂未初始化心理档案', style: TextStyle(color: AppColors.textSecondary)),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text('立即初始化'),
                  ),
                ],
              ),
            );
          }
          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('心理档案', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 16),
                      _buildItem('MBTI 类型', profile.mbtiType ?? '未设置'),
                      Divider(),
                      _buildItem('九型人格', profile.enneagramType ?? '未设置'),
                      Divider(),
                      _buildItem('压力基线', profile.baselineStressLevel != null ? '${profile.baselineStressLevel}/10' : '未设置'),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.textSecondary)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
