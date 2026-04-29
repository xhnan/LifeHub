import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/models/psy_assessment.dart';
import '../providers/psy_assessment_provider.dart';

class AssessmentScreen extends ConsumerStatefulWidget {
  final String scaleName;

  const AssessmentScreen({super.key, required this.scaleName});

  @override
  ConsumerState<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends ConsumerState<AssessmentScreen> {
  late List<AssessmentQuestion> questions;
  late List<int?> answers;
  int currentStep = 0;

  @override
  void initState() {
    super.initState();
    final provider = ref.read(psyAssessmentProvider.notifier);
    questions = widget.scaleName == 'PHQ-9'
        ? provider.getPHQ9Questions()
        : provider.getGAD7Questions();
    answers = List.filled(questions.length, null);
  }

  int get totalScore {
    return answers.where((a) => a != null).fold(0, (sum, a) => sum + a!);
  }

  bool get isComplete => answers.every((a) => a != null);

  void _nextQuestion() {
    if (currentStep < questions.length - 1) {
      setState(() {
        currentStep++;
      });
    }
  }

  void _previousQuestion() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
    }
  }

  Future<void> _submit() async {
    if (!isComplete) return;

    final provider = ref.read(psyAssessmentProvider.notifier);
    final severity = provider.getSeverity(widget.scaleName, totalScore);
    final analysis = provider.getAnalysis(widget.scaleName, totalScore);

    final success = await provider.submitAssessment(
      scaleName: widget.scaleName,
      totalScore: totalScore,
      severityLevel: severity,
      resultAnalysis: analysis,
    );

    if (success && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text('评估结果'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '总分：$totalScore',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '严重程度：$severity',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 16),
              Text(
                analysis,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('确定'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentStep];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.scaleName == 'PHQ-9' ? '抑郁筛查 (PHQ-9)' : '焦虑筛查 (GAD-7)'),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (currentStep + 1) / questions.length,
            backgroundColor: AppColors.divider,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '问题 ${currentStep + 1}/${questions.length}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '在过去两周内，以下问题困扰您的频率：',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    question.question,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 24),
                  ...question.options.map((option) => _buildOption(option)),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildOption(AssessmentOption option) {
    final isSelected = answers[currentStep] == option.value;

    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            answers[currentStep] = option.value;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.divider,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    width: 2,
                  ),
                  color: isSelected ? AppColors.primary : Colors.transparent,
                ),
                child: isSelected
                    ? Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  option.label,
                  style: TextStyle(
                    fontSize: 16,
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousQuestion,
                child: Text('上一题'),
              ),
            ),
          if (currentStep > 0) SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: answers[currentStep] == null
                  ? null
                  : currentStep < questions.length - 1
                      ? _nextQuestion
                      : isComplete
                          ? _submit
                          : null,
              child: Text(currentStep < questions.length - 1 ? '下一题' : '提交'),
            ),
          ),
        ],
      ),
    );
  }
}
