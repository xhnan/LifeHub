import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/error_handler.dart';
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

class PsyProfileViewScreen extends ConsumerStatefulWidget {
  const PsyProfileViewScreen({super.key});

  @override
  ConsumerState<PsyProfileViewScreen> createState() => _PsyProfileViewScreenState();
}

class _PsyProfileViewScreenState extends ConsumerState<PsyProfileViewScreen> {
  bool _isInitializing = false;

  Future<void> _handleInit() async {
    setState(() => _isInitializing = true);
    try {
      final success = await ref.read(_psyRepoProvider).initProfile();
      if (success && mounted) {
        ref.invalidate(_psyProfileProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ErrorHandler.getFriendlyMessage(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _isInitializing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(_psyProfileProvider);

    return Scaffold(
      appBar: AppBar(title: Text('心理档案')),
      body: profileAsync.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.error),
              SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(ErrorHandler.getFriendlyMessage(e), style: TextStyle(color: AppColors.error), textAlign: TextAlign.center),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(_psyProfileProvider),
                child: Text('重试'),
              ),
            ],
          ),
        ),
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
                    onPressed: _isInitializing ? null : _handleInit,
                    child: _isInitializing
                        ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text('立即初始化'),
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
