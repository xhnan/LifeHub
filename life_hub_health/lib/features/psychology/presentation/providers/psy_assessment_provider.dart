import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../shared/models/psy_assessment.dart';
import '../../../../shared/providers/providers.dart';
import '../../domain/repositories/psychology_repository.dart';
import '../../data/repositories/psychology_repository.dart';

final psychologyRepositoryProvider = Provider<IPsychologyRepository>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return PsychologyRepository(apiService);
});

final psyAssessmentProvider = StateNotifierProvider<PsyAssessmentNotifier, PsyAssessmentState>((ref) {
  final repository = ref.read(psychologyRepositoryProvider);
  return PsyAssessmentNotifier(repository);
});

const _sentinel = Object();

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
    Object? latestAssessment = _sentinel,
    String? error,
  }) {
    return PsyAssessmentState(
      isLoading: isLoading ?? this.isLoading,
      assessments: assessments ?? this.assessments,
      latestAssessment: latestAssessment == _sentinel ? this.latestAssessment : latestAssessment as PsyAssessment?,
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
        error: ErrorHandler.getFriendlyMessage(e),
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
        error: ErrorHandler.getFriendlyMessage(e),
      );
      return false;
    }
  }

  List<AssessmentQuestion> getPHQ9Questions() {
    return AssessmentScoring.getQuestions('PHQ-9');
  }

  List<AssessmentQuestion> getGAD7Questions() {
    return AssessmentScoring.getQuestions('GAD-7');
  }

  String getSeverity(String scaleName, int score) {
    return AssessmentScoring.getSeverity(scaleName, score);
  }

  String getAnalysis(String scaleName, int score) {
    return AssessmentScoring.getAnalysis(scaleName, score);
  }
}
