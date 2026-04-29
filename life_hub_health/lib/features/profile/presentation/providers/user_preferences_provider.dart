import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/user_preferences.dart';
import '../../../../shared/providers/providers.dart';
import '../../data/repositories/user_preferences_repository.dart';

final userPreferencesRepositoryProvider = Provider<UserPreferencesRepository>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return UserPreferencesRepository(apiService);
});

final userPreferencesProvider = StateNotifierProvider<UserPreferencesNotifier, UserPreferencesState>((ref) {
  final repository = ref.read(userPreferencesRepositoryProvider);
  return UserPreferencesNotifier(repository);
});

class UserPreferencesState {
  final bool isLoading;
  final UserPreferences? preferences;
  final String? error;

  UserPreferencesState({
    this.isLoading = false,
    this.preferences,
    this.error,
  });

  UserPreferencesState copyWith({
    bool? isLoading,
    UserPreferences? preferences,
    String? error,
  }) {
    return UserPreferencesState(
      isLoading: isLoading ?? this.isLoading,
      preferences: preferences ?? this.preferences,
      error: error,
    );
  }
}

class UserPreferencesNotifier extends StateNotifier<UserPreferencesState> {
  final UserPreferencesRepository _repository;

  UserPreferencesNotifier(this._repository) : super(UserPreferencesState()) {
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final preferences = await _repository.getMyPreferences();
      state = state.copyWith(isLoading: false, preferences: preferences);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
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
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.savePreferences(
        preferredDietStyle: preferredDietStyle,
        dislikedFoods: dislikedFoods,
        preferredExerciseTypes: preferredExerciseTypes,
        preferredSupportStyle: preferredSupportStyle,
        routinePattern: routinePattern,
        motivationTags: motivationTags,
        habitProfile: habitProfile,
      );
      await loadPreferences();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
