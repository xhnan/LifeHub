import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';

class LocalStorageService {
  final FlutterSecureStorage _secureStorage;
  Box? _cacheBox;
  Box? _settingsBox;
  bool _initialized = false;

  LocalStorageService() : _secureStorage = FlutterSecureStorage();

  bool get isInitialized => _initialized;

  Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();

    final encryptionKey = await _getOrCreateEncryptionKey();
    final cipher = HiveAesCipher(encryptionKey);

    _cacheBox = await Hive.openBox(
      AppConstants.cacheBox,
      encryptionCipher: cipher,
    );
    _settingsBox = await Hive.openBox(
      AppConstants.settingsBox,
      encryptionCipher: cipher,
    );
    _initialized = true;
  }

  Future<List<int>> _getOrCreateEncryptionKey() async {
    const keyName = 'hive_encryption_key';
    final existingKey = await _secureStorage.read(key: keyName);
    if (existingKey != null) {
      return base64Decode(existingKey);
    }
    final random = Random.secure();
    final key = List<int>.generate(32, (_) => random.nextInt(256));
    await _secureStorage.write(key: keyName, value: base64Encode(key));
    return key;
  }

  Box get cacheBox {
    if (_cacheBox == null) {
      throw StateError('LocalStorageService not initialized. Call init() first.');
    }
    return _cacheBox!;
  }

  Box get settingsBox {
    if (_settingsBox == null) {
      throw StateError('LocalStorageService not initialized. Call init() first.');
    }
    return _settingsBox!;
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
    await cacheBox.put(key, value);
  }

  dynamic getFromCache(String key) {
    return cacheBox.get(key);
  }

  Future<void> removeFromCache(String key) async {
    await cacheBox.delete(key);
  }

  Future<void> clearCache() async {
    await cacheBox.clear();
  }

  // Settings management
  Future<void> saveSetting(String key, dynamic value) async {
    await settingsBox.put(key, value);
  }

  dynamic getSetting(String key, {dynamic defaultValue}) {
    return settingsBox.get(key, defaultValue: defaultValue);
  }

  Future<void> clearSettings() async {
    await settingsBox.clear();
  }

  // Clear all data
  Future<void> clearAll() async {
    await clearTokens();
    await clearCache();
    await clearSettings();
  }
}
