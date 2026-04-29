import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/agent_models.dart';
import '../../../../shared/providers/providers.dart';
import '../../data/repositories/agent_repository.dart';

final agentRepositoryProvider = Provider<AgentRepository>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return AgentRepository(apiService);
});

final agentProvider = StateNotifierProvider<AgentNotifier, AgentState>((ref) {
  final repository = ref.read(agentRepositoryProvider);
  return AgentNotifier(repository);
});

class AgentState {
  final bool isLoading;
  final List<AdviceRecord> adviceRecords;
  final List<FollowupPlan> followupPlans;
  final List<Checkin> checkins;
  final String? error;

  AgentState({
    this.isLoading = false,
    this.adviceRecords = const [],
    this.followupPlans = const [],
    this.checkins = const [],
    this.error,
  });

  AgentState copyWith({
    bool? isLoading,
    List<AdviceRecord>? adviceRecords,
    List<FollowupPlan>? followupPlans,
    List<Checkin>? checkins,
    String? error,
  }) {
    return AgentState(
      isLoading: isLoading ?? this.isLoading,
      adviceRecords: adviceRecords ?? this.adviceRecords,
      followupPlans: followupPlans ?? this.followupPlans,
      checkins: checkins ?? this.checkins,
      error: error,
    );
  }
}

class AgentNotifier extends StateNotifier<AgentState> {
  final AgentRepository _repository;

  AgentNotifier(this._repository) : super(AgentState());

  Future<void> loadAdviceRecords({String? agentType, bool? activeOnly}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final records = await _repository.getMyAdviceRecords(
        agentType: agentType,
        activeOnly: activeOnly,
      );
      state = state.copyWith(isLoading: false, adviceRecords: records);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadFollowupPlans({bool? activeOnly}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final plans = await _repository.getMyFollowupPlans(activeOnly: activeOnly);
      state = state.copyWith(isLoading: false, followupPlans: plans);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

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
