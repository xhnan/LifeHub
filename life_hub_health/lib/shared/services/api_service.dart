import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';
import 'local_storage_service.dart';

class ApiService {
  final Dio _dio;
  final LocalStorageService _localStorageService;
  bool _isRefreshing = false;

  ApiService(this._localStorageService) : _dio = Dio() {
    _dio.options.baseUrl = AppConstants.baseUrl;
    _dio.options.connectTimeout = Duration(milliseconds: AppConstants.connectTimeout);
    _dio.options.receiveTimeout = Duration(milliseconds: AppConstants.receiveTimeout);
    _dio.options.sendTimeout = Duration(milliseconds: AppConstants.sendTimeout);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    _dio.interceptors.add(_authInterceptor());
    _dio.interceptors.add(_logInterceptor());
  }

  Interceptor _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _localStorageService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401 && !_isRefreshing) {
          _isRefreshing = true;
          try {
            final refreshed = await _refreshToken();
            if (refreshed) {
              final token = await _localStorageService.getToken();
              error.requestOptions.headers['Authorization'] = 'Bearer $token';
              final response = await _dio.fetch(error.requestOptions);
              handler.resolve(response);
              return;
            }
          } finally {
            _isRefreshing = false;
          }
        }
        handler.next(error);
      },
    );
  }

  Interceptor _logInterceptor() {
    if (!kDebugMode) return InterceptorsWrapper();
    return LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      error: true,
      logPrint: (obj) {
        final message = obj.toString();
        if (_containsSensitiveData(message)) {
          print('[REDACTED - sensitive data detected]');
        } else {
          print(obj);
        }
      },
    );
  }

  bool _containsSensitiveData(String message) {
    final lower = message.toLowerCase();
    final sensitiveKeys = [
      'authorization',
      'password',
      'token',
      'refreshtoken',
      'accesstoken',
      'journaltext',
      'journal_text',
      'emotiontags',
      'emotion_tags',
      'moodscore',
      'mood_score',
      'content',
      'systemprompt',
      'system_prompt',
      'useridforagent',
    ];
    return sensitiveKeys.any((key) => lower.contains(key));
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _localStorageService.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        await _localStorageService.saveToken(data['token']);
        if (data['refreshToken'] != null) {
          await _localStorageService.saveRefreshToken(data['refreshToken']);
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return _dio.put(path, data: data);
  }

  Future<Response> delete(String path) async {
    return _dio.delete(path);
  }
}
