import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';

class LocalStorageService {
  final FlutterSecureStorage _secureStorage;
  late Box _cacheBox;
  late Box _settingsBox;

  LocalStorageService() : _secureStorage = FlutterSecureStorage();

  Future<void> init() async {
    await Hive.initFlutter();
    _cacheBox = await Hive.openBox(AppConstants.cacheBox);
    _settingsBox = await Hive.openBox(AppConstants.settingsBox);
  }

  // Token management
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: AppConstants.tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: AppConstants.tokenKey);
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    await _secureStorage.write(key: AppConstants.refreshTokenKey, value: refreshToken);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: AppConstants.refreshTokenKey);
  }

  Future<void> clearTokens() async {
    await _secureStorage.delete(key: AppConstants.tokenKey);
    await _secureStorage.delete(key: AppConstants.refreshTokenKey);
  }

  // Cache management
  Future<void> saveToCache(String key, dynamic value) async {
    await _cacheBox.put(key, value);
  }

  dynamic getFromCache(String key) {
    return _cacheBox.get(key);
  }

  Future<void> removeFromCache(String key) async {
    await _cacheBox.delete(key);
  }

  Future<void> clearCache() async {
    await _cacheBox.clear();
  }

  // Settings management
  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  dynamic getSetting(String key, {dynamic defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue);
  }

  Future<void> clearSettings() async {
    await _settingsBox.clear();
  }

  // Clear all data
  Future<void> clearAll() async {
    await clearTokens();
    await clearCache();
    await clearSettings();
  }
}
