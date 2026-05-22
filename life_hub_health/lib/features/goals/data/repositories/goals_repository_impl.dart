import '../../../../shared/models/health_goal.dart';
import '../../../../shared/services/api_service.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/repositories/goals_repository.dart';

class GoalsRepositoryImpl implements IGoalsRepository {
  final ApiService _apiService;

  GoalsRepositoryImpl(this._apiService);

  @override
  Future<List<HealthGoal>> getMyGoals({String? status, String? goalType}) async {
    final params = <String, dynamic>{};
    if (status != null) params['status'] = status;
    if (goalType != null) params['goalType'] = goalType;

    final response = await _apiService.get(
      '/health/goals/my',
      queryParameters: params.isEmpty ? null : params,
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      final data = response.data['data'];
      if (data != null && data is List) {
        return data.map((e) => HealthGoal.fromJson(e)).toList();
      }
      return [];
    }
    throw Exception(response.data['message'] ?? '获取健康目标失败');
  }

  @override
  Future<HealthGoal> createGoal({
    required String goalType,
    required double targetValue,
    DateTime? deadline,
  }) async {
    final body = <String, dynamic>{
      'goalType': goalType,
      'targetValue': targetValue,
    };
    if (deadline != null) {
      body['deadline'] = AppDateUtils.formatDate(deadline);
    }

    final response = await _apiService.post('/health/goals', data: body);

    if (response.statusCode == 200 && response.data['success'] == true) {
      return HealthGoal.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? '创建目标失败');
  }

  @override
  Future<void> updateGoalStatus(int goalId, String status) async {
    final response = await _apiService.put(
      '/health/goals/$goalId',
      data: {'status': status},
    );

    if (response.statusCode != 200 || response.data['success'] != true) {
      throw Exception(response.data['message'] ?? '更新目标状态失败');
    }
  }
}
