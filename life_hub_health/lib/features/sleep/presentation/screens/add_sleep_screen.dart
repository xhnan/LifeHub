import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../providers/sleep_provider.dart';

class AddSleepScreen extends ConsumerStatefulWidget {
  const AddSleepScreen({super.key});

  @override
  ConsumerState<AddSleepScreen> createState() => _AddSleepScreenState();
}

class _AddSleepScreenState extends ConsumerState<AddSleepScreen> {
  DateTime _sleepDate = DateTime.now().subtract(Duration(days: 1));
  TimeOfDay _bedTime = TimeOfDay(hour: 23, minute: 0);
  TimeOfDay _wakeTime = TimeOfDay(hour: 7, minute: 0);
  int _qualityScore = 7;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  int get _calculatedDuration {
    final bedMinutes = _bedTime.hour * 60 + _bedTime.minute;
    final wakeMinutes = _wakeTime.hour * 60 + _wakeTime.minute;
    var diff = wakeMinutes - bedMinutes;
    if (diff < 0) diff += 24 * 60; // 跨午夜
    return diff;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sleepProvider);

    return Scaffold(
      appBar: AppBar(title: Text('记录睡眠')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 日期选择
            Text('睡眠日期', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 18, color: Colors.indigo),
                    SizedBox(width: 12),
                    Text(
                      '${_sleepDate.year}-${_sleepDate.month.toString().padLeft(2, '0')}-${_sleepDate.day.toString().padLeft(2, '0')}',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // 入睡/起床时间
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('入睡时间', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      SizedBox(height: 8),
                      _buildTimePicker(_bedTime, (t) => setState(() => _bedTime = t)),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('起床时间', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      SizedBox(height: 8),
                      _buildTimePicker(_wakeTime, (t) => setState(() => _wakeTime = t)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Center(
              child: Text(
                '睡眠时长：${_calculatedDuration ~/ 60}h ${_calculatedDuration % 60}m',
                style: TextStyle(fontSize: 14, color: Colors.indigo, fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(height: 20),

            // 质量评分
            Text('睡眠质量', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Row(
              children: [
                Text('$_qualityScore', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo)),
                Text(' / 10', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                SizedBox(width: 12),
                Expanded(
                  child: Slider(
                    value: _qualityScore.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    activeColor: Colors.indigo,
                    onChanged: (v) => setState(() => _qualityScore = v.toInt()),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // 备注
            Text('备注（可选）', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: '做了什么梦？有什么影响睡眠的事？',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: state.isCreating ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: state.isCreating
                    ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text('保存记录', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(TimeOfDay time, ValueChanged<TimeOfDay> onChanged) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(context: context, initialTime: time);
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
            SizedBox(width: 8),
            Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _sleepDate,
      firstDate: DateTime.now().subtract(Duration(days: 30)),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => _sleepDate = date);
  }

  Future<void> _submit() async {
    final bedDateTime = DateTime(
      _sleepDate.year, _sleepDate.month, _sleepDate.day,
      _bedTime.hour, _bedTime.minute,
    );
    final wakeDateTime = DateTime(
      _sleepDate.year, _sleepDate.month, _sleepDate.day + (_wakeTime.hour < _bedTime.hour ? 1 : 0),
      _wakeTime.hour, _wakeTime.minute,
    );

    final success = await ref.read(sleepProvider.notifier).createLog(
      sleepDate: _sleepDate,
      bedTime: bedDateTime,
      wakeTime: wakeDateTime,
      durationMinutes: _calculatedDuration,
      qualityScore: _qualityScore,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('睡眠记录已保存 ✓'), behavior: SnackBarBehavior.floating),
      );
    }
  }
}
