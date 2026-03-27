import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:sentry_flutter/sentry_flutter.dart';

/// Sentry configuration for crash reporting
class SentryConfig {
  static const _sensitiveKeys = ['password', 'token', 'secret'];

  /// Initialize Sentry for crash reporting
  static Future<void> initialize() async {
    const dsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');
    if (dsn.isEmpty) return;

    await SentryFlutter.init((options) {
      options.dsn = dsn;
      options.environment = kReleaseMode ? 'production' : 'staging';
      options.tracesSampleRate = kReleaseMode ? 0.1 : 1.0;
      options.beforeBreadcrumb = _filterSensitiveBreadcrumb;
    });
  }

  static Breadcrumb? _filterSensitiveBreadcrumb(
      Breadcrumb? breadcrumb, Hint hint) {
    if (breadcrumb?.data == null || breadcrumb!.data is! Map) return breadcrumb;

    final data = Map<String, dynamic>.from(breadcrumb.data as Map);
    final hasSensitive = data.keys
        .any((k) => _sensitiveKeys.any((s) => k.toLowerCase().contains(s)));
    if (!hasSensitive) return breadcrumb;

    data.removeWhere(
        (k, _) => _sensitiveKeys.any((s) => k.toLowerCase().contains(s)));
    return breadcrumb.copyWith(data: data);
  }

  /// Capture exception
  static Future<void> captureException(
      dynamic exception, StackTrace? stackTrace) async {
    if (kDebugMode) return;
    await Sentry.captureException(exception, stackTrace: stackTrace);
  }

  /// Capture message
  static Future<void> captureMessage(String message,
      {SentryLevel level = SentryLevel.info}) async {
    if (kDebugMode) return;
    await Sentry.captureMessage(message, level: level);
  }

  /// Set user context
  static Future<void> setUser(
      {String? id, String? email, String? username}) async {
    await Sentry.configureScope((scope) {
      scope.setUser(SentryUser(id: id, email: email, username: username));
    });
  }

  /// Clear user context
  static Future<void> clearUser() async {
    await Sentry.configureScope((scope) => scope.setUser(null));
  }
}
