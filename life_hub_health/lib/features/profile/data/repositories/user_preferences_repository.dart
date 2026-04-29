import '../../../../shared/models/user_preferences.dart';
import '../../../../shared/services/api_service.dart';

class UserPreferencesRepository {
  final ApiService _apiService;

  UserPreferencesRepository(this._apiService);

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
