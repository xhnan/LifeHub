import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../services/sse_service.dart';

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

final apiServiceProvider = Provider<ApiService>((ref) {
  final localStorageService = ref.read(localStorageServiceProvider);
  return ApiService(localStorageService);
});

final sseServiceProvider = Provider<SseService>((ref) {
  final localStorageService = ref.read(localStorageServiceProvider);
  return SseService(localStorageService);
});
