import 'package:intl/intl.dart';
import '../../core/di/injection.dart';
import '../../core/storage/local_storage_service.dart';
import '../models/currency_model.dart';

/// Currency formatting helper for Enshaal Khata.
class CurrencyUtils {
  CurrencyUtils._();

  static NumberFormat? _cachedFormatter;
  static CurrencyModel? _cachedCurrency;

  /// Get current currency from storage
  static CurrencyModel _getCurrentCurrency() {
    final storage = getIt<LocalStorageService>();
    final currencyCode = storage.getCurrencyPreference();

    if (currencyCode != null) {
      final currency = CurrencyModel.getByCode(currencyCode);
      if (currency != null) {
        return currency;
      }
    }

    return CurrencyModel.getDefault();
  }

  /// Get currency formatter (cached for performance)
  static NumberFormat _getFormatter() {
    final currency = _getCurrentCurrency();

    // Return cached formatter if currency hasn't changed
    if (_cachedCurrency?.code == currency.code && _cachedFormatter != null) {
      return _cachedFormatter!;
    }

    // Create new formatter based on currency
    _cachedCurrency = currency;
    _cachedFormatter = NumberFormat.currency(
      symbol: currency.symbol,
      decimalDigits: 2,
    );

    return _cachedFormatter!;
  }

  /// Format currency amount
  static String formatCurrency(num amount) {
    return _getFormatter().format(amount);
  }

  /// Get current currency model
  static CurrencyModel getCurrentCurrency() {
    return _getCurrentCurrency();
  }

  /// Clear cached formatter (call when currency changes)
  static void clearCache() {
    _cachedFormatter = null;
    _cachedCurrency = null;
  }
}
