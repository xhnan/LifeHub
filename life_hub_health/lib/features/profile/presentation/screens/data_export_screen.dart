import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/providers/providers.dart';

class DataExportScreen extends ConsumerStatefulWidget {
  const DataExportScreen({super.key});

  @override
  ConsumerState<DataExportScreen> createState() => _DataExportScreenState();
}

class _DataExportScreenState extends ConsumerState<DataExportScreen> {
  bool _isExporting = false;
  String? _exportResult;

  final _exportOptions = [
    _ExportOption('activities', '运动记录', Icons.fitness_center, true),
    _ExportOption('diet-logs', '饮食记录', Icons.restaurant, true),
    _ExportOption('weight-logs', '体重记录', Icons.monitor_weight, true),
    _ExportOption('daily-summaries', '每日汇总', Icons.summarize, true),
    _ExportOption('psychology/daily-moods', '心情记录', Icons.mood, true),
    _ExportOption('psychology/assessments', '心理评估', Icons.psychology, true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('数据导出')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 18, color: AppColors.textSecondary),
                        SizedBox(width: 8),
                        Text('导出说明', style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '选择要导出的数据类型，将以 JSON 格式保存到设备存储中。',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Text('选择导出内容', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _exportOptions.length,
                itemBuilder: (context, index) {
                  final option = _exportOptions[index];
                  return CheckboxListTile(
                    value: option.selected,
                    onChanged: (v) => setState(() => option.selected = v ?? false),
                    title: Text(option.label),
                    secondary: Icon(option.icon, color: AppColors.primary),
                    controlAffinity: ListTileControlAffinity.trailing,
                  );
                },
              ),
            ),
            if (_exportResult != null) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _exportResult!,
                  style: TextStyle(fontSize: 13, color: AppColors.success),
                ),
              ),
              SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isExporting ? null : _export,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: _isExporting
                    ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Icon(Icons.download, color: Colors.white),
                label: Text(
                  _isExporting ? '导出中...' : '导出数据',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _export() async {
    final selectedOptions = _exportOptions.where((o) => o.selected).toList();
    if (selectedOptions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请选择至少一项导出内容'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    setState(() {
      _isExporting = true;
      _exportResult = null;
    });

    try {
      final api = ref.read(apiServiceProvider);
      final exportData = <String, dynamic>{
        'exportTime': DateTime.now().toIso8601String(),
        'appVersion': '1.0.0',
      };

      for (final option in selectedOptions) {
        try {
          final response = await api.get('/health/${option.apiPath}/my');
          if (response.statusCode == 200 && response.data['success'] == true) {
            exportData[option.apiPath.replaceAll('/', '_')] = response.data['data'];
          }
        } catch (_) {
          exportData[option.apiPath.replaceAll('/', '_')] = null;
        }
      }

      // 保存到 app 文档目录
      final jsonStr = JsonEncoder.withIndent('  ').convert(exportData);
      final dir = Directory('/storage/emulated/0/Download');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      final fileName = 'lifehub_health_export_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(jsonStr);

      setState(() {
        _isExporting = false;
        _exportResult = '✓ 导出成功！\n文件：$fileName\n路径：${dir.path}';
      });
    } catch (e) {
      setState(() {
        _isExporting = false;
        _exportResult = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败: $e'), behavior: SnackBarBehavior.floating, backgroundColor: AppColors.error),
        );
      }
    }
  }
}

class _ExportOption {
  final String apiPath;
  final String label;
  final IconData icon;
  bool selected;

  _ExportOption(this.apiPath, this.label, this.icon, this.selected);
}
