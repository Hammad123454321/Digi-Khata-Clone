import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';

/// Application Configuration
class AppConfig {
  AppConfig._();

  static bool get isDevelopment => kDebugMode;
  static bool get isProduction => kReleaseMode;

  static const String _baseUrlOverride =
      String.fromEnvironment('API_BASE_URL', defaultValue: '');

  static String get baseUrl {
    if (_baseUrlOverride.isNotEmpty) {
      return _baseUrlOverride;
    }
    if (isDevelopment) {
      return ApiConstants.baseUrlDev;
    }
    return ApiConstants.baseUrlProd;
  }

  static List<String> get devBaseUrls => [
        ApiConstants.baseUrlDev,
        ApiConstants.baseUrlDevAlt,
      ];

  static String? getAlternateBaseUrl(String current) {
    if (!isDevelopment) return null;
    for (final url in devBaseUrls) {
      if (url != current) {
        return url;
      }
    }
    return null;
  }

  static String get apiBaseUrl => '$baseUrl${ApiConstants.apiPrefix}';

  // API Configuration
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // Sync Configuration
  static const int syncBatchSize = 100;
  static const Duration syncInterval = Duration(minutes: 5);

  // Cache Configuration
  static const Duration cacheExpiration = Duration(hours: 1);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}
