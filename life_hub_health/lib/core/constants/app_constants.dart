class AppConstants {
  static const String appName = 'LifeHub Health';
  static const String baseUrl = 'https://api.lifehub.com';
  static const String apiVersion = '/api/v1';
  
  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  
  // Hive boxes
  static const String cacheBox = 'cache_box';
  static const String settingsBox = 'settings_box';
  
  // API timeouts
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;
  static const int sendTimeout = 15000;
}
