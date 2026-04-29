import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/models/agent_models.dart';
import '../providers/profile_providers.dart';

class CheckinScreen extends ConsumerStatefulWidget {
  const CheckinScreen({super.key});

  @override
  ConsumerState<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends ConsumerState<CheckinScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(checkinsProvider.notifier).loadCheckins();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(checkinsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('打卡记录'),
      ),
      body: state.isLoading
          ? Center(child: CircularProgressIndicator())
          : state.checkins.isEmpty
              ? _buildEmptyState()
              : _buildCheckinList(state.checkins),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCheckinDialog(context),
        backgroundColor: AppColors.primary,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16),
          Text(
            '暂无打卡记录',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '点击右下角按钮开始打卡',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckinList(List<Checkin> checkins) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: checkins.length,
      itemBuilder: (context, index) {
        final checkin = checkins[index];
        return _buildCheckinCard(checkin);
      },
    );
  }

  Widget _buildCheckinCard(Checkin checkin) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildStatusChip(checkin.completionStatus),
                Spacer(),
                Text(
                  _formatDate(checkin.checkinDate),
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            if (checkin.adherenceScore != null) ...[
              Row(
                children: [
                  Text(
                    '依从性评分：',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  ...List.generate(5, (index) => Icon(
                    index < checkin.adherenceScore!
                        ? Icons.star
                        : Icons.star_border,
                    size: 20,
                    color: AppColors.warning,
                  )),
                ],
              ),
              SizedBox(height: 8),
            ],
            if (checkin.effectScore != null) ...[
              Row(
                children: [
                  Text(
                    '效果评分：',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  ...List.generate(5, (index) => Icon(
                    index < checkin.effectScore!
                        ? Icons.star
                        : Icons.star_border,
                    size: 20,
                    color: AppColors.primary,
                  )),
                ],
              ),
              SizedBox(height: 8),
            ],
            if (checkin.userFeedback != null && checkin.userFeedback!.isNotEmpty) ...[
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.comment, size: 16, color: AppColors.textSecondary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        checkin.userFeedback!,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (checkin.blockerReason != null && checkin.blockerReason!.isNotEmpty) ...[
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, size: 16, color: AppColors.error),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '阻碍原因：${checkin.blockerReason}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    IconData icon;
    switch (status) {
      case 'done':
        color = AppColors.success;
        label = '已完成';
        icon = Icons.check_circle;
        break;
      case 'partial':
        color = AppColors.warning;
        label = '部分完成';
        icon = Icons.adjust;
        break;
      case 'missed':
        color = AppColors.error;
        label = '未完成';
        icon = Icons.cancel;
        break;
      default:
        color = AppColors.textSecondary;
        label = '待打卡';
        icon = Icons.radio_button_unchecked;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showCheckinDialog(BuildContext context) {
    String selectedStatus = 'done';
    int adherenceScore = 5;
    int effectScore = 5;
    final feedbackController = TextEditingController();
    final blockerController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('每日打卡'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('完成状态'),
                SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatusOption(
                      context,
                      'done',
                      '已完成',
                      AppColors.success,
                      selectedStatus,
                      (value) => setState(() => selectedStatus = value),
                    ),
                    SizedBox(width: 8),
                    _buildStatusOption(
                      context,
                      'partial',
                      '部分',
                      AppColors.warning,
                      selectedStatus,
                      (value) => setState(() => selectedStatus = value),
                    ),
                    SizedBox(width: 8),
                    _buildStatusOption(
                      context,
                      'missed',
                      '未完成',
                      AppColors.error,
                      selectedStatus,
                      (value) => setState(() => selectedStatus = value),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text('依从性评分'),
                SizedBox(height: 8),
                Row(
                  children: List.generate(5, (index) => IconButton(
                    icon: Icon(
                      index < adherenceScore ? Icons.star : Icons.star_border,
                      color: AppColors.warning,
                    ),
                    onPressed: () => setState(() => adherenceScore = index + 1),
                  )),
                ),
                SizedBox(height: 16),
                Text('效果评分'),
                SizedBox(height: 8),
                Row(
                  children: List.generate(5, (index) => IconButton(
                    icon: Icon(
                      index < effectScore ? Icons.star : Icons.star_border,
                      color: AppColors.primary,
                    ),
                    onPressed: () => setState(() => effectScore = index + 1),
                  )),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: feedbackController,
                  decoration: InputDecoration(
                    labelText: '反馈（可选）',
                    hintText: '分享您的感受...',
                  ),
                  maxLines: 3,
                ),
                if (selectedStatus != 'done') ...[
                  SizedBox(height: 16),
                  TextField(
                    controller: blockerController,
                    decoration: InputDecoration(
                      labelText: '阻碍原因',
                      hintText: '是什么阻碍了您完成计划？',
                    ),
                    maxLines: 2,
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('取消'),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await ref.read(checkinsProvider.notifier).createCheckin(
                  checkinDate: DateTime.now(),
                  completionStatus: selectedStatus,
                  adherenceScore: adherenceScore,
                  effectScore: effectScore,
                  userFeedback: feedbackController.text.isNotEmpty ? feedbackController.text : null,
                  blockerReason: blockerController.text.isNotEmpty ? blockerController.text : null,
                );
                if (success && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('打卡成功！')),
                  );
                }
              },
              child: Text('提交'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOption(
    BuildContext context,
    String value,
    String label,
    Color color,
    String selected,
    ValueChanged<String> onSelected,
  ) {
    final isSelected = selected == value;
    return InkWell(
      onTap: () => onSelected(value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}
