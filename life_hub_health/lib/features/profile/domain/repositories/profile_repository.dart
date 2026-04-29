import '../../../../shared/models/agent_models.dart';
import '../../../../shared/models/user_preferences.dart';

abstract class IProfileRepository {
  // Agent advice
  Future<List<AdviceRecord>> getMyAdviceRecords({
    String? agentType,
    bool? activeOnly,
  });

  // Followup plans
  Future<List<FollowupPlan>> getMyFollowupPlans({bool? activeOnly});

  // Checkins
  Future<List<Checkin>> getMyCheckins({int? followupPlanId});
  Future<bool> createCheckin({
    int? adviceRecordId,
    int? followupPlanId,
    required DateTime checkinDate,
    required String completionStatus,
    int? adherenceScore,
    int? effectScore,
    String? userFeedback,
    String? blockerReason,
  });

  // User preferences
  Future<UserPreferences?> getMyPreferences();
  Future<bool> savePreferences({
    String? preferredDietStyle,
    String? dislikedFoods,
    String? preferredExerciseTypes,
    String? preferredSupportStyle,
    String? routinePattern,
    String? motivationTags,
    Map<String, dynamic>? habitProfile,
  });
}
