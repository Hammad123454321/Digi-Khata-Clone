/// Storage Keys Constants
class StorageConstants {
  StorageConstants._();

  // Auth
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String deviceId = 'device_id';
  static const String deviceName = 'device_name';

  // User
  static const String userId = 'user_id';
  static const String userPhone = 'user_phone';
  static const String userName = 'user_name';
  static const String userEmail = 'user_email';

  // Business
  static const String businessId = 'business_id';
  static const String businessName = 'business_name';
  static const String selectedBusinessId = 'selected_business_id';
  static const String defaultBusinessId = 'default_business_id';

  // Sync
  static const String syncCursor = 'sync_cursor';
  static const String lastSyncAt = 'last_sync_at';
  static const String syncCursorScopedPrefix = 'sync_cursor_scoped';
  static const String lastSyncAtScopedPrefix = 'last_sync_at_scoped';

  // Settings
  static const String isFirstLaunch = 'is_first_launch';
  static const String languagePreference = 'language_preference';
  static const String themeMode = 'theme_mode';
  static const String currencyPreference = 'currency_preference';
  static const String hideBalances = 'hide_balances';

  // Cached data
  static const String cachedDevices = 'cached_devices';
}
