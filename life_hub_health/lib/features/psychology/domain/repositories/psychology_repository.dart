import '../../../../shared/models/psy_assessment.dart';
import '../../../../shared/models/psy_profile.dart';

abstract class IPsychologyRepository {
  Future<PsyProfile?> getMyProfile();
  Future<bool> initProfile({
    String? mbtiType,
    String? enneagramType,
    int? baselineStressLevel,
  });
  Future<List<PsyAssessment>> getMyAssessments({String? scaleName});
  Future<PsyAssessment?> getLatestAssessment();
  Future<bool> createAssessment({
    required String scaleName,
    required int totalScore,
    String? severityLevel,
    String? resultAnalysis,
  });
}
