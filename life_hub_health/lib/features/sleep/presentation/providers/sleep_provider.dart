import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../shared/models/sleep_log.dart';
import '../../../../shared/providers/providers.dart';
import '../../data/repositories/sleep_repository_impl.dart';
import '../../domain/repositories/sleep_repository.dart';

final sleepRepositoryProvider = Provider<ISleepRepository>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return SleepRepositoryImpl(apiService);
});

final sleepProvider = StateNotifierProvider<SleepNotifier, SleepState>((ref) {
  final repository = ref.read(sleepRepositoryProvider);
  return SleepNotifier(repository);
});

class SleepState {
  final bool isLoading;
  final List<SleepLog> sleepLogs;
  final SleepLog? latestLog;
  final String? error;
  final bool isCreating;

  SleepState({
    this.isLoading = false,
    this.sleepLogs = const [],
    this.latestLog,
    this.error,
    this.isCreating = false,
  });

  double get averageDuration {
    if (sleepLogs.isEmpty) return 0;
    final total = sleepLogs
        .where((l) => l.durationMinutes != null)
        .fold(0, (sum, l) => sum + l.durationMinutes!);
    final count = sleepLogs.where((l) => l.durationMinutes != null).length;
    if (count == 0) return 0;
    return total / count;
  }

  double get averageQuality {
    if (sleepLogs.isEmpty) return 0;
    final total = sleepLogs
        .where((l) => l.qualityScore != null)
        .fold(0, (sum, l) => sum + l.qualityScore!);
    final count = sleepLogs.where((l) => l.qualityScore != null).length;
    if (count == 0) return 0;
    return total / count;
  }

  SleepState copyWith({
    bool? isLoading,
    List<SleepLog>? sleepLogs,
    SleepLog? latestLog,
    String? error,
    bool? isCreating,
  }) {
    return SleepState(
      isLoading: isLoading ?? this.isLoading,
      sleepLogs: sleepLogs ?? this.sleepLogs,
      latestLog: latestLog ?? this.latestLog,
      error: error,
      isCreating: isCreating ?? this.isCreating,
    );
  }
}

class SleepNotifier extends StateNotifier<SleepState> {
  final ISleepRepository _repository;

  SleepNotifier(this._repository) : super(SleepState()) {
    loadData();
  }

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final now = DateTime.now();
      final logs = await _repository.getSleepLogsByRange(
        now.subtract(Duration(days: 30)),
        now,
      );
      final latest = await _repository.getLatestSleepLog();
      state = state.copyWith(isLoading: false, sleepLogs: logs, latestLog: latest);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: ErrorHandler.getFriendlyMessage(e));
    }
  }

  Future<bool> createLog({
    required DateTime sleepDate,
    DateTime? bedTime,
    DateTime? wakeTime,
    int? durationMinutes,
    int? qualityScore,
    String? notes,
  }) async {
    state = state.copyWith(isCreating: true);
    try {
      await _repository.createSleepLog(
        sleepDate: sleepDate,
        bedTime: bedTime,
        wakeTime: wakeTime,
        durationMinutes: durationMinutes,
        qualityScore: qualityScore,
        notes: notes,
      );
      await loadData();
      return true;
    } catch (e) {
      state = state.copyWith(isCreating: false, error: ErrorHandler.getFriendlyMessage(e));
      return false;
    }
  }
}
