/// Date utility functions for consistent date handling
class AppDateUtils {
  AppDateUtils._();

  /// Normalize a DateTime to the start of day in local timezone
  /// This ensures consistent date handling regardless of time component
  static DateTime normalizeToStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get today's date normalized to start of day
  static DateTime today() {
    final now = DateTime.now();
    return normalizeToStartOfDay(now);
  }

  /// Format date as YYYY-MM-DD string for API requests
  /// Uses local date to avoid timezone issues
  static String formatDateForApi(DateTime date) {
    final normalized = normalizeToStartOfDay(date);
    return '${normalized.year.toString().padLeft(4, '0')}-'
        '${normalized.month.toString().padLeft(2, '0')}-'
        '${normalized.day.toString().padLeft(2, '0')}';
  }

  /// Format date as ISO8601 string for API requests
  /// Normalizes to start of day to avoid timezone issues
  static String formatDateTimeForApi(DateTime date) {
    final normalized = normalizeToStartOfDay(date);
    return normalized.toIso8601String();
  }
}
