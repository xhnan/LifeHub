import '../../../../shared/models/psy_assessment.dart';
import '../../../../shared/services/api_service.dart';

class PsyAssessmentRepository {
  final ApiService _apiService;

  PsyAssessmentRepository(this._apiService);

  Future<List<PsyAssessment>> getMyAssessments({String? scaleName}) async {
    final queryParams = <String, dynamic>{};
    if (scaleName != null) queryParams['scaleName'] = scaleName;

    final response = await _apiService.get(
      '/health/psychology/assessments/my',
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      final List<dynamic> data = response.data['data'];
      return data.map((json) => PsyAssessment.fromJson(json)).toList();
    }
    throw Exception(response.data['message'] ?? '获取评估记录失败');
  }

  Future<PsyAssessment?> getLatestAssessment() async {
    final response = await _apiService.get('/health/psychology/assessments/latest');

    if (response.statusCode == 200 && response.data['success'] == true) {
      if (response.data['data'] != null) {
        return PsyAssessment.fromJson(response.data['data']);
      }
      return null;
    }
    throw Exception(response.data['message'] ?? '获取最新评估失败');
  }

  Future<bool> createAssessment({
    required String scaleName,
    required int totalScore,
    String? severityLevel,
    String? resultAnalysis,
  }) async {
    final response = await _apiService.post(
      '/health/psychology/assessments',
      data: {
        'scaleName': scaleName,
        'totalScore': totalScore,
        'severityLevel': severityLevel,
        'resultAnalysis': resultAnalysis,
      },
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return true;
    }
    throw Exception(response.data['message'] ?? '保存评估失败');
  }
}
