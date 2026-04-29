import 'dart:async';
import 'dart:convert';
import 'package:eventsource/eventsource.dart';
import '../../core/constants/app_constants.dart';
import 'local_storage_service.dart';

class SseService {
  final LocalStorageService _localStorageService;

  SseService(this._localStorageService);

  Future<Stream<Event>> streamChat({
    required String message,
    int historyLimit = 10,
    String? systemPrompt,
    bool useAgent = true,
  }) async {
    final token = await _localStorageService.getToken();
    if (token == null) {
      throw Exception('未登录，请先登录');
    }

    final uri = Uri.parse('${AppConstants.baseUrl}/health/chat/stream');
    
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'text/event-stream',
    };

    final body = jsonEncode({
      'message': message,
      'historyLimit': historyLimit,
      'systemPrompt': systemPrompt,
      'useAgent': useAgent,
    });

    try {
      final eventSource = await EventSource.connect(
        uri.toString(),
        headers: headers,
        body: body,
        method: 'POST',
      );

      return eventSource;
    } catch (e) {
      throw Exception('连接 AI 服务失败: $e');
    }
  }
}
