import '../../../../shared/models/auth_user.dart';
import '../../../../shared/services/api_service.dart';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository(this._apiService);

  Future<AuthResponse> login(String username, String password) async {
    final response = await _apiService.post(
      '/auth/login',
      data: {
        'username': username,
        'password': password,
      },
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return AuthResponse.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? '登录失败');
  }

  Future<AuthResponse> wxLogin(String code) async {
    final response = await _apiService.post(
      '/auth/wx-login',
      data: {'code': code},
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return AuthResponse.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? '微信登录失败');
  }

  Future<AuthUser> getProfile() async {
    final response = await _apiService.get('/auth/profile');

    if (response.statusCode == 200 && response.data['success'] == true) {
      return AuthUser.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? '获取用户信息失败');
  }
}
