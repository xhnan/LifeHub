import '../../../../shared/models/agent_models.dart';
import '../../../../shared/models/user_preferences.dart';
import '../../../../shared/services/api_service.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepository implements IProfileRepository {
  final ApiService _apiService;

  ProfileRepository(this._apiService);

  @override
  Future<List<AdviceRecord>> getMyAdviceRecords({
    String? agentType,
    bool? activeOnly,
  }) async {
    final queryParams = <String, dynamic>{};
    if (agentType != null) queryParams['agentType'] = agentType;
    if (activeOnly != null) queryParams['activeOnly'] = activeOnly;

    final response = await _apiService.get(
      '/health/agent/advice-records/my',
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      final List<dynamic> data = response.data['data'];
      return data.map((json) => AdviceRecord.fromJson(json)).toList();
    }
    throw Exception(response.data['message'] ?? '获取建议记录失败');
  }

  @override
  Future<List<FollowupPlan>> getMyFollowupPlans({bool? activeOnly}) async {
    final queryParams = <String, dynamic>{};
    if (activeOnly != null) queryParams['activeOnly'] = activeOnly;

    final response = await _apiService.get(
      '/health/agent/followup-plans/my',
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      final List<dynamic> data = response.data['data'];
      return data.map((json) => FollowupPlan.fromJson(json)).toList();
    }
    throw Exception(response.data['message'] ?? '获取跟踪计划失败');
  }

  @override
  Future<List<Checkin>> getMyCheckins({int? followupPlanId}) async {
    final queryParams = <String, dynamic>{};
    if (followupPlanId != null) queryParams['followupPlanId'] = followupPlanId;

    final response = await _apiService.get(
      '/health/agent/checkins/my',
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      final List<dynamic> data = response.data['data'];
      return data.map((json) => Checkin.fromJson(json)).toList();
    }
    throw Exception(response.data['message'] ?? '获取打卡记录失败');
  }

  @override
  Future<bool> createCheckin({
    int? adviceRecordId,
    int? followupPlanId,
    required DateTime checkinDate,
    required String completionStatus,
    int? adherenceScore,
    int? effectScore,
    String? userFeedback,
    String? blockerReason,
  }) async {
    final response = await _apiService.post(
      '/health/agent/checkins',
      data: {
        'adviceRecordId': adviceRecordId,
        'followupPlanId': followupPlanId,
        'checkinDate': checkinDate.toIso8601String().split('T')[0],
        'completionStatus': completionStatus,
        'adherenceScore': adherenceScore,
        'effectScore': effectScore,
        'userFeedback': userFeedback,
        'blockerReason': blockerReason,
      },
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return true;
    }
    throw Exception(response.data['message'] ?? '打卡失败');
  }

  @override
  Future<UserPreferences?> getMyPreferences() async {
    final response = await _apiService.get('/health/agent/user-preferences/my');

    if (response.statusCode == 200 && response.data['success'] == true) {
      if (response.data['data'] != null) {
        return UserPreferences.fromJson(response.data['data']);
      }
      return null;
    }
    throw Exception(response.data['message'] ?? '获取偏好设置失败');
  }

  @override
  Future<bool> savePreferences({
    String? preferredDietStyle,
    String? dislikedFoods,
    String? preferredExerciseTypes,
    String? preferredSupportStyle,
    String? routinePattern,
    String? motivationTags,
    Map<String, dynamic>? habitProfile,
  }) async {
    final response = await _apiService.post(
      '/health/agent/user-preferences',
      data: {
        'preferredDietStyle': preferredDietStyle,
        'dislikedFoods': dislikedFoods,
        'preferredExerciseTypes': preferredExerciseTypes,
        'preferredSupportStyle': preferredSupportStyle,
        'routinePattern': routinePattern,
        'motivationTags': motivationTags,
        'habitProfile': habitProfile,
      },
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return true;
    }
    throw Exception(response.data['message'] ?? '保存偏好设置失败');
  }
}
