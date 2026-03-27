/// API Constants for endpoints, headers, and timeouts.
class ApiConstants {
  ApiConstants._();

  // Base URLs
  static const String baseUrlDev = 'http://10.0.2.2:8000';
  static const String baseUrlDevAlt = 'http://localhost:8000';
  static const String baseUrlProd = 'https://qazitraders.com';

  // API prefix
  static const String apiPrefix = '/api/v1';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const Duration sendTimeout = Duration(seconds: 10);

  // Headers
  static const String headerContentType = 'Content-Type';
  static const String headerAccept = 'Accept';
  static const String headerAuthorization = 'Authorization';
  static const String headerBusinessId = 'X-Business-Id';
  static const String headerDeviceId = 'X-Device-Id';

  // Content types
  static const String applicationJson = 'application/json';

  // Auth
  static const String requestOtp = '/auth/request-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String refreshToken = '/auth/refresh';
  static const String setPin = '/auth/set-pin';
  static const String verifyPin = '/auth/verify-pin';

  // Businesses
  static const String businesses = '/businesses';

  // Cash
  static const String cashTransactions = '/cash/transactions';
  static const String cashBalance = '/cash/balance';
  static const String cashSummary = '/cash/summary';

  // Customers
  static const String customers = '/customers';

  // Suppliers
  static const String suppliers = '/suppliers';

  // Bank
  static const String bankAccounts = '/banks/accounts';
  static const String bankTransactions = '/banks/transactions';
  static const String bankTransfers = '/banks/transfers';

  // Expenses
  static const String expenses = '/expenses';
  static const String expenseCategories = '/expenses/categories';
  static const String expensesSummary = '/expenses/summary';

  // Staff
  static const String staff = '/staff';

  // Stock
  static const String stockItems = '/stock/items';
  static const String stockTransactions = '/stock/transactions';
  static const String stockAlerts = '/stock/alerts';

  // Invoices
  static const String invoices = '/invoices';

  // Reports
  static const String reportsSales = '/reports/sales';
  static const String reportsCashFlow = '/reports/cash-flow';
  static const String reportsExpenses = '/reports/expenses';
  static const String reportsStock = '/reports/stock';
  static const String reportsProfitLoss = '/reports/profit-loss';

  // Devices
  static const String devices = '/devices';
  static const String devicePairingToken = '/devices/pairing-token';
  static const String devicePair = '/devices/pair';

  // Sync
  static const String syncPull = '/sync/pull';
  static const String syncPush = '/sync/push';
  static const String syncStatus = '/sync/status';

  // Reminders
  static const String reminders = '/reminders';

  // Backups
  static const String backups = '/backups';
}
