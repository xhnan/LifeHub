import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../shared/models/daily_mood.dart';
import '../../../../shared/providers/providers.dart';
import '../../../psychology/domain/repositories/psychology_repository.dart';
import '../../../psychology/data/repositories/psychology_repository.dart';

final psychologyRepositoryForMoodProvider = Provider<IPsychologyRepository>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return PsychologyRepository(apiService);
});

final moodProvider = StateNotifierProvider<MoodNotifier, MoodState>((ref) {
  final repository = ref.read(psychologyRepositoryForMoodProvider);
  return MoodNotifier(repository);
});

const _sentinel = Object();

class MoodState {
  final bool isLoading;
  final List<DailyMood> moods;
  final DailyMood? latestMood;
  final String? error;

  MoodState({
    this.isLoading = false,
    this.moods = const [],
    this.latestMood,
    this.error,
  });

  MoodState copyWith({
    bool? isLoading,
    List<DailyMood>? moods,
    Object? latestMood = _sentinel,
    String? error,
  }) {
    return MoodState(
      isLoading: isLoading ?? this.isLoading,
      moods: moods ?? this.moods,
      latestMood: latestMood == _sentinel ? this.latestMood : latestMood as DailyMood?,
      error: error,
    );
  }
}

class MoodNotifier extends StateNotifier<MoodState> {
  final IPsychologyRepository _repository;

  MoodNotifier(this._repository) : super(MoodState()) {
    loadMoods();
  }

  Future<void> loadMoods() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final moods = await _repository.getMyMoods();
      final latest = await _repository.getLatestMood();
      state = state.copyWith(isLoading: false, moods: moods, latestMood: latest);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: ErrorHandler.getFriendlyMessage(e));
    }
  }

  Future<bool> recordMood({
    required int moodScore,
    String? primaryEmotion,
    String? journalText,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.recordMood(
        moodScore: moodScore,
        primaryEmotion: primaryEmotion,
        journalText: journalText,
      );
      await loadMoods();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: ErrorHandler.getFriendlyMessage(e));
      return false;
    }
  }
}
