import '../../../../shared/models/psy_assessment.dart';
import '../../../../shared/models/psy_profile.dart';
import '../../../../shared/services/api_service.dart';
import '../../domain/repositories/psychology_repository.dart';

class PsychologyRepository implements IPsychologyRepository {
  final ApiService _apiService;

  PsychologyRepository(this._apiService);

  @override
  Future<PsyProfile?> getMyProfile() async {
    final response = await _apiService.get('/health/psychology/profiles/my');

    if (response.statusCode == 200 && response.data['success'] == true) {
      if (response.data['data'] != null) {
        return PsyProfile.fromJson(response.data['data']);
      }
      return null;
    }
    throw Exception(response.data['message'] ?? '获取心理档案失败');
  }

  @override
  Future<bool> initProfile({
    String? mbtiType,
    String? enneagramType,
    int? baselineStressLevel,
  }) async {
    final response = await _apiService.post(
      '/health/psychology/profiles/init',
      data: {
        'mbtiType': mbtiType,
        'enneagramType': enneagramType,
        'baselineStressLevel': baselineStressLevel,
      },
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return true;
    }
    throw Exception(response.data['message'] ?? '初始化心理档案失败');
  }

  @override
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

  @override
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

  @override
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
