import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// App Lock Service for PIN and Biometric Authentication
class AppLockService {
  AppLockService({
    required LocalAuthentication localAuth,
    required FlutterSecureStorage secureStorage,
  })  : _localAuth = localAuth,
        _secureStorage = secureStorage;

  final LocalAuthentication _localAuth;
  final FlutterSecureStorage _secureStorage;
  static const String _pinKey = 'app_lock_pin_hash';
  static const String _biometricEnabledKey = 'app_lock_biometric_enabled';
  static const String _lockEnabledKey = 'app_lock_enabled';

  /// Check if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Check if app lock is enabled
  Future<bool> isLockEnabled() async {
    final enabled = await _secureStorage.read(key: _lockEnabledKey);
    return enabled == 'true';
  }

  /// Enable/disable app lock
  Future<void> setLockEnabled(bool enabled) async {
    await _secureStorage.write(key: _lockEnabledKey, value: enabled.toString());
  }

  /// Check if biometric is enabled
  Future<bool> isBiometricEnabled() async {
    final enabled = await _secureStorage.read(key: _biometricEnabledKey);
    return enabled == 'true';
  }

  /// Enable/disable biometric authentication
  Future<void> setBiometricEnabled(bool enabled) async {
    await _secureStorage.write(
      key: _biometricEnabledKey,
      value: enabled.toString(),
    );
  }

  /// Set PIN
  Future<void> setPin(String pin) async {
    final hash = _hashPin(pin);
    await _secureStorage.write(key: _pinKey, value: hash);
    await setLockEnabled(true);
  }

  /// Verify PIN
  Future<bool> verifyPin(String pin) async {
    final storedHash = await _secureStorage.read(key: _pinKey);
    if (storedHash == null) return false;

    final inputHash = _hashPin(pin);
    return storedHash == inputHash;
  }

  /// Check if PIN is set
  Future<bool> hasPin() async {
    final pinHash = await _secureStorage.read(key: _pinKey);
    return pinHash != null && pinHash.isNotEmpty;
  }

  /// Authenticate with biometric
  Future<bool> authenticateWithBiometric({
    String reason = 'Authenticate to unlock the app',
  }) async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) return false;

      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  /// Authenticate (tries biometric first, then PIN)
  Future<bool> authenticate({
    String? pin,
    bool useBiometric = true,
  }) async {
    // Try biometric first if enabled and available
    if (useBiometric) {
      final biometricEnabled = await isBiometricEnabled();
      if (biometricEnabled) {
        final biometricAvailable = await isBiometricAvailable();
        if (biometricAvailable) {
          final biometricResult = await authenticateWithBiometric();
          if (biometricResult) return true;
        }
      }
    }

    // Fall back to PIN if provided
    if (pin != null) {
      return await verifyPin(pin);
    }

    return false;
  }

  /// Clear PIN (disable app lock)
  Future<void> clearPin() async {
    await _secureStorage.delete(key: _pinKey);
    await setLockEnabled(false);
  }

  /// Hash PIN for storage
  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
