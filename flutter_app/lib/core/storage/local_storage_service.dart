import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/storage_constants.dart';

/// Local Storage Service for non-sensitive data
class LocalStorageService {
  LocalStorageService(this._prefs);

  final SharedPreferences _prefs;

  // User Data
  Future<void> saveUserId(String userId) async {
    await _prefs.setString(StorageConstants.userId, userId);
  }

  String? getUserId() {
    return _prefs.getString(StorageConstants.userId);
  }

  Future<void> saveUserPhone(String phone) async {
    await _prefs.setString(StorageConstants.userPhone, phone);
  }

  String? getUserPhone() {
    return _prefs.getString(StorageConstants.userPhone);
  }

  Future<void> saveUserName(String name) async {
    await _prefs.setString(StorageConstants.userName, name);
  }

  String? getUserName() {
    return _prefs.getString(StorageConstants.userName);
  }

  Future<void> saveUserEmail(String email) async {
    await _prefs.setString(StorageConstants.userEmail, email);
  }

  String? getUserEmail() {
    return _prefs.getString(StorageConstants.userEmail);
  }

  // Business Data
  Future<void> saveSelectedBusinessId(String businessId) async {
    await _prefs.setString(StorageConstants.selectedBusinessId, businessId);
  }

  String? getSelectedBusinessId() {
    return _prefs.getString(StorageConstants.selectedBusinessId);
  }

  Future<void> saveBusinessName(String name) async {
    await _prefs.setString(StorageConstants.businessName, name);
  }

  String? getBusinessName() {
    return _prefs.getString(StorageConstants.businessName);
  }

  // Devices cache
  Future<void> saveCachedDevices(List<Map<String, dynamic>> devices) async {
    final encoded = jsonEncode(devices);
    await _prefs.setString(StorageConstants.cachedDevices, encoded);
  }

  List<Map<String, dynamic>>? getCachedDevices() {
    final raw = _prefs.getString(StorageConstants.cachedDevices);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  // Sync Data
  Future<void> saveLastSyncAt(String dateTime) async {
    await _prefs.setString(StorageConstants.lastSyncAt, dateTime);
  }

  String? getLastSyncAt() {
    return _prefs.getString(StorageConstants.lastSyncAt);
  }

  // Settings
  Future<void> saveLanguagePreference(String language) async {
    await _prefs.setString(StorageConstants.languagePreference, language);
  }

  String? getLanguagePreference() {
    return _prefs.getString(StorageConstants.languagePreference);
  }

  Future<void> saveThemeMode(String themeMode) async {
    await _prefs.setString(StorageConstants.themeMode, themeMode);
  }

  String? getThemeMode() {
    return _prefs.getString(StorageConstants.themeMode);
  }

  Future<void> saveCurrencyPreference(String currencyCode) async {
    await _prefs.setString(StorageConstants.currencyPreference, currencyCode);
  }

  String? getCurrencyPreference() {
    return _prefs.getString(StorageConstants.currencyPreference);
  }

  Future<void> setFirstLaunch(bool isFirst) async {
    await _prefs.setBool(StorageConstants.isFirstLaunch, isFirst);
  }

  bool isFirstLaunch() {
    return _prefs.getBool(StorageConstants.isFirstLaunch) ?? true;
  }

  // Generic methods
  Future<void> saveString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<void> saveInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  Future<void> saveBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  Future<void> clearSessionData() async {
    final keysToRemove = <String>{
      StorageConstants.userId,
      StorageConstants.userPhone,
      StorageConstants.userName,
      StorageConstants.userEmail,
      StorageConstants.selectedBusinessId,
      StorageConstants.businessName,
      StorageConstants.lastSyncAt,
      StorageConstants.cachedDevices,
    };

    for (final key in keysToRemove) {
      await _prefs.remove(key);
    }

    final scopedLastSyncPrefix = '${StorageConstants.lastSyncAtScopedPrefix}_';
    for (final key in _prefs.getKeys()) {
      if (key.startsWith(scopedLastSyncPrefix)) {
        await _prefs.remove(key);
      }
    }
  }

  Future<void> clear() async {
    await _prefs.clear();
  }
}
