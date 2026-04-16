import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../network/api_client.dart';
import '../storage/local_storage_service.dart';
import '../storage/secure_storage_service.dart';
import '../security/app_lock_service.dart';
import '../database/app_database.dart';
import '../database/local_database.dart';
import '../sync/sync_queue.dart';
import '../sync/sync_service.dart';
import '../sync/background_sync_service.dart';
import '../analytics/analytics_service.dart';
import '../utils/performance_utils.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/bank_repository.dart';
import '../../data/repositories/backup_repository.dart';
import '../../data/repositories/business_repository.dart';
import '../../data/repositories/cash_repository.dart';
import '../../data/repositories/customer_repository.dart';
import '../../data/repositories/expense_repository.dart';
import '../../data/repositories/invoice_repository.dart';
import '../../data/repositories/reminder_repository.dart';
import '../../data/repositories/reports_repository.dart';
import '../../data/repositories/staff_repository.dart';
import '../../data/repositories/stock_repository.dart';
import '../../data/repositories/supplier_repository.dart';

final getIt = GetIt.instance;

/// Dependency Injection Setup
Future<void> setupDependencyInjection() async {
  // External Dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Logger
  getIt.registerSingleton<Logger>(
    Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 5,
        lineLength: 50,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
    ),
  );

  // Storage Services
  getIt.registerSingleton<SecureStorageService>(
    SecureStorageService(),
  );

  getIt.registerSingleton<LocalStorageService>(
    LocalStorageService(sharedPreferences),
  );

  // App Lock Service
  getIt.registerSingleton<AppLockService>(
    AppLockService(
      localAuth: LocalAuthentication(),
      secureStorage: const FlutterSecureStorage(),
    ),
  );

  // API Client
  getIt.registerSingleton<ApiClient>(
    ApiClient(
      secureStorage: getIt<SecureStorageService>(),
      logger: getIt<Logger>(),
    ),
  );

  // Local Database (Drift)
  getIt.registerSingleton<AppDatabase>(AppDatabase());

  // Sync Queue (Drift-backed)
  getIt.registerSingleton<SyncQueue>(
    SyncQueue(
      appDatabase: getIt<AppDatabase>(),
      secureStorage: getIt<SecureStorageService>(),
    ),
  );

  // Repositories
  getIt.registerSingleton<AuthRepository>(
    AuthRepository(
      apiClient: getIt<ApiClient>(),
      secureStorage: getIt<SecureStorageService>(),
      localStorage: getIt<LocalStorageService>(),
      appDatabase: getIt<AppDatabase>(),
    ),
  );

  getIt.registerSingleton<BusinessRepository>(
    BusinessRepository(
      apiClient: getIt<ApiClient>(),
      secureStorage: getIt<SecureStorageService>(),
      localStorage: getIt<LocalStorageService>(),
      appDatabase: getIt<AppDatabase>(),
    ),
  );

  getIt.registerSingleton<CashRepository>(
    CashRepository(
      apiClient: getIt<ApiClient>(),
      appDatabase: getIt<AppDatabase>(),
      syncQueue: getIt<SyncQueue>(),
    ),
  );

  getIt.registerSingleton<StockRepository>(
    StockRepository(
      apiClient: getIt<ApiClient>(),
      appDatabase: getIt<AppDatabase>(),
      syncQueue: getIt<SyncQueue>(),
    ),
  );

  getIt.registerSingleton<InvoiceRepository>(
    InvoiceRepository(
      apiClient: getIt<ApiClient>(),
      appDatabase: getIt<AppDatabase>(),
      syncQueue: getIt<SyncQueue>(),
    ),
  );

  getIt.registerSingleton<CustomerRepository>(
    CustomerRepository(
      apiClient: getIt<ApiClient>(),
      appDatabase: getIt<AppDatabase>(),
      syncQueue: getIt<SyncQueue>(),
    ),
  );

  getIt.registerSingleton<SupplierRepository>(
    SupplierRepository(
      apiClient: getIt<ApiClient>(),
      appDatabase: getIt<AppDatabase>(),
      syncQueue: getIt<SyncQueue>(),
    ),
  );

  getIt.registerSingleton<ExpenseRepository>(
    ExpenseRepository(
      apiClient: getIt<ApiClient>(),
      appDatabase: getIt<AppDatabase>(),
      syncQueue: getIt<SyncQueue>(),
    ),
  );

  getIt.registerSingleton<StaffRepository>(
    StaffRepository(
      apiClient: getIt<ApiClient>(),
      appDatabase: getIt<AppDatabase>(),
      syncQueue: getIt<SyncQueue>(),
    ),
  );

  getIt.registerSingleton<ReminderRepository>(
    ReminderRepository(
      apiClient: getIt<ApiClient>(),
      appDatabase: getIt<AppDatabase>(),
      syncQueue: getIt<SyncQueue>(),
    ),
  );

  getIt.registerSingleton<BankRepository>(
    BankRepository(
      apiClient: getIt<ApiClient>(),
      appDatabase: getIt<AppDatabase>(),
      syncQueue: getIt<SyncQueue>(),
    ),
  );

  getIt.registerSingleton<ReportsRepository>(
    ReportsRepository(
      apiClient: getIt<ApiClient>(),
      appDatabase: getIt<AppDatabase>(),
    ),
  );

  getIt.registerSingleton<BackupRepository>(
    BackupRepository(
      apiClient: getIt<ApiClient>(),
    ),
  );

  // Local Database (legacy)
  getIt.registerSingleton<LocalDatabase>(LocalDatabase());

  // Sync Services
  getIt.registerSingleton<SyncService>(
    SyncService(
      apiClient: getIt<ApiClient>(),
      secureStorage: getIt<SecureStorageService>(),
      localStorage: getIt<LocalStorageService>(),
      authRepository: getIt<AuthRepository>(),
      syncQueue: getIt<SyncQueue>(),
      appDatabase: getIt<AppDatabase>(),
    ),
  );

  // Background Sync Service
  getIt.registerSingleton<BackgroundSyncService>(
    BackgroundSyncService(
      syncService: getIt<SyncService>(),
      syncQueue: getIt<SyncQueue>(),
      localStorage: getIt<LocalStorageService>(),
      authRepository: getIt<AuthRepository>(),
    ),
  );

  // Analytics Service
  getIt.registerSingleton<AnalyticsService>(AnalyticsService());

  // Enable performance optimizations
  PerformanceUtils.enablePerformanceOptimizations();
}
