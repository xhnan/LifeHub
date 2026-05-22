import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';

/// 离线缓存服务
/// - 网络请求结果缓存到 Hive
/// - 离线时从缓存读取
/// - 在线时乐观更新（先显示缓存，后台刷新）
class OfflineCacheService {
  static const _cacheBoxName = 'api_cache';
  static const _pendingBoxName = 'pending_operations';

  late Box _cacheBox;
  late Box _pendingBox;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _cacheBox = await Hive.openBox(_cacheBoxName);
    _pendingBox = await Hive.openBox(_pendingBoxName);
    _initialized = true;
  }

  /// 检查网络连接
  Future<bool> isOnline() async {
    final results = await Connectivity().checkConnectivity();
    if (results is List) {
      return !(results as List).contains(ConnectivityResult.none);
    }
    return results != ConnectivityResult.none;
  }

  /// 缓存 GET 请求结果
  Future<void> cacheResponse(String key, dynamic data, {Duration? ttl}) async {
    await initialize();
    final entry = {
      'data': jsonEncode(data),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'ttl': ttl?.inMilliseconds ?? (5 * 60 * 1000), // 默认5分钟
    };
    await _cacheBox.put(key, entry);
  }

  /// 获取缓存数据（如果未过期）
  dynamic getCachedResponse(String key) {
    if (!_initialized) return null;
    final entry = _cacheBox.get(key);
    if (entry == null) return null;

    final timestamp = entry['timestamp'] as int;
    final ttl = entry['ttl'] as int;
    final now = DateTime.now().millisecondsSinceEpoch;

    if (now - timestamp > ttl) {
      // 过期但仍然返回（stale-while-revalidate 策略）
      // 调用方可以根据需要决定是否使用
    }

    try {
      return jsonDecode(entry['data'] as String);
    } catch (_) {
      return null;
    }
  }

  /// 检查缓存是否新鲜（未过期）
  bool isCacheFresh(String key) {
    if (!_initialized) return false;
    final entry = _cacheBox.get(key);
    if (entry == null) return false;

    final timestamp = entry['timestamp'] as int;
    final ttl = entry['ttl'] as int;
    final now = DateTime.now().millisecondsSinceEpoch;
    return now - timestamp <= ttl;
  }

  /// 添加待同步的离线操作
  Future<void> addPendingOperation({
    required String method,
    required String path,
    Map<String, dynamic>? data,
  }) async {
    await initialize();
    final operation = {
      'method': method,
      'path': path,
      'data': data != null ? jsonEncode(data) : null,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await _pendingBox.add(operation);
  }

  /// 获取所有待同步操作
  List<Map<String, dynamic>> getPendingOperations() {
    if (!_initialized) return [];
    return _pendingBox.values
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  /// 清除已同步的操作
  Future<void> clearPendingOperation(int index) async {
    await initialize();
    await _pendingBox.deleteAt(index);
  }

  /// 清除所有待同步操作
  Future<void> clearAllPending() async {
    await initialize();
    await _pendingBox.clear();
  }

  /// 清除所有缓存
  Future<void> clearCache() async {
    await initialize();
    await _cacheBox.clear();
  }

  /// 生成缓存 key
  static String cacheKey(String path, {Map<String, dynamic>? params}) {
    if (params == null || params.isEmpty) return path;
    final sortedParams = params.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    final paramStr = sortedParams.map((e) => '${e.key}=${e.value}').join('&');
    return '$path?$paramStr';
  }
}
