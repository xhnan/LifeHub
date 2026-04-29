import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/psy_assessment.dart';
import '../../../../shared/providers/providers.dart';
import '../../domain/repositories/psychology_repository.dart';
import '../../data/repositories/psychology_repository.dart';
import '../../data/datasources/assessment_datasource.dart';

final psychologyRepositoryProvider = Provider<IPsychologyRepository>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return PsychologyRepository(apiService);
});

final psyAssessmentProvider = StateNotifierProvider<PsyAssessmentNotifier, PsyAssessmentState>((ref) {
  final repository = ref.read(psychologyRepositoryProvider);
  return PsyAssessmentNotifier(repository);
});

class PsyAssessmentState {
  final bool isLoading;
  final List<PsyAssessment> assessments;
  final PsyAssessment? latestAssessment;
  final String? error;

  PsyAssessmentState({
    this.isLoading = false,
    this.assessments = const [],
    this.latestAssessment,
    this.error,
  });

  PsyAssessmentState copyWith({
    bool? isLoading,
    List<PsyAssessment>? assessments,
    PsyAssessment? latestAssessment,
    String? error,
  }) {
    return PsyAssessmentState(
      isLoading: isLoading ?? this.isLoading,
      assessments: assessments ?? this.assessments,
      latestAssessment: latestAssessment ?? this.latestAssessment,
      error: error,
    );
  }
}

class PsyAssessmentNotifier extends StateNotifier<PsyAssessmentState> {
  final IPsychologyRepository _repository;

  PsyAssessmentNotifier(this._repository) : super(PsyAssessmentState()) {
    loadAssessments();
  }

  Future<void> loadAssessments() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final assessments = await _repository.getMyAssessments();
      final latestAssessment = await _repository.getLatestAssessment();
      state = state.copyWith(
        isLoading: false,
        assessments: assessments,
        latestAssessment: latestAssessment,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> submitAssessment({
    required String scaleName,
    required int totalScore,
    String? severityLevel,
    String? resultAnalysis,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.createAssessment(
        scaleName: scaleName,
        totalScore: totalScore,
        severityLevel: severityLevel,
        resultAnalysis: resultAnalysis,
      );
      await loadAssessments();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  List<AssessmentQuestion> getPHQ9Questions() {
    return AssessmentDataSource.getPHQ9Questions();
  }

  List<AssessmentQuestion> getGAD7Questions() {
    return AssessmentDataSource.getGAD7Questions();
  }

  String getSeverity(String scaleName, int score) {
    if (scaleName == 'PHQ-9') {
      return AssessmentDataSource.getPHQ9Severity(score);
    } else if (scaleName == 'GAD-7') {
      return AssessmentDataSource.getGAD7Severity(score);
    }
    return '';
  }

  String getAnalysis(String scaleName, int score) {
    if (scaleName == 'PHQ-9') {
      return AssessmentDataSource.getPHQ9Analysis(score);
    } else if (scaleName == 'GAD-7') {
      return AssessmentDataSource.getGAD7Analysis(score);
    }
    return '';
  }
}
