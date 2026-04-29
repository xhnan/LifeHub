import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/auth_user.dart';
import '../../../../shared/services/local_storage_service.dart';
import '../../../../shared/providers/providers.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return AuthRepository(apiService);
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  final localStorageService = ref.read(localStorageServiceProvider);
  return AuthNotifier(authRepository, localStorageService);
});

class AuthState {
  final bool isLoading;
  final AuthUser? user;
  final String? error;
  final bool isAuthenticated;

  AuthState({
    this.isLoading = false,
    this.user,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    bool? isLoading,
    AuthUser? user,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final IAuthRepository _authRepository;
  final LocalStorageService _localStorageService;

  AuthNotifier(this._authRepository, this._localStorageService) : super(AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final token = await _localStorageService.getToken();
    if (token != null) {
      try {
        final user = await _authRepository.getProfile();
        state = state.copyWith(user: user, isAuthenticated: true);
      } catch (e) {
        await _localStorageService.clearTokens();
        state = state.copyWith(isAuthenticated: false);
      }
    }
  }

  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final authResponse = await _authRepository.login(username, password);
      await _localStorageService.saveToken(authResponse.token);
      if (authResponse.refreshToken != null) {
        await _localStorageService.saveRefreshToken(authResponse.refreshToken!);
      }
      state = state.copyWith(
        isLoading: false,
        user: authResponse.user,
        isAuthenticated: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _localStorageService.clearTokens();
    state = AuthState();
  }
}
