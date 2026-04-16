import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../config/app_config.dart';
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';
import '../storage/secure_storage_service.dart';

/// Production-ready API Client using Dio
class ApiClient {
  ApiClient({
    required SecureStorageService secureStorage,
    Logger? logger,
  })  : _dio = Dio(),
        _secureStorage = secureStorage,
        _logger = logger ?? Logger() {
    _setupInterceptors();
    _setupDio();
  }

  final Dio _dio;
  final SecureStorageService _secureStorage;
  final Logger _logger;
  Future<bool>? _refreshInFlight;
  String? _lastRefreshToken;
  bool _refreshTokenInvalid = false;
  bool _sessionExpiredNotified = false;
  final StreamController<void> _sessionExpiredController =
      StreamController<void>.broadcast();

  Stream<void> get sessionExpiredStream => _sessionExpiredController.stream;

  void resetAuthRecoveryState() {
    _refreshTokenInvalid = false;
    _lastRefreshToken = null;
    _sessionExpiredNotified = false;
  }

  void _setupDio() {
    _dio.options = BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      sendTimeout: ApiConstants.sendTimeout,
      headers: {
        ApiConstants.headerContentType: ApiConstants.applicationJson,
        ApiConstants.headerAccept: ApiConstants.applicationJson,
      },
    );
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token
          final path = options.path.toLowerCase();
          final isRefreshCall = path.contains(ApiConstants.refreshToken);
          final skipAuthHeader =
              options.extra['skip_auth_header'] == true ||
                  isRefreshCall;
          if (!skipAuthHeader) {
            final token = await _secureStorage.getAccessToken();
            if (token != null) {
              options.headers[ApiConstants.headerAuthorization] =
                  'Bearer $token';
            }
          }

          // Add business ID if available (skip for business creation/list endpoints)
          final isBusinessList = path.contains('/businesses') &&
              options.method == 'GET' &&
              !path.contains('/businesses/');
          final isBusinessCreate = path.contains('/businesses') &&
              options.method == 'POST' &&
              !path.contains('/businesses/') &&
              !path.contains('/set-default');
          final skipBusinessHeader =
              options.extra['skip_business_header'] == true;

          if (!isRefreshCall &&
              !skipBusinessHeader &&
              !isBusinessList &&
              !isBusinessCreate) {
            final businessId = await _secureStorage.getBusinessId();
            if (businessId != null) {
              options.headers[ApiConstants.headerBusinessId] = businessId;
            }
          }

          // Add device ID for sync endpoints
          if (!isRefreshCall &&
              (options.path.contains('/sync/') ||
                  options.path.contains('/devices/'))) {
            final deviceId = await _secureStorage.getDeviceId();
            if (deviceId != null) {
              options.headers[ApiConstants.headerDeviceId] = deviceId;
            }
          }

          if (kDebugMode) {
            _logger.d(
              'REQUEST[${options.method}] => PATH: ${options.path}',
            );
            _logger.d('Base URL: ${options.baseUrl}');
            _logger.d('Headers: ${options.headers}');
            if (options.data != null) {
              _logger.d('Data: ${options.data}');
            }
          }

          handler.next(options);
        },
        onResponse: (response, handler) {
          response.data = _normalizeResponseData(response.data);
          if (kDebugMode) {
            _logger.d(
              'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
            );
            _logger.d('Data: ${response.data}');
          }
          handler.next(response);
        },
        onError: (error, handler) async {
          if (kDebugMode) {
            _logger.e(
              'ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}',
            );
            _logger.e('Error: ${error.message}');
            if (error.response != null) {
              _logger.e('Response: ${error.response?.data}');
            }
          }

          // Handle 401 - Unauthorized
          if (error.response?.statusCode == 401) {
            final path = error.requestOptions.path;
            final isRefreshCall = path.contains(ApiConstants.refreshToken);
            final skipAuthRefresh =
                error.requestOptions.extra['skip_auth_refresh'] == true;
            final skipAuthRecovery =
                error.requestOptions.extra['skip_auth_recovery'] == true;
            final alreadyRefreshed =
                error.requestOptions.extra['auth_refreshed'] == true;

            // Public/unauthed endpoints should return backend 401 details as-is.
            if (skipAuthRecovery) {
              handler.next(error);
              return;
            }

            if (_refreshTokenInvalid) {
              handler.next(
                DioException(
                  requestOptions: error.requestOptions,
                  error: const AuthenticationException('Session expired'),
                ),
              );
              return;
            }

            if (isRefreshCall || skipAuthRefresh) {
              _refreshTokenInvalid = true;
              await _invalidateSessionTokens();
            }

            if (!isRefreshCall && !skipAuthRefresh && !alreadyRefreshed) {
              final refreshToken = await _secureStorage.getRefreshToken();
              if (refreshToken == null || refreshToken.isEmpty) {
                _refreshTokenInvalid = true;
                await _invalidateSessionTokens();
                handler.next(
                  DioException(
                    requestOptions: error.requestOptions,
                    error: const AuthenticationException('Session expired'),
                  ),
                );
                return;
              }
              final refreshed = await _refreshToken();
              if (refreshed) {
                // Retry the request once with new token
                final opts = error.requestOptions;
                opts.extra['auth_refreshed'] = true;
                final token = await _secureStorage.getAccessToken();
                if (token != null) {
                  opts.headers[ApiConstants.headerAuthorization] =
                      'Bearer $token';
                }
                try {
                  final response = await _dio.fetch(opts);
                  handler.resolve(response);
                  return;
                } catch (e) {
                  handler.next(error);
                  return;
                }
              }
            }

            handler.next(
              DioException(
                requestOptions: error.requestOptions,
                error: const AuthenticationException('Session expired'),
              ),
            );
            return;
          }

          // Retry once with alternate dev base URL for emulator/device mismatch.
          if (error.type == DioExceptionType.connectionError ||
              error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.sendTimeout) {
            final alreadyRetried =
                error.requestOptions.extra['retried_alt_base'] == true;
            final currentBaseUrl = error.requestOptions.baseUrl;
            final alternate = AppConfig.getAlternateBaseUrl(currentBaseUrl);
            if (!alreadyRetried && alternate != null) {
              try {
                final opts = error.requestOptions;
                opts.extra['retried_alt_base'] = true;
                opts.baseUrl = alternate;
                _dio.options.baseUrl = alternate;
                if (kDebugMode) {
                  _logger.w('Retrying with alternate base URL: $alternate');
                }
                final response = await _dio.fetch(opts);
                handler.resolve(response);
                return;
              } catch (_) {
                // Fall through to normal error handling below.
              }
            }
          }

          handler.next(error);
        },
      ),
    );
  }

  Future<bool> _refreshToken() async {
    final refreshToken = await _secureStorage.getRefreshToken();
    if (refreshToken == null) return false;
    final deviceId = await _secureStorage.getDeviceId();

    if (_refreshTokenInvalid && _lastRefreshToken == refreshToken) {
      return false;
    }

    if (_refreshInFlight != null) {
      return _refreshInFlight!;
    }

    final completer = Completer<bool>();
    _refreshInFlight = completer.future;
    _lastRefreshToken = refreshToken;

    try {
      final response = await _dio.post(
        ApiConstants.refreshToken,
        data: {
          'refresh_token': refreshToken,
          if (deviceId != null && deviceId.isNotEmpty) 'device_id': deviceId,
        },
        options: Options(extra: {'skip_auth_refresh': true}),
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access_token'] as String;
        await _secureStorage.saveAccessToken(newAccessToken);
        _refreshTokenInvalid = false;
        _sessionExpiredNotified = false;
        completer.complete(true);
        return true;
      }

      if (response.statusCode == 401) {
        _refreshTokenInvalid = true;
        await _invalidateSessionTokens();
      }
      completer.complete(false);
      return false;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401) {
        _refreshTokenInvalid = true;
        await _invalidateSessionTokens();
      }
      completer.complete(false);
      return false;
    } finally {
      _refreshInFlight = null;
    }
  }

  Future<void> _invalidateSessionTokens() async {
    await _secureStorage.deleteAccessToken();
    await _secureStorage.deleteRefreshToken();
    if (!_sessionExpiredNotified) {
      _sessionExpiredNotified = true;
      _sessionExpiredController.add(null);
    }
  }

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Download file
  Future<Response> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Helper to safely extract detail message from error response
  String _extractDetail(dynamic data, String defaultValue) {
    if (data is Map<String, dynamic>) {
      final detail = data['detail'];
      if (detail is String) {
        return detail;
      } else if (detail != null) {
        return detail.toString();
      }
    } else if (data is String) {
      return data;
    }
    return defaultValue;
  }

  Exception _handleError(DioException error) {
    final interceptedError = error.error;
    if (interceptedError is AppException) {
      return interceptedError;
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException('Request timeout. Please try again.');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;

        if (statusCode == 400) {
          final detail = _extractDetail(data, 'Bad request');
          // Check if it's a CORS preflight error
          if (detail.toLowerCase().contains('cors') ||
              detail.toLowerCase().contains('origin')) {
            return NetworkException(
                'CORS error: $detail. Please check server CORS configuration.');
          }
          return ValidationException(
            detail,
            _extractValidationErrors(data),
          );
        } else if (statusCode == 401) {
          return AuthenticationException(
            _extractDetail(data, 'Authentication failed'),
          );
        } else if (statusCode == 403) {
          return AuthorizationException(
            _extractDetail(data, 'Access denied'),
          );
        } else if (statusCode == 404) {
          return ServerException('Resource not found', statusCode);
        } else if (statusCode == 409) {
          return ValidationException(
            _extractDetail(data, 'Conflict occurred'),
          );
        } else if (statusCode == 422) {
          return ValidationException(
            _extractDetail(data, 'Validation error'),
            _extractValidationErrors(data),
          );
        } else if (statusCode == 429) {
          return ServerException(
            _extractDetail(data, 'Rate limit exceeded'),
            statusCode,
          );
        } else if (statusCode != null && statusCode >= 500) {
          return ServerException(
            _extractDetail(data, 'Server error'),
            statusCode,
          );
        }
        return ServerException(
          _extractDetail(data, 'Unknown error'),
          statusCode,
        );
      case DioExceptionType.cancel:
        return NetworkException('Request cancelled');
      case DioExceptionType.connectionError:
        // Check if it's a CORS error
        if (error.message?.toLowerCase().contains('cors') == true ||
            error.message?.toLowerCase().contains('origin') == true) {
          return NetworkException(
              'CORS error: The server is not allowing requests from this origin. Please check server CORS configuration.');
        }
        return NetworkException(
            'No internet connection. Please check your network and try again.');
      default:
        return NetworkException('Network error occurred');
    }
  }

  Map<String, List<String>>? _extractValidationErrors(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('details')) {
      final details = data['details'];
      if (details is Map<String, dynamic>) {
        final errors = <String, List<String>>{};
        details.forEach((key, value) {
          if (value is List) {
            errors[key] = value.map((e) => e.toString()).toList();
          } else {
            errors[key] = [value.toString()];
          }
        });
        return errors;
      }
    }
    return null;
  }

  dynamic _normalizeResponseData(dynamic data) {
    dynamic current = data;
    for (var i = 0; i < 2; i++) {
      if (current is! String) break;
      final decoded = _tryDecodeJson(current);
      if (decoded == null) break;
      current = decoded;
    }
    return current;
  }

  dynamic _tryDecodeJson(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    final looksLikeJsonObject =
        trimmed.startsWith('{') && trimmed.endsWith('}');
    final looksLikeJsonArray = trimmed.startsWith('[') && trimmed.endsWith(']');
    final looksLikeQuotedJson =
        trimmed.startsWith('"') && trimmed.endsWith('"');

    if (!looksLikeJsonObject && !looksLikeJsonArray && !looksLikeQuotedJson) {
      return null;
    }

    try {
      return jsonDecode(trimmed);
    } catch (_) {
      return null;
    }
  }
}
