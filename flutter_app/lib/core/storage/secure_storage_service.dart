import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/storage_constants.dart';

/// Secure Storage Service for sensitive data
class SecureStorageService {
  SecureStorageService() : _storage = const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  // Access Token
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: StorageConstants.accessToken, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: StorageConstants.accessToken);
  }

  Future<void> deleteAccessToken() async {
    await _storage.delete(key: StorageConstants.accessToken);
  }

  // Refresh Token
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: StorageConstants.refreshToken, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: StorageConstants.refreshToken);
  }

  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: StorageConstants.refreshToken);
  }

  // Device ID
  Future<void> saveDeviceId(String deviceId) async {
    await _storage.write(key: StorageConstants.deviceId, value: deviceId);
  }

  Future<String?> getDeviceId() async {
    return await _storage.read(key: StorageConstants.deviceId);
  }

  // Device Name
  Future<void> saveDeviceName(String deviceName) async {
    await _storage.write(key: StorageConstants.deviceName, value: deviceName);
  }

  Future<String?> getDeviceName() async {
    return await _storage.read(key: StorageConstants.deviceName);
  }

  // Business ID
  Future<void> saveBusinessId(String businessId) async {
    await _storage.write(key: StorageConstants.businessId, value: businessId);
  }

  Future<String?> getBusinessId() async {
    return await _storage.read(key: StorageConstants.businessId);
  }

  Future<void> deleteBusinessId() async {
    await _storage.delete(key: StorageConstants.businessId);
  }

  // Default Business ID
  Future<void> saveDefaultBusinessId(String businessId) async {
    await _storage.write(
        key: StorageConstants.defaultBusinessId, value: businessId);
  }

  Future<String?> getDefaultBusinessId() async {
    return await _storage.read(key: StorageConstants.defaultBusinessId);
  }

  // Sync Cursor
  Future<void> saveSyncCursor(String cursor) async {
    await _storage.write(key: StorageConstants.syncCursor, value: cursor);
  }

  Future<String?> getSyncCursor() async {
    return await _storage.read(key: StorageConstants.syncCursor);
  }

  Future<void> saveScopedSyncCursor({
    required String userId,
    required String businessId,
    required String cursor,
  }) async {
    final key = _scopedSyncCursorKey(userId: userId, businessId: businessId);
    await _storage.write(key: key, value: cursor);
  }

  Future<String?> getScopedSyncCursor({
    required String userId,
    required String businessId,
  }) async {
    final key = _scopedSyncCursorKey(userId: userId, businessId: businessId);
    return await _storage.read(key: key);
  }

  Future<void> deleteScopedSyncCursor({
    required String userId,
    required String businessId,
  }) async {
    final key = _scopedSyncCursorKey(userId: userId, businessId: businessId);
    await _storage.delete(key: key);
  }

  // Clear all data (logout)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  String _scopedSyncCursorKey({
    required String userId,
    required String businessId,
  }) {
    return '${StorageConstants.syncCursorScopedPrefix}_${userId}_$businessId';
  }
}
