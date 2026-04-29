import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/agent_models.dart';
import '../../../../shared/models/user_preferences.dart';
import '../../../../shared/providers/providers.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../data/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<IProfileRepository>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return ProfileRepository(apiService);
});

// Separate providers for each feature
final adviceRecordsProvider = StateNotifierProvider<AdviceRecordsNotifier, AdviceRecordsState>((ref) {
  final repository = ref.read(profileRepositoryProvider);
  return AdviceRecordsNotifier(repository);
});

final followupPlansProvider = StateNotifierProvider<FollowupPlansNotifier, FollowupPlansState>((ref) {
  final repository = ref.read(profileRepositoryProvider);
  return FollowupPlansNotifier(repository);
});

final checkinsProvider = StateNotifierProvider<CheckinsNotifier, CheckinsState>((ref) {
  final repository = ref.read(profileRepositoryProvider);
  return CheckinsNotifier(repository);
});

final userPreferencesProvider = StateNotifierProvider<UserPreferencesNotifier, UserPreferencesState>((ref) {
  final repository = ref.read(profileRepositoryProvider);
  return UserPreferencesNotifier(repository);
});

// Advice Records
class AdviceRecordsState {
  final bool isLoading;
  final List<AdviceRecord> records;
  final String? error;

  AdviceRecordsState({
    this.isLoading = false,
    this.records = const [],
    this.error,
  });

  AdviceRecordsState copyWith({
    bool? isLoading,
    List<AdviceRecord>? records,
    String? error,
  }) {
    return AdviceRecordsState(
      isLoading: isLoading ?? this.isLoading,
      records: records ?? this.records,
      error: error,
    );
  }
}

class AdviceRecordsNotifier extends StateNotifier<AdviceRecordsState> {
  final IProfileRepository _repository;

  AdviceRecordsNotifier(this._repository) : super(AdviceRecordsState());

  Future<void> loadRecords({String? agentType, bool? activeOnly}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final records = await _repository.getMyAdviceRecords(
        agentType: agentType,
        activeOnly: activeOnly,
      );
      state = state.copyWith(isLoading: false, records: records);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// Followup Plans
class FollowupPlansState {
  final bool isLoading;
  final List<FollowupPlan> plans;
  final String? error;

  FollowupPlansState({
    this.isLoading = false,
    this.plans = const [],
    this.error,
  });

  FollowupPlansState copyWith({
    bool? isLoading,
    List<FollowupPlan>? plans,
    String? error,
  }) {
    return FollowupPlansState(
      isLoading: isLoading ?? this.isLoading,
      plans: plans ?? this.plans,
      error: error,
    );
  }
}

class FollowupPlansNotifier extends StateNotifier<FollowupPlansState> {
  final IProfileRepository _repository;

  FollowupPlansNotifier(this._repository) : super(FollowupPlansState());

  Future<void> loadPlans({bool? activeOnly}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final plans = await _repository.getMyFollowupPlans(activeOnly: activeOnly);
      state = state.copyWith(isLoading: false, plans: plans);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// Checkins
class CheckinsState {
  final bool isLoading;
  final List<Checkin> checkins;
  final String? error;

  CheckinsState({
    this.isLoading = false,
    this.checkins = const [],
    this.error,
  });

  CheckinsState copyWith({
    bool? isLoading,
    List<Checkin>? checkins,
    String? error,
  }) {
    return CheckinsState(
      isLoading: isLoading ?? this.isLoading,
      checkins: checkins ?? this.checkins,
      error: error,
    );
  }
}

class CheckinsNotifier extends StateNotifier<CheckinsState> {
  final IProfileRepository _repository;

  CheckinsNotifier(this._repository) : super(CheckinsState());

  Future<void> loadCheckins({int? followupPlanId}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final checkins = await _repository.getMyCheckins(followupPlanId: followupPlanId);
      state = state.copyWith(isLoading: false, checkins: checkins);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

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
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.createCheckin(
        adviceRecordId: adviceRecordId,
        followupPlanId: followupPlanId,
        checkinDate: checkinDate,
        completionStatus: completionStatus,
        adherenceScore: adherenceScore,
        effectScore: effectScore,
        userFeedback: userFeedback,
        blockerReason: blockerReason,
      );
      await loadCheckins(followupPlanId: followupPlanId);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

const _sentinel = Object();

// User Preferences
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
    Object? preferences = _sentinel,
    String? error,
  }) {
    return UserPreferencesState(
      isLoading: isLoading ?? this.isLoading,
      preferences: preferences == _sentinel ? this.preferences : preferences as UserPreferences?,
      error: error,
    );
  }
}

class UserPreferencesNotifier extends StateNotifier<UserPreferencesState> {
  final IProfileRepository _repository;

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
