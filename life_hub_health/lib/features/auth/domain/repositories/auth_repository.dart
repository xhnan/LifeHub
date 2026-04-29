import '../../../../shared/models/auth_user.dart';

abstract class IAuthRepository {
  Future<AuthResponse> login(String username, String password);
  Future<AuthResponse> wxLogin(String code);
  Future<AuthUser> getProfile();
}
