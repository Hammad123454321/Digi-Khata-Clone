import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../di/injection.dart';

/// Analytics Service for tracking user events
/// In production, integrate with Firebase Analytics, Mixpanel, etc.
class AnalyticsService {
  AnalyticsService() : _logger = getIt<Logger>();

  final Logger _logger;

  /// Track screen view
  void trackScreenView(String screenName, {Map<String, dynamic>? parameters}) {
    if (kDebugMode) {
      _logger.d('Screen View: $screenName', error: parameters);
    }
    // Production: FirebaseAnalytics.instance.logScreenView(screenName: screenName);
  }

  /// Track event
  void trackEvent(String eventName, {Map<String, dynamic>? parameters}) {
    if (kDebugMode) {
      _logger.d('Event: $eventName', error: parameters);
    }
    // Production: FirebaseAnalytics.instance.logEvent(name: eventName, parameters: parameters);
  }

  /// Track user property
  void setUserProperty(String name, String value) {
    if (kDebugMode) {
      _logger.d('User Property: $name = $value');
    }
    // Production: FirebaseAnalytics.instance.setUserProperty(name: name, value: value);
  }

  /// Track error
  void trackError(String error, StackTrace? stackTrace) {
    _logger.e('Error: $error', error: stackTrace);
    // Production: FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }
}
