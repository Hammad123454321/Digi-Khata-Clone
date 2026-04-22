import 'dart:convert';

import 'package:dio/dio.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/local_storage_service.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/database/app_database.dart';
import '../../core/utils/result.dart';
import '../../core/constants/api_constants.dart';
import '../../shared/models/auth_response_model.dart';
import '../../shared/models/business_model.dart';
import '../../shared/models/user_model.dart';

/// Authentication Repository
class AuthRepository {
  AuthRepository({
    required ApiClient apiClient,
    required SecureStorageService secureStorage,
    required LocalStorageService localStorage,
    required AppDatabase appDatabase,
  })  : _apiClient = apiClient,
        _secureStorage = secureStorage,
        _localStorage = localStorage,
        _appDatabase = appDatabase;

  final ApiClient _apiClient;
  final SecureStorageService _secureStorage;
  final LocalStorageService _localStorage;
  final AppDatabase _appDatabase;

  /// Request OTP
  Future<Result<void>> requestOtp(String phone) async {
    try {
      await _apiClient
          .post(
            ApiConstants.requestOtp,
            data: {'phone': phone},
            options: _publicAuthOptions,
          )
          .timeout(ApiConstants.connectTimeout + const Duration(seconds: 5));
      return const Result.success(null);
    } on AppException catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  /// Verify OTP
  Future<Result<AuthResponseModel>> verifyOtp({
    required String phone,
    required String otp,
    required String deviceId,
    String? deviceName,
  }) async {
    try {
      final response = await _apiClient
          .post(
            ApiConstants.verifyOtp,
            data: {
              'phone': phone,
              'otp': otp,
              'device_id': deviceId,
              if (deviceName != null) 'device_name': deviceName,
            },
            options: _publicAuthOptions,
          )
          .timeout(ApiConstants.connectTimeout + const Duration(seconds: 5));

      // Check if response data is valid
      if (response.data == null) {
        return const Result.failure(
          ServerFailure('Invalid response from server'),
        );
      }

      final authPayload = _extractAuthPayload(response.data);
      final authResponse = AuthResponseModel.fromJson(authPayload);

      // Save tokens and user data
      await _saveAuthData(authResponse);

      return Result.success(authResponse);
    } on FormatException catch (_) {
      return const Result.failure(
        ServerFailure('Invalid authentication response from server'),
      );
    } on AppException catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    } catch (e) {
      // Catch any other unexpected errors
      return Result.failure(
        UnknownFailure('Failed to verify OTP: ${e.toString()}'),
      );
    }
  }

  /// Refresh Access Token
  Future<Result<String>> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) {
        return const Result.failure(
          AuthenticationFailure('No refresh token available'),
        );
      }

      final deviceId = await _secureStorage.getDeviceId();
      final response = await _apiClient.post(
        ApiConstants.refreshToken,
        data: {
          'refresh_token': refreshToken,
          if (deviceId != null && deviceId.isNotEmpty) 'device_id': deviceId,
        },
        options: Options(
          extra: {
            'skip_auth_header': true,
            'skip_business_header': true,
            'skip_auth_refresh': true,
          },
        ),
      );

      final newAccessToken = response.data['access_token'] as String;
      await _secureStorage.saveAccessToken(newAccessToken);

      return Result.success(newAccessToken);
    } on AppException catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  /// Set PIN
  Future<Result<void>> setPin(String pin) async {
    try {
      await _apiClient.post(
        ApiConstants.setPin,
        data: {'pin': pin},
      );
      return const Result.success(null);
    } on AppException catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  /// Verify PIN
  Future<Result<bool>> verifyPin(String pin) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.verifyPin,
        data: {'pin': pin},
      );
      final isValid = response.data['valid'] as bool? ?? false;
      return Result.success(isValid);
    } on AppException catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _secureStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Check if local session exists for offline continuation.
  Future<bool> hasCachedSession() async {
    final userId = _localStorage.getUserId();
    final phone = _localStorage.getUserPhone();
    final selectedBusinessId = _localStorage.getSelectedBusinessId();
    final secureBusinessId = await _secureStorage.getBusinessId();
    return userId != null &&
        phone != null &&
        userId.isNotEmpty &&
        phone.isNotEmpty &&
        ((selectedBusinessId != null && selectedBusinessId.isNotEmpty) ||
            (secureBusinessId != null && secureBusinessId.isNotEmpty));
  }

  /// Get current user
  Future<UserModel?> getCurrentUser() async {
    final userId = _localStorage.getUserId();
    final phone = _localStorage.getUserPhone();
    final name = _localStorage.getUserName();
    final email = _localStorage.getUserEmail();

    if (userId == null || phone == null) {
      return null;
    }

    return UserModel(
      id: userId,
      phone: phone,
      name: name,
      email: email,
    );
  }

  /// Logout
  Future<void> logout() async {
    final refreshToken = await _secureStorage.getRefreshToken();
    final deviceId = await _secureStorage.getDeviceId();

    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await _apiClient.post(
          ApiConstants.logout,
          data: {
            'refresh_token': refreshToken,
            if (deviceId != null && deviceId.isNotEmpty) 'device_id': deviceId,
          },
          options: Options(
            extra: {
              'skip_business_header': true,
              'skip_auth_refresh': true,
              'skip_auth_recovery': true,
            },
          ),
        );
      } catch (_) {
        // Best-effort remote logout; local session should still be cleared.
      }
    }

    await _appDatabase.clearAllData();
    await _secureStorage.clearSessionData();
    await _localStorage.clearSessionData();
    _apiClient.resetAuthRecoveryState();
  }

  /// Create a default business for new user
  Future<Result<BusinessModel>> createDefaultBusiness(String phone) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.businesses,
        data: {
          'name': 'My Business',
          'phone': phone,
        },
      );

      final business = BusinessModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      return Result.success(business);
    } on AppException catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    } catch (e) {
      return Result.failure(
        UnknownFailure('Failed to create business: ${e.toString()}'),
      );
    }
  }

  /// Save authentication data
  Future<void> _saveAuthData(AuthResponseModel authResponse) async {
    // Save tokens
    await _secureStorage.saveAccessToken(authResponse.accessToken);
    if (authResponse.refreshToken.isNotEmpty) {
      await _secureStorage.saveRefreshToken(authResponse.refreshToken);
    }

    // Save user data
    await _localStorage.saveUserId(authResponse.user.id);
    await _localStorage.saveUserPhone(authResponse.user.phone);
    if (authResponse.user.name != null) {
      await _localStorage.saveUserName(authResponse.user.name!);
    }
    if (authResponse.user.email != null) {
      await _localStorage.saveUserEmail(authResponse.user.email!);
    }

    // Save device data
    if (authResponse.device != null) {
      await _secureStorage.saveDeviceId(authResponse.device!.deviceId);
      if (authResponse.device!.deviceName != null) {
        await _secureStorage.saveDeviceName(authResponse.device!.deviceName!);
      }
    }

    // Handle business data
    if (authResponse.defaultBusinessId != null) {
      await _secureStorage
          .saveDefaultBusinessId(authResponse.defaultBusinessId!);
      await _secureStorage.saveBusinessId(authResponse.defaultBusinessId!);
      await _localStorage
          .saveSelectedBusinessId(authResponse.defaultBusinessId!);
    }

    if (authResponse.businesses != null &&
        authResponse.businesses!.isNotEmpty) {
      // User has businesses - use default or first one
      final businessId =
          authResponse.defaultBusinessId ?? authResponse.businesses!.first.id;
      final business = authResponse.businesses!.firstWhere(
        (b) => b.id == businessId,
        orElse: () => authResponse.businesses!.first,
      );

      await _secureStorage.saveBusinessId(business.id);
      await _localStorage.saveSelectedBusinessId(business.id);
      await _localStorage.saveBusinessName(business.name);
      if (business.permissions != null) {
        await _localStorage.saveBusinessPermissions(
          business.id,
          business.permissions!,
        );
      }
    }
    // If no businesses, user will be prompted to create one
    _apiClient.resetAuthRecoveryState();
  }

  Failure _mapExceptionToFailure(AppException exception) {
    return switch (exception) {
      NetworkException() => NetworkFailure(exception.message),
      ServerException() => ServerFailure(exception.message),
      TimeoutException() => TimeoutFailure(exception.message),
      AuthenticationException() => AuthenticationFailure(exception.message),
      AuthorizationException() => AuthorizationFailure(exception.message),
      ValidationException() => ValidationFailure(
          exception.message,
          exception.errors,
        ),
      _ => UnknownFailure(exception.message),
    };
  }

  Map<String, dynamic> _extractAuthPayload(dynamic rawData) {
    var payload = _extractMap(rawData, fieldName: 'response');
    const wrapperKeys = ['data', 'payload', 'result'];
    for (final key in wrapperKeys) {
      if (_hasAuthFields(payload)) break;
      final nested = payload[key];
      if (nested == null) continue;
      payload = _extractMap(nested, fieldName: key);
    }
    return payload;
  }

  bool _hasAuthFields(Map<String, dynamic> payload) {
    return payload.containsKey('access_token') ||
        payload.containsKey('accessToken');
  }

  Map<String, dynamic> _extractMap(
    dynamic raw, {
    required String fieldName,
  }) {
    final decoded = _decodeMaybeJson(raw);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    throw FormatException('Invalid "$fieldName" payload format');
  }

  dynamic _decodeMaybeJson(dynamic raw) {
    if (raw is! String) return raw;
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return raw;
    }

    final looksLikeJsonObject =
        trimmed.startsWith('{') && trimmed.endsWith('}');
    final looksLikeJsonArray = trimmed.startsWith('[') && trimmed.endsWith(']');
    final looksLikeQuotedJson =
        trimmed.startsWith('"') && trimmed.endsWith('"');

    if (!looksLikeJsonObject && !looksLikeJsonArray && !looksLikeQuotedJson) {
      return raw;
    }

    try {
      var decoded = jsonDecode(trimmed);
      if (decoded is String) {
        final secondPass = decoded.trim();
        if ((secondPass.startsWith('{') && secondPass.endsWith('}')) ||
            (secondPass.startsWith('[') && secondPass.endsWith(']'))) {
          decoded = jsonDecode(secondPass);
        }
      }
      return decoded;
    } catch (_) {
      return raw;
    }
  }

  Options get _publicAuthOptions => Options(
        extra: {
          'skip_auth_header': true,
          'skip_business_header': true,
          'skip_auth_recovery': true,
        },
      );
}
