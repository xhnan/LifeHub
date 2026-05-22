import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../services/sse_service.dart';
import '../services/notification_service.dart';
import '../services/offline_cache_service.dart';

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

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final offlineCacheServiceProvider = Provider<OfflineCacheService>((ref) {
  return OfflineCacheService();
});
