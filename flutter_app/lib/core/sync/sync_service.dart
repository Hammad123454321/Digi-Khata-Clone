import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import '../errors/exceptions.dart';
import '../errors/failures.dart';
import '../network/api_client.dart';
import '../storage/local_storage_service.dart';
import '../storage/secure_storage_service.dart';
import '../database/app_database.dart';
import '../constants/api_constants.dart';
import '../constants/storage_constants.dart';
import '../utils/result.dart';
import '../../data/repositories/auth_repository.dart';
import '../../shared/models/customer_model.dart';
import '../../shared/models/invoice_model.dart';
import '../../shared/models/stock_item_model.dart';
import '../../shared/models/inventory_transaction_model.dart';
import '../../shared/models/supplier_model.dart';
import '../../shared/models/expense_model.dart';
import '../../shared/models/cash_transaction_model.dart';
import '../../shared/models/bank_account_model.dart';
import '../../shared/models/bank_transaction_model.dart';
import '../../shared/models/staff_model.dart';
import 'sync_queue.dart';

/// Sync Service for offline-first architecture
class SyncService {
  SyncService({
    required ApiClient apiClient,
    required SecureStorageService secureStorage,
    required LocalStorageService localStorage,
    required AuthRepository authRepository,
    required SyncQueue syncQueue,
    required AppDatabase appDatabase,
  })  : _apiClient = apiClient,
        _secureStorage = secureStorage,
        _localStorage = localStorage,
        _authRepository = authRepository,
        _syncQueue = syncQueue,
        _appDatabase = appDatabase,
        _connectivity = Connectivity();

  final ApiClient _apiClient;
  final SecureStorageService _secureStorage;
  final LocalStorageService _localStorage;
  final AuthRepository _authRepository;
  final SyncQueue _syncQueue;
  final AppDatabase _appDatabase;
  final Connectivity _connectivity;

  /// Check if device is online
  Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// Pull changes from server
  Future<Result<Map<String, dynamic>>> pullChanges({
    String? cursor,
    List<String>? entityTypes,
    int limit = 100,
  }) async {
    try {
      if (!await isOnline()) {
        return Result.failure(NetworkFailure('No internet connection'));
      }

      final isAuthenticated = await _authRepository.isAuthenticated();
      if (!isAuthenticated) {
        return Result.failure(
          AuthenticationFailure('Not authenticated'),
        );
      }

      final response = await _apiClient.post(
        ApiConstants.syncPull,
        data: {
          if (cursor != null) 'cursor': cursor,
          if (entityTypes != null) 'entity_types': entityTypes,
          'limit': limit,
        },
      );

      final data = response.data as Map<String, dynamic>;

      // Update sync cursor
      if (data['next_cursor'] != null) {
        await _saveScopedSyncCursor(data['next_cursor'] as String);
        await _saveScopedLastSyncAt(DateTime.now().toIso8601String());
      }

      return Result.success(data);
    } on DioException catch (e) {
      return Result.failure(NetworkFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  /// Push local changes to server
  Future<Result<Map<String, dynamic>>> pushChanges({
    required List<Map<String, dynamic>> changes,
  }) async {
    try {
      if (!await isOnline()) {
        return Result.failure(NetworkFailure('No internet connection'));
      }

      final isAuthenticated = await _authRepository.isAuthenticated();
      if (!isAuthenticated) {
        return Result.failure(
          AuthenticationFailure('Not authenticated'),
        );
      }

      final response = await _apiClient.post(
        ApiConstants.syncPush,
        data: {'changes': changes},
      );

      final data = response.data as Map<String, dynamic>;

      // Update sync cursor
      if (data['next_cursor'] != null) {
        await _saveScopedSyncCursor(data['next_cursor'] as String);
        await _saveScopedLastSyncAt(DateTime.now().toIso8601String());
      }

      return Result.success(data);
    } on DioException catch (e) {
      return Result.failure(NetworkFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  /// Push queued local operations using REST endpoints (incremental offline sync)
  Future<Result<int>> pushQueuedOperations({int limit = 50}) async {
    try {
      if (!await isOnline()) {
        return Result.failure(NetworkFailure('No internet connection'));
      }

      final isAuthenticated = await _authRepository.isAuthenticated();
      if (!isAuthenticated) {
        return Result.failure(
          AuthenticationFailure('Not authenticated'),
        );
      }

      final queuedChanges = await _syncQueue.getQueue(limit: limit);
      if (queuedChanges.isEmpty) {
        return const Result.success(0);
      }

      var pushed = 0;
      final currentBusinessId = await _secureStorage.getBusinessId();
      for (final item in queuedChanges) {
        final id = item['id'] as int?;
        if (id == null) continue;
        await _syncQueue.markAttempted(id);

        final entityType = item['entity_type'] as String?;
        final action = item['action'] as String?;
        final data = Map<String, dynamic>.from(
          (item['data'] as Map).cast<String, dynamic>(),
        );
        final queuedBusinessId = data['business_id']?.toString();
        if (queuedBusinessId != null &&
            queuedBusinessId.isNotEmpty &&
            currentBusinessId != null &&
            currentBusinessId.isNotEmpty &&
            queuedBusinessId != currentBusinessId) {
          await _syncQueue.incrementRetry(
            id,
            errorMessage: 'Queued for a different business context',
          );
          continue;
        }

        try {
          final handled = await _processQueueItem(
            entityType: entityType,
            action: action,
            data: data,
          );
          if (handled) {
            await _syncQueue.removeById(id);
            pushed += 1;
          } else {
            await _syncQueue.incrementRetry(
              id,
              errorMessage: 'Unsupported sync operation',
            );
          }
        } on AppException catch (e) {
          if (e is AuthenticationException || e is AuthorizationException) {
            await _syncQueue.incrementRetry(
              id,
              errorMessage: e.message,
              maxRetries: 3,
            );
            return Result.failure(
              AuthenticationFailure('Session expired. Please sign in again.'),
            );
          }
          await _syncQueue.incrementRetry(id, errorMessage: e.message);
        } catch (e) {
          await _syncQueue.incrementRetry(id, errorMessage: e.toString());
        }
      }

      if (pushed > 0) {
        await _saveScopedLastSyncAt(DateTime.now().toIso8601String());
      }

      return Result.success(pushed);
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  /// Get sync status
  Future<Result<Map<String, dynamic>>> getSyncStatus() async {
    try {
      if (!await isOnline()) {
        return const Result.failure(NetworkFailure('No internet connection'));
      }

      final response = await _apiClient.get(ApiConstants.syncStatus);
      return Result.success(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return Result.failure(NetworkFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  /// Get last sync cursor
  Future<String?> getLastSyncCursor() async {
    final scope = await _getSyncScope();
    if (scope == null) {
      return await _secureStorage.getSyncCursor();
    }
    final scopedCursor = await _secureStorage.getScopedSyncCursor(
      userId: scope.userId,
      businessId: scope.businessId,
    );
    return scopedCursor ?? await _secureStorage.getSyncCursor();
  }

  /// Perform full sync (pull then push)
  Future<Result<Map<String, dynamic>>> performFullSync({
    List<String>? entityTypes,
  }) async {
    try {
      // 1. Push queued local operations
      final pushQueueResult = await pushQueuedOperations();
      if (pushQueueResult.isFailure) {
        return Result.failure(pushQueueResult.failureOrNull!);
      }

      // 2. Pull changes from server
      final cursor = await getLastSyncCursor();
      final pullResult = await pullChanges(
        cursor: cursor,
        entityTypes: entityTypes,
      );

      if (pullResult.isFailure) {
        return pullResult;
      }

      // 3. Apply pulled changes to local database
      final pulledChanges =
          pullResult.dataOrNull?['changes'] as List<dynamic>? ?? [];
      final applied = await _applyPulledChanges(pulledChanges);

      return Result.success({
        'status': 'completed',
        'pulled': pullResult.dataOrNull?['total_count'] ?? 0,
        'pushed': pushQueueResult.dataOrNull ?? 0,
        'applied': applied,
      });
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  Future<Result<void>> resolveConflicts({
    required List<Map<String, dynamic>> resolutions,
  }) async {
    try {
      if (!await isOnline()) {
        return const Result.failure(NetworkFailure('No internet connection'));
      }

      for (final resolution in resolutions) {
        final shouldKeepServer =
            resolution['resolution']?.toString() == 'server';
        final entityType = resolution['entity_type']?.toString();
        final entityId = resolution['entity_id']?.toString();
        if (entityType == null ||
            entityType.isEmpty ||
            entityId == null ||
            entityId.isEmpty) {
          continue;
        }
        if (shouldKeepServer) {
          await _syncQueue.removeByEntity(
            entityType: entityType,
            entityId: entityId,
          );
        } else {
          await _syncQueue.retryDeadLettersForEntity(
            entityType: entityType,
            entityId: entityId,
          );
        }
      }

      final syncResult = await performFullSync();
      if (syncResult.isFailure) {
        return Result.failure(syncResult.failureOrNull!);
      }
      return const Result.success(null);
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  Future<Map<String, dynamic>> getLocalSyncQueueHealth() async {
    final pendingCount = await _syncQueue.getQueueSize();
    final failedCount = await _syncQueue.getDeadLetterCount();
    final online = await isOnline();
    return {
      'is_online': online,
      'pending_count': pendingCount,
      'failed_count': failedCount,
      'last_sync_at': _localStorage.getLastSyncAt(),
    };
  }

  Future<bool> _processQueueItem({
    required String? entityType,
    required String? action,
    required Map<String, dynamic> data,
  }) async {
    if (entityType == 'customer' && action == 'create') {
      await _syncCustomerCreate(data);
      return true;
    }
    if (entityType == 'customer' && action == 'delete') {
      await _syncCustomerDelete(data);
      return true;
    }
    if (entityType == 'customer_transaction' && action == 'create') {
      await _syncCustomerTransactionCreate(data);
      return true;
    }
    if (entityType == 'customer_transaction' && action == 'update') {
      await _syncCustomerTransactionUpdate(data);
      return true;
    }
    if (entityType == 'customer_transaction' && action == 'delete') {
      await _syncCustomerTransactionDelete(data);
      return true;
    }
    if (entityType == 'invoice' && action == 'create') {
      await _syncInvoiceCreate(data);
      return true;
    }
    if (entityType == 'invoice' && action == 'update') {
      await _syncInvoiceUpdate(data);
      return true;
    }
    if (entityType == 'invoice' && action == 'delete') {
      await _syncInvoiceDelete(data);
      return true;
    }
    if (entityType == 'item' && action == 'create') {
      await _syncStockItemCreate(data);
      return true;
    }
    if (entityType == 'item' && action == 'update') {
      await _syncStockItemUpdate(data);
      return true;
    }
    if (entityType == 'inventory_transaction' && action == 'create') {
      await _syncInventoryTransactionCreate(data);
      return true;
    }
    if (entityType == 'supplier' && action == 'create') {
      await _syncSupplierCreate(data);
      return true;
    }
    if (entityType == 'supplier_transaction' && action == 'create') {
      await _syncSupplierTransactionCreate(data);
      return true;
    }
    if (entityType == 'expense_category' && action == 'create') {
      await _syncExpenseCategoryCreate(data);
      return true;
    }
    if (entityType == 'expense' && action == 'create') {
      await _syncExpenseCreate(data);
      return true;
    }
    if (entityType == 'cash_transaction' && action == 'create') {
      await _syncCashTransactionCreate(data);
      return true;
    }
    if (entityType == 'bank_account' && action == 'create') {
      await _syncBankAccountCreate(data);
      return true;
    }
    if (entityType == 'bank_transaction' && action == 'create') {
      await _syncBankTransactionCreate(data);
      return true;
    }
    if (entityType == 'cash_bank_transfer' && action == 'create') {
      await _syncCashBankTransferCreate(data);
      return true;
    }
    if (entityType == 'staff' && action == 'create') {
      await _syncStaffCreate(data);
      return true;
    }
    if (entityType == 'staff_salary' && action == 'create') {
      await _syncStaffSalaryCreate(data);
      return true;
    }
    if (entityType == 'reminder' && action == 'create') {
      await _syncReminderCreate(data);
      return true;
    }
    if (entityType == 'reminder' && action == 'resolve') {
      await _syncReminderResolve(data);
      return true;
    }
    return false;
  }

  Future<void> _syncCustomerCreate(Map<String, dynamic> data) async {
    final clientId = data['client_id']?.toString();
    final payload = Map<String, dynamic>.from(data)
      ..remove('client_id')
      ..remove('updated_at')
      ..remove('version')
      ..remove('business_id');

    final response = await _apiClient.post(
      ApiConstants.customers,
      data: payload,
    );

    final customer = CustomerModel.fromJson(
      response.data as Map<String, dynamic>,
    );

    if (clientId != null) {
      await _applyCustomerServerData(
        clientId: clientId,
        customer: customer,
      );
    } else {
      await _appDatabase.upsertCustomers([
        CustomersCompanion(
          serverId: Value(customer.id),
          name: Value(customer.name),
          phone: Value(customer.phone),
          email: Value(customer.email),
          address: Value(customer.address),
          isActive: Value(customer.isActive ?? true),
          balance: Value(customer.balance),
          createdAt: Value(customer.createdAt ?? DateTime.now()),
          updatedAt: Value(customer.updatedAt ?? DateTime.now()),
          isSynced: const Value(true),
          syncStatus: const Value('synced'),
        ),
      ]);
    }
  }

  Future<void> _applyCustomerServerData({
    required String clientId,
    required CustomerModel customer,
  }) async {
    final companion = CustomersCompanion(
      serverId: Value(customer.id),
      clientId: Value(clientId),
      name: Value(customer.name),
      phone: Value(customer.phone),
      email: Value(customer.email),
      address: Value(customer.address),
      isActive: Value(customer.isActive ?? true),
      balance: Value(customer.balance),
      createdAt: Value(customer.createdAt ?? DateTime.now()),
      updatedAt: Value(customer.updatedAt ?? DateTime.now()),
      isSynced: const Value(true),
      syncStatus: const Value('synced'),
    );

    final updated = await _appDatabase.updateCustomerByClientId(
      clientId: clientId,
      companion: companion,
    );

    if (updated == 0) {
      await _appDatabase.upsertCustomers([companion]);
    }

    await _appDatabase.updateInvoicesCustomerId(
      oldId: clientId,
      newId: customer.id,
    );
    await _appDatabase.updateCustomerTransactionsCustomerId(
      oldId: clientId,
      newId: customer.id,
    );
  }

  Future<void> _syncCustomerDelete(Map<String, dynamic> data) async {
    final serverId = data['server_id']?.toString();
    final clientId = data['client_id']?.toString();

    if (serverId != null) {
      await _apiClient.delete('${ApiConstants.customers}/$serverId');
      final syncedUpdate = CustomersCompanion(
        isActive: const Value(false),
        isSynced: const Value(true),
        syncStatus: const Value('synced'),
        updatedAt: Value(DateTime.now()),
      );
      await _appDatabase.updateCustomerByServerId(
        serverId: serverId,
        companion: syncedUpdate,
      );
      if (clientId != null) {
        await _appDatabase.updateCustomerByClientId(
          clientId: clientId,
          companion: syncedUpdate,
        );
      }
      return;
    }

    if (clientId != null) {
      await _appDatabase.deleteCustomerByClientId(clientId);
    }
  }

  Future<void> _syncCustomerTransactionCreate(Map<String, dynamic> data) async {
    final clientId = data['client_id']?.toString();
    final payload = Map<String, dynamic>.from(data)
      ..remove('client_id')
      ..remove('updated_at')
      ..remove('version')
      ..remove('business_id');

    if (clientId != null) {
      final local = await _appDatabase.findCustomerTransactionByClientId(
        clientId,
      );
      if (local != null) {
        payload['customer_id'] = local.customerId;
        if (local.referenceId != null) {
          payload['reference_id'] = local.referenceId;
        }
        if (local.referenceType != null) {
          payload['reference_type'] = local.referenceType;
        }
      }
    }

    final rawCustomerId = payload['customer_id']?.toString();
    if (rawCustomerId == null || rawCustomerId.isEmpty) {
      throw const SyncException('Missing customer_id');
    }

    final customerId = await _resolveCustomerServerId(rawCustomerId);
    final transactionType = payload['transaction_type']?.toString() ?? '';
    final referenceType = payload['reference_type']?.toString();
    if (referenceType == 'invoice' && payload['reference_id'] != null) {
      final rawReferenceId = payload['reference_id'].toString();
      final localInvoice = await _appDatabase.findInvoiceByServerId(
        rawReferenceId,
      );
      if (localInvoice != null) {
        if (localInvoice.isSynced == false) {
          throw const SyncException('Dependent invoice not synced');
        }
        payload['reference_id'] = localInvoice.serverId;
      }
    }

    if (transactionType != 'payment') {
      if (clientId != null) {
        await _appDatabase.updateCustomerTransactionByClientId(
          clientId: clientId,
          companion: CustomerTransactionsCompanion(
            customerId: Value(customerId),
            isSynced: const Value(true),
            syncStatus: const Value('synced'),
          ),
        );
      }
      return;
    }

    final requestBody = <String, dynamic>{
      'amount': payload['amount'],
      'date': payload['date'],
      if (payload['remarks'] != null) 'remarks': payload['remarks'],
    };
    if (referenceType == 'invoice' && payload['reference_id'] != null) {
      requestBody['invoice_id'] = payload['reference_id'];
    }

    final response = await _apiClient.post(
      '${ApiConstants.customers}/$customerId/payments',
      data: requestBody,
    );

    final responseMap = response.data is Map
        ? Map<String, dynamic>.from(response.data as Map)
        : <String, dynamic>{};
    final serverId =
        responseMap['id']?.toString() ?? responseMap['_id']?.toString();

    final companion = CustomerTransactionsCompanion(
      serverId: Value(serverId),
      clientId: Value(clientId),
      customerId: Value(customerId),
      transactionType: const Value('payment'),
      amount: Value(
        _normalizeAmount(responseMap['amount'] ?? payload['amount']),
      ),
      date: Value(_parseDate(responseMap['date']) ?? DateTime.now()),
      referenceId: Value(
        responseMap['reference_id']?.toString() ??
            payload['reference_id']?.toString(),
      ),
      referenceType: Value(
        responseMap['reference_type']?.toString() ??
            payload['reference_type']?.toString(),
      ),
      remarks: Value(
        responseMap['remarks']?.toString() ?? payload['remarks']?.toString(),
      ),
      createdAt: Value(_parseDate(responseMap['created_at'])),
      isSynced: const Value(true),
      syncStatus: const Value('synced'),
    );

    var updated = 0;
    if (clientId != null) {
      updated = await _appDatabase.updateCustomerTransactionByClientId(
        clientId: clientId,
        companion: companion,
      );
    }

    if (updated == 0) {
      await _appDatabase.upsertCustomerTransactions([companion]);
    }
  }

  Future<void> _syncCustomerTransactionUpdate(Map<String, dynamic> data) async {
    final rawCustomerId = data['customer_id']?.toString();
    final rawTransactionId = data['transaction_id']?.toString();
    if (rawCustomerId == null ||
        rawCustomerId.isEmpty ||
        rawTransactionId == null ||
        rawTransactionId.isEmpty) {
      throw const SyncException('Missing customer_id or transaction_id');
    }

    final customerId = await _resolveCustomerServerId(rawCustomerId);
    await _apiClient.patch(
      '${ApiConstants.customers}/$customerId/payments/$rawTransactionId',
      data: {
        'amount': data['amount'],
        'date': data['date'],
        if (data['remarks'] != null) 'remarks': data['remarks'],
      },
    );

    await _appDatabase.updateCustomerTransactionByServerId(
      serverId: rawTransactionId,
      companion: CustomerTransactionsCompanion(
        amount: Value(_normalizeAmount(data['amount'])),
        date: Value(_parseDate(data['date']) ?? DateTime.now()),
        remarks: Value(data['remarks']?.toString()),
        isSynced: const Value(true),
        syncStatus: const Value('synced'),
      ),
    );
  }

  Future<void> _syncCustomerTransactionDelete(Map<String, dynamic> data) async {
    final rawCustomerId = data['customer_id']?.toString();
    final rawTransactionId = data['transaction_id']?.toString();
    if (rawCustomerId == null ||
        rawCustomerId.isEmpty ||
        rawTransactionId == null ||
        rawTransactionId.isEmpty) {
      throw const SyncException('Missing customer_id or transaction_id');
    }

    final customerId = await _resolveCustomerServerId(rawCustomerId);
    await _apiClient.delete(
      '${ApiConstants.customers}/$customerId/payments/$rawTransactionId',
    );
  }

  Future<void> _syncInvoiceCreate(Map<String, dynamic> data) async {
    final clientId = data['client_id']?.toString();
    final payload = await _mapInvoicePayload(Map<String, dynamic>.from(data))
      ..remove('client_id')
      ..remove('updated_at')
      ..remove('version')
      ..remove('business_id');

    final response = await _apiClient.post(
      ApiConstants.invoices,
      data: payload,
    );

    final invoice = InvoiceModel.fromJson(
      response.data as Map<String, dynamic>,
    );

    final companion = _invoiceCompanionFromModel(invoice);

    if (clientId != null) {
      await _appDatabase.updateInvoiceServerId(
        oldId: clientId,
        newId: invoice.id,
        companion: companion,
      );
      await _appDatabase.updateCustomerTransactionsReferenceId(
        oldId: clientId,
        newId: invoice.id,
      );
      await _appDatabase.updateCustomerTransactionByClientId(
        clientId: clientId,
        companion: CustomerTransactionsCompanion(
          serverId: Value(invoice.id),
          referenceId: Value(invoice.id),
          isSynced: const Value(true),
          syncStatus: const Value('synced'),
        ),
      );
    } else {
      await _appDatabase.upsertInvoices([companion]);
    }

    if (invoice.items != null && invoice.items!.isNotEmpty) {
      await _appDatabase.replaceInvoiceItems(
        invoiceServerId: invoice.id,
        entries: _invoiceItemsCompanions(invoice.id, invoice.items!),
      );
    }

    if (invoice.customerId != null && invoice.invoiceType == 'credit') {
      await _appDatabase.upsertCustomerTransactions([
        CustomerTransactionsCompanion(
          serverId: Value(invoice.id),
          customerId: Value(invoice.customerId!),
          transactionType: const Value('credit'),
          amount: Value(invoice.totalAmount),
          date: Value(invoice.date),
          referenceId: Value(invoice.id),
          referenceType: const Value('invoice'),
          remarks: Value(invoice.remarks),
          createdAt: Value(invoice.createdAt),
          isSynced: const Value(true),
          syncStatus: const Value('synced'),
        ),
      ]);
    }
  }

  Future<void> _syncInvoiceUpdate(Map<String, dynamic> data) async {
    final serverId = data['invoice_id']?.toString() ??
        data['id']?.toString() ??
        data['server_id']?.toString();
    if (serverId == null || serverId.isEmpty) {
      throw const SyncException('Missing invoice id');
    }

    final payload = await _mapInvoicePayload(Map<String, dynamic>.from(data))
      ..remove('invoice_id')
      ..remove('id')
      ..remove('server_id')
      ..remove('client_id')
      ..remove('updated_at')
      ..remove('version')
      ..remove('business_id');

    final response = await _apiClient.patch(
      '${ApiConstants.invoices}/$serverId',
      data: payload,
    );

    final invoice = InvoiceModel.fromJson(
      response.data as Map<String, dynamic>,
    );

    await _appDatabase.upsertInvoices([_invoiceCompanionFromModel(invoice)]);
    if (invoice.items != null) {
      await _appDatabase.replaceInvoiceItems(
        invoiceServerId: invoice.id,
        entries: _invoiceItemsCompanions(invoice.id, invoice.items!),
      );
    }

    if (invoice.customerId != null && invoice.invoiceType == 'credit') {
      await _appDatabase.upsertCustomerTransactions([
        CustomerTransactionsCompanion(
          serverId: Value(invoice.id),
          customerId: Value(invoice.customerId!),
          transactionType: const Value('credit'),
          amount: Value(invoice.totalAmount),
          date: Value(invoice.date),
          referenceId: Value(invoice.id),
          referenceType: const Value('invoice'),
          remarks: Value(invoice.remarks),
          createdAt: Value(invoice.createdAt),
          isSynced: const Value(true),
          syncStatus: const Value('synced'),
        ),
      ]);
    }
  }

  Future<void> _syncInvoiceDelete(Map<String, dynamic> data) async {
    final serverId = data['invoice_id']?.toString() ??
        data['id']?.toString() ??
        data['server_id']?.toString();
    if (serverId == null || serverId.isEmpty) {
      throw const SyncException('Missing invoice id');
    }

    await _apiClient.delete('${ApiConstants.invoices}/$serverId');
    await _appDatabase.deleteInvoiceByServerId(serverId);
    await _appDatabase.deleteCustomerTransactionsByReference(
      referenceType: 'invoice',
      referenceId: serverId,
    );
  }

  Future<void> _syncStockItemCreate(Map<String, dynamic> data) async {
    final clientId = data['client_id']?.toString();
    final payload = Map<String, dynamic>.from(data)
      ..remove('client_id')
      ..remove('updated_at')
      ..remove('version')
      ..remove('business_id');

    final response = await _apiClient.post(
      ApiConstants.stockItems,
      data: payload,
    );

    final item = StockItemModel.fromJson(
      response.data as Map<String, dynamic>,
    );

    final companion = _stockItemCompanionFromModel(item);

    if (clientId != null) {
      final updated = await _appDatabase.updateStockItemByClientId(
        clientId: clientId,
        companion: companion,
      );
      if (updated == 0) {
        await _appDatabase.upsertStockItems([companion]);
      }
    } else {
      await _appDatabase.upsertStockItems([companion]);
    }
  }

  Future<void> _syncStockItemUpdate(Map<String, dynamic> data) async {
    final serverId = data['id']?.toString() ?? data['server_id']?.toString();
    if (serverId == null || serverId.isEmpty) {
      throw const SyncException('Missing server id for item update');
    }

    final payload = Map<String, dynamic>.from(data)
      ..remove('id')
      ..remove('server_id')
      ..remove('client_id')
      ..remove('updated_at')
      ..remove('version')
      ..remove('business_id');

    if (payload.isEmpty) {
      return;
    }

    final response = await _apiClient.patch(
      '${ApiConstants.stockItems}/$serverId',
      data: payload,
    );

    final item = StockItemModel.fromJson(
      response.data as Map<String, dynamic>,
    );

    await _appDatabase.upsertStockItems([
      _stockItemCompanionFromModel(item),
    ]);
  }

  Future<void> _syncInventoryTransactionCreate(
      Map<String, dynamic> data) async {
    final clientId = data['client_id']?.toString();
    final payload = await _mapInventoryTransactionPayload(
      Map<String, dynamic>.from(data),
    )
      ..remove('client_id')
      ..remove('updated_at')
      ..remove('version')
      ..remove('business_id');

    final response = await _apiClient.post(
      ApiConstants.stockTransactions,
      data: payload,
    );

    final transaction = InventoryTransactionModel.fromJson(
      response.data as Map<String, dynamic>,
    );

    final companion = InventoryTransactionsCompanion(
      serverId: Value(transaction.id),
      clientId: Value(clientId),
      itemId: Value(transaction.itemId),
      transactionType: Value(transaction.transactionType),
      quantity: Value(transaction.quantity),
      unitPrice: Value(transaction.unitPrice),
      date: Value(transaction.date),
      remarks: Value(transaction.remarks),
      createdAt: Value(transaction.createdAt ?? transaction.date),
      isSynced: const Value(true),
      syncStatus: const Value('synced'),
    );

    var updated = 0;
    if (clientId != null) {
      updated = await _appDatabase.updateInventoryTransactionByClientId(
        clientId: clientId,
        companion: companion,
      );
    }

    if (updated == 0) {
      await _appDatabase.upsertInventoryTransactions([companion]);
      await _applyLocalStockFromTransaction(
        itemId: transaction.itemId,
        transactionType: transaction.transactionType,
        quantity: transaction.quantity,
        markSynced: true,
      );
    } else {
      await _markStockItemSynced(transaction.itemId);
    }
  }

  Future<void> _syncSupplierCreate(Map<String, dynamic> data) async {
    final clientId = data['client_id']?.toString();
    final payload = Map<String, dynamic>.from(data)
      ..remove('client_id')
      ..remove('updated_at')
      ..remove('version')
      ..remove('business_id');

    final response = await _apiClient.post(
      ApiConstants.suppliers,
      data: payload,
    );

    final supplier = SupplierModel.fromJson(
      response.data as Map<String, dynamic>,
    );

    if (clientId != null) {
      await _applySupplierServerData(
        clientId: clientId,
        supplier: supplier,
      );
    } else {
      await _appDatabase.upsertSuppliers([
        _supplierCompanionFromModel(supplier),
      ]);
    }
  }

  Future<void> _applySupplierServerData({
    required String clientId,
    required SupplierModel supplier,
  }) async {
    final companion = _supplierCompanionFromModel(supplier).copyWith(
      clientId: Value(clientId),
      isSynced: const Value(true),
      syncStatus: const Value('synced'),
    );

    final updated = await _appDatabase.updateSupplierByClientId(
      clientId: clientId,
      companion: companion,
    );

    if (updated == 0) {
      await _appDatabase.upsertSuppliers([companion]);
    }

    await _appDatabase.updateSupplierTransactionsSupplierId(
      oldId: clientId,
      newId: supplier.id,
    );
  }

  Future<void> _syncSupplierTransactionCreate(
    Map<String, dynamic> data,
  ) async {
    final clientId = data['client_id']?.toString();
    final transactionType = data['transaction_type']?.toString();
    final payload = Map<String, dynamic>.from(data)
      ..remove('client_id')
      ..remove('updated_at')
      ..remove('version')
      ..remove('business_id');

    final rawSupplierId = payload['supplier_id']?.toString();
    if (rawSupplierId == null || rawSupplierId.isEmpty) {
      throw const SyncException('Missing supplier_id');
    }

    final supplierId = await _resolveSupplierServerId(rawSupplierId);
    payload['supplier_id'] = supplierId;

    final postData = <String, dynamic>{
      'amount': payload['amount'],
      'date': payload['date'],
      if (payload['remarks'] != null) 'remarks': payload['remarks'],
    };

    if (transactionType == 'purchase') {
      final items = payload['items'];
      if (items is List) {
        postData['items'] = await _mapSupplierPurchaseItems(items);
      }
    }

    final response = await _apiClient.post(
      transactionType == 'purchase'
          ? '${ApiConstants.suppliers}/$supplierId/purchases'
          : '${ApiConstants.suppliers}/$supplierId/payments',
      data: postData,
    );

    final responseMap = response.data as Map<String, dynamic>;
    final serverId =
        responseMap['id']?.toString() ?? responseMap['_id']?.toString();
    if (serverId == null || serverId.isEmpty) {
      throw const SyncException('Missing supplier transaction id');
    }

    final companion = SupplierTransactionsCompanion(
      serverId: Value(serverId),
      clientId: Value(clientId),
      supplierId: Value(supplierId),
      transactionType: Value(
        responseMap['transaction_type']?.toString() ?? transactionType ?? '',
      ),
      amount:
          Value(_normalizeAmount(responseMap['amount'] ?? payload['amount'])),
      date: Value(_parseDate(responseMap['date']) ?? DateTime.now()),
      referenceId: Value(responseMap['reference_id']?.toString()),
      referenceType: Value(responseMap['reference_type']?.toString()),
      remarks: Value(responseMap['remarks']?.toString()),
      createdAt: Value(_parseDate(responseMap['created_at'])),
      isSynced: const Value(true),
      syncStatus: const Value('synced'),
    );

    var updated = 0;
    if (clientId != null) {
      updated = await _appDatabase.updateSupplierTransactionByClientId(
        clientId: clientId,
        companion: companion,
      );
    }

    if (updated == 0) {
      await _appDatabase.upsertSupplierTransactions([companion]);
    }
  }

  Future<void> _syncExpenseCategoryCreate(Map<String, dynamic> data) async {
    final clientId = data['client_id']?.toString();
    final payload = Map<String, dynamic>.from(data)
      ..remove('client_id')
      ..remove('updated_at')
      ..remove('version')
      ..remove('business_id');

    final response = await _apiClient.post(
      ApiConstants.expenseCategories,
      data: payload,
    );

    final category = ExpenseCategoryModel.fromJson(
      response.data as Map<String, dynamic>,
    );

    if (clientId != null) {
      await _applyExpenseCategoryServerData(
        clientId: clientId,
        category: category,
      );
    } else {
      await _appDatabase.upsertExpenseCategories([
        _expenseCategoryCompanionFromModel(category),
      ]);
    }
  }

  Future<void> _applyExpenseCategoryServerData({
    required String clientId,
    required ExpenseCategoryModel category,
  }) async {
    final companion = _expenseCategoryCompanionFromModel(category).copyWith(
      clientId: Value(clientId),
      isSynced: const Value(true),
      syncStatus: const Value('synced'),
    );

    final updated = await _appDatabase.updateExpenseCategoryByClientId(
      clientId: clientId,
      companion: companion,
    );

    if (updated == 0) {
      await _appDatabase.upsertExpenseCategories([companion]);
    }

    await _appDatabase.updateExpensesCategoryId(
      oldId: clientId,
      newId: category.id,
    );
  }

  Future<void> _syncExpenseCreate(Map<String, dynamic> data) async {
    final clientId = data['client_id']?.toString();
    final payload = await _mapExpensePayload(Map<String, dynamic>.from(data))
      ..remove('client_id')
      ..remove('updated_at')
      ..remove('version')
      ..remove('business_id');

    final response = await _apiClient.post(
      ApiConstants.expenses,
      data: payload,
    );

    final expense = ExpenseModel.fromJson(
      response.data as Map<String, dynamic>,
    );

    final companion = _expenseCompanionFromModel(expense);

    if (clientId != null) {
      final updated = await _appDatabase.updateExpenseByClientId(
        clientId: clientId,
        companion: companion,
      );
      if (updated == 0) {
        await _appDatabase.upsertExpenses([companion]);
      }
    } else {
      await _appDatabase.upsertExpenses([companion]);
    }
  }

  Future<void> _syncCashTransactionCreate(Map<String, dynamic> data) async {
    final clientId = data['client_id']?.toString();
    final payload = Map<String, dynamic>.from(data)
      ..remove('client_id')
      ..remove('updated_at')
      ..remove('version')
      ..remove('business_id');

    final response = await _apiClient.post(
      ApiConstants.cashTransactions,
      data: payload,
    );

    final transaction = CashTransactionModel.fromJson(
      response.data as Map<String, dynamic>,
    );

    final companion = CashTransactionsCompanion(
      serverId: Value(transaction.id),
      clientId: Value(clientId),
      transactionType: Value(transaction.transactionType),
      amount: Value(transaction.amount),
      date: Value(transaction.date),
      source: Value(transaction.source),
      remarks: Value(transaction.remarks),
      createdAt: Value(transaction.createdAt),
      isSynced: const Value(true),
      syncStatus: const Value('synced'),
    );

    var updated = 0;
    if (clientId != null) {
      updated = await _appDatabase.updateCashTransactionByClientId(
        clientId: clientId,
        companion: companion,
      );
    }

    if (updated == 0) {
      await _appDatabase.upsertCashTransactions([companion]);
    }
  }

  Future<void> _syncBankAccountCreate(Map<String, dynamic> data) async {
    final clientId = data['client_id']?.toString();
    final payload = Map<String, dynamic>.from(data)
      ..remove('client_id')
      ..remove('updated_at')
      ..remove('version')
      ..remove('business_id');

    final response = await _apiClient.post(
      ApiConstants.bankAccounts,
      data: payload,
    );

    final account = BankAccountModel.fromJson(
      response.data as Map<String, dynamic>,
    );

    if (clientId != null) {
      await _applyBankAccountServerData(
        clientId: clientId,
        account: account,
      );
    } else {
      await _appDatabase.upsertBankAccounts([
        _bankAccountCompanionFromModel(account),
      ]);
    }
  }

  Future<void> _applyBankAccountServerData({
    required String clientId,
    required BankAccountModel account,
  }) async {
    final companion = _bankAccountCompanionFromModel(account).copyWith(
      clientId: Value(clientId),
      isSynced: const Value(true),
      syncStatus: const Value('synced'),
    );

    final updated = await _appDatabase.updateBankAccountByClientId(
      clientId: clientId,
      companion: companion,
    );

    if (updated == 0) {
      await _appDatabase.upsertBankAccounts([companion]);
    }

    await _appDatabase.updateBankTransactionsAccountId(
      oldId: clientId,
      newId: account.id,
    );
  }

  Future<void> _syncBankTransactionCreate(Map<String, dynamic> data) async {
    final clientId = data['client_id']?.toString();
    final payload = Map<String, dynamic>.from(data)
      ..remove('client_id')
      ..remove('updated_at')
      ..remove('version')
      ..remove('business_id');

    final accountId = payload['bank_account_id']?.toString();
    if (accountId == null || accountId.isEmpty) {
      throw const SyncException('Missing bank_account_id');
    }

    final resolvedAccountId = await _resolveBankAccountServerId(accountId);
    payload['bank_account_id'] = resolvedAccountId;

    final response = await _apiClient.post(
      ApiConstants.bankTransactions,
      data: payload,
    );

    final transaction = BankTransactionModel.fromJson(
      response.data as Map<String, dynamic>,
    );

    final companion = BankTransactionsCompanion(
      serverId: Value(transaction.id),
      clientId: Value(clientId),
      accountId: Value(transaction.accountId),
      transactionType: Value(transaction.transactionType),
      amount: Value(transaction.amount),
      date: Value(transaction.date),
      referenceNumber: Value(transaction.referenceNumber),
      remarks: Value(transaction.remarks),
      createdAt: Value(transaction.createdAt),
      isSynced: const Value(true),
      syncStatus: const Value('synced'),
    );

    var updated = 0;
    if (clientId != null) {
      updated = await _appDatabase.updateBankTransactionByClientId(
        clientId: clientId,
        companion: companion,
      );
    }

    if (updated == 0) {
      await _appDatabase.upsertBankTransactions([companion]);
    }

    await _markBankAccountSynced(transaction.accountId);
  }

  Future<void> _syncCashBankTransferCreate(Map<String, dynamic> data) async {
    final payload = Map<String, dynamic>.from(data)
      ..remove('client_id')
      ..remove('updated_at')
      ..remove('version')
      ..remove('business_id');

    final accountId = payload['bank_account_id']?.toString();
    if (accountId == null || accountId.isEmpty) {
      throw const SyncException('Missing bank_account_id');
    }

    final resolvedAccountId = await _resolveBankAccountServerId(accountId);
    payload['bank_account_id'] = resolvedAccountId;

    await _apiClient.post(
      ApiConstants.bankTransfers,
      data: payload,
    );

    await _markBankAccountSynced(resolvedAccountId);
  }

  Future<void> _syncStaffCreate(Map<String, dynamic> data) async {
    final clientId = data['client_id']?.toString();
    final payload = Map<String, dynamic>.from(data)
      ..remove('client_id')
      ..remove('updated_at')
      ..remove('version')
      ..remove('business_id');

    final response = await _apiClient.post(
      ApiConstants.staff,
      data: payload,
    );

    final staff = StaffModel.fromJson(
      response.data as Map<String, dynamic>,
    );

    if (clientId != null) {
      await _applyStaffServerData(
        clientId: clientId,
        staff: staff,
      );
    } else {
      await _appDatabase.upsertStaffs([
        _staffCompanionFromModel(staff),
      ]);
    }
  }

  Future<void> _applyStaffServerData({
    required String clientId,
    required StaffModel staff,
  }) async {
    final companion = _staffCompanionFromModel(staff).copyWith(
      clientId: Value(clientId),
      isSynced: const Value(true),
      syncStatus: const Value('synced'),
    );

    final updated = await _appDatabase.updateStaffByClientId(
      clientId: clientId,
      companion: companion,
    );

    if (updated == 0) {
      await _appDatabase.upsertStaffs([companion]);
    }

    await _appDatabase.updateStaffSalariesStaffId(
      oldId: clientId,
      newId: staff.id,
    );
  }

  Future<void> _syncStaffSalaryCreate(Map<String, dynamic> data) async {
    final clientId = data['client_id']?.toString();
    final payload = Map<String, dynamic>.from(data)
      ..remove('client_id')
      ..remove('updated_at')
      ..remove('version')
      ..remove('business_id');

    final staffId = payload['staff_id']?.toString();
    if (staffId == null || staffId.isEmpty) {
      throw const SyncException('Missing staff_id');
    }

    final resolvedStaffId = await _resolveStaffServerId(staffId);

    final response = await _apiClient.post(
      '${ApiConstants.staff}/$resolvedStaffId/salaries',
      data: {
        'staff_id': resolvedStaffId,
        'amount': payload['amount'],
        'date': payload['date'],
        if (payload['remarks'] != null) 'remarks': payload['remarks'],
        if (payload['payment_mode'] != null)
          'payment_mode': payload['payment_mode'],
      },
    );

    final responseMap = response.data as Map<String, dynamic>;
    final serverId =
        responseMap['id']?.toString() ?? responseMap['_id']?.toString();
    if (serverId == null || serverId.isEmpty) {
      throw const SyncException('Missing staff salary id');
    }

    final companion = StaffSalariesCompanion(
      serverId: Value(serverId),
      clientId: Value(clientId),
      staffId: Value(resolvedStaffId),
      amount:
          Value(_normalizeAmount(responseMap['amount'] ?? payload['amount'])),
      date: Value(_parseDate(responseMap['date']) ?? DateTime.now()),
      paymentMode: Value(responseMap['payment_mode']?.toString()),
      remarks: Value(responseMap['remarks']?.toString()),
      referenceId: Value(responseMap['reference_id']?.toString()),
      referenceType: Value(responseMap['reference_type']?.toString()),
      createdAt: Value(_parseDate(responseMap['created_at'])),
      isSynced: const Value(true),
      syncStatus: const Value('synced'),
    );

    var updated = 0;
    if (clientId != null) {
      updated = await _appDatabase.updateStaffSalaryByClientId(
        clientId: clientId,
        companion: companion,
      );
    }

    if (updated == 0) {
      await _appDatabase.upsertStaffSalaries([companion]);
    }
  }

  Future<void> _syncReminderCreate(Map<String, dynamic> data) async {
    final clientId = data['client_id']?.toString();
    final payload = Map<String, dynamic>.from(data)
      ..remove('client_id')
      ..remove('updated_at')
      ..remove('version')
      ..remove('entity_name')
      ..remove('entity_phone');

    final entityType = payload['entity_type']?.toString();
    final entityId = payload['entity_id']?.toString();
    if (entityType == null || entityId == null) {
      throw const SyncException('Missing reminder entity');
    }

    if (entityType == 'customer') {
      payload['entity_id'] = await _resolveCustomerServerId(entityId);
    } else if (entityType == 'supplier') {
      payload['entity_id'] = await _resolveSupplierServerId(entityId);
    }

    final response = await _apiClient.post(
      ApiConstants.reminders,
      data: payload,
    );

    final reminder = Map<String, dynamic>.from(response.data as Map);
    final serverId = reminder['id']?.toString();
    if (serverId == null || serverId.isEmpty) {
      throw const SyncException('Missing reminder id');
    }

    final companion = RemindersCompanion(
      serverId: Value(serverId),
      clientId: Value(clientId),
      entityType: Value(reminder['entity_type']?.toString() ?? entityType),
      entityId: Value(reminder['entity_id']?.toString() ??
          payload['entity_id']?.toString() ??
          ''),
      entityDisplayName: Value(reminder['entity_name']?.toString() ??
          data['entity_name']?.toString()),
      entityPhone: Value(reminder['entity_phone']?.toString() ??
          data['entity_phone']?.toString()),
      amount: Value(_normalizeAmount(reminder['amount'] ?? payload['amount'])),
      dueDate: Value(
          _parseDate(reminder['due_date']) ?? _parseDate(payload['due_date'])),
      message: Value(
          reminder['message']?.toString() ?? payload['message']?.toString()),
      isResolved: Value((reminder['is_resolved'] as bool?) ?? false),
      resolvedAt: Value(_parseDate(reminder['resolved_at'])),
      createdAt: Value(_parseDate(reminder['created_at']) ?? DateTime.now()),
      updatedAt: Value(_parseDate(reminder['updated_at'])),
      isSynced: const Value(true),
      syncStatus: const Value('synced'),
    );

    var updated = 0;
    if (clientId != null) {
      updated = await _appDatabase.updateReminderByClientId(
        clientId: clientId,
        companion: companion,
      );
    }

    if (updated == 0) {
      await _appDatabase.upsertReminders([companion]);
    }
  }

  Future<void> _syncReminderResolve(Map<String, dynamic> data) async {
    final serverId = data['id']?.toString() ?? data['server_id']?.toString();
    final clientId = data['client_id']?.toString();

    String? resolvedId = serverId;
    if ((resolvedId == null || resolvedId.isEmpty) && clientId != null) {
      final reminder = await _appDatabase.findReminderByAnyId(clientId);
      resolvedId = reminder?.serverId;
    }

    if (resolvedId == null || resolvedId.isEmpty) {
      throw const SyncException('Missing reminder id');
    }

    await _apiClient.post('${ApiConstants.reminders}/$resolvedId/resolve');

    final resolvedAt = _parseDate(data['resolved_at']) ?? DateTime.now();
    final companion = RemindersCompanion(
      isResolved: const Value(true),
      resolvedAt: Value(resolvedAt),
      updatedAt: Value(DateTime.now()),
      isSynced: const Value(true),
      syncStatus: const Value('synced'),
    );

    if (clientId != null) {
      final updated = await _appDatabase.updateReminderByClientId(
        clientId: clientId,
        companion: companion,
      );
      if (updated > 0) return;
    }

    await _appDatabase.updateReminderByServerId(
      serverId: resolvedId,
      companion: companion,
    );
  }

  Future<int> _applyPulledChanges(List<dynamic> changes) async {
    var applied = 0;
    for (final raw in changes) {
      if (raw is! Map<String, dynamic>) continue;
      final entityType = raw['entity_type']?.toString();
      final action = raw['action']?.toString();
      final entityId = raw['entity_id']?.toString();
      final data = (raw['data'] is Map)
          ? Map<String, dynamic>.from(raw['data'] as Map)
          : <String, dynamic>{};

      if (entityType == 'customer') {
        final didApply = await _applyCustomerChange(
          action: action,
          entityId: entityId,
          data: data,
        );
        if (didApply) {
          applied += 1;
        }
      }
      if (entityType == 'customer_transaction') {
        final didApply = await _applyCustomerTransactionChange(
          action: action,
          entityId: entityId,
          data: data,
        );
        if (didApply) {
          applied += 1;
        }
      }
      if (entityType == 'invoice') {
        final didApply = await _applyInvoiceChange(
          action: action,
          entityId: entityId,
          data: data,
        );
        if (didApply) {
          applied += 1;
        }
      }
      if (entityType == 'item') {
        final didApply = await _applyStockItemChange(
          action: action,
          entityId: entityId,
          data: data,
        );
        if (didApply) {
          applied += 1;
        }
      }
      if (entityType == 'inventory_transaction') {
        final didApply = await _applyInventoryTransactionChange(
          action: action,
          entityId: entityId,
          data: data,
        );
        if (didApply) {
          applied += 1;
        }
      }
      if (entityType == 'supplier') {
        final didApply = await _applySupplierChange(
          action: action,
          entityId: entityId,
          data: data,
        );
        if (didApply) {
          applied += 1;
        }
      }
      if (entityType == 'supplier_transaction') {
        final didApply = await _applySupplierTransactionChange(
          action: action,
          entityId: entityId,
          data: data,
        );
        if (didApply) {
          applied += 1;
        }
      }
      if (entityType == 'expense_category') {
        final didApply = await _applyExpenseCategoryChange(
          action: action,
          entityId: entityId,
          data: data,
        );
        if (didApply) {
          applied += 1;
        }
      }
      if (entityType == 'expense') {
        final didApply = await _applyExpenseChange(
          action: action,
          entityId: entityId,
          data: data,
        );
        if (didApply) {
          applied += 1;
        }
      }
      if (entityType == 'cash_transaction') {
        final didApply = await _applyCashTransactionChange(
          action: action,
          entityId: entityId,
          data: data,
        );
        if (didApply) {
          applied += 1;
        }
      }
      if (entityType == 'bank_account') {
        final didApply = await _applyBankAccountChange(
          action: action,
          entityId: entityId,
          data: data,
        );
        if (didApply) {
          applied += 1;
        }
      }
      if (entityType == 'bank_transaction') {
        final didApply = await _applyBankTransactionChange(
          action: action,
          entityId: entityId,
          data: data,
        );
        if (didApply) {
          applied += 1;
        }
      }
      if (entityType == 'staff') {
        final didApply = await _applyStaffChange(
          action: action,
          entityId: entityId,
          data: data,
        );
        if (didApply) {
          applied += 1;
        }
      }
      if (entityType == 'staff_salary') {
        final didApply = await _applyStaffSalaryChange(
          action: action,
          entityId: entityId,
          data: data,
        );
        if (didApply) {
          applied += 1;
        }
      }
      if (entityType == 'reminder') {
        final didApply = await _applyReminderChange(
          action: action,
          entityId: entityId,
          data: data,
        );
        if (didApply) {
          applied += 1;
        }
      }
    }
    return applied;
  }

  Future<bool> _applyCustomerChange({
    required String? action,
    required String? entityId,
    required Map<String, dynamic> data,
  }) async {
    final serverId = (data['id'] ?? entityId)?.toString();
    if (serverId == null) return false;

    if (action == 'delete') {
      final syncedUpdate = CustomersCompanion(
        isActive: const Value(false),
        isSynced: const Value(true),
        syncStatus: const Value('synced'),
        updatedAt: Value(DateTime.now()),
      );
      await _appDatabase.updateCustomerByServerId(
        serverId: serverId,
        companion: syncedUpdate,
      );
      return true;
    }

    if (action != 'create' && action != 'update') {
      return false;
    }

    final local = await _appDatabase.findCustomerByAnyId(serverId);
    if (local != null && local.isSynced == false) {
      // Preserve local pending changes
      return false;
    }

    final name = data['name']?.toString();
    if (name == null || name.trim().isEmpty) {
      return false;
    }

    final companion = CustomersCompanion(
      serverId: Value(serverId),
      name: Value(name),
      phone: Value(data['phone']?.toString()),
      email: Value(data['email']?.toString()),
      address: Value(data['address']?.toString()),
      isActive: Value((data['is_active'] as bool?) ?? true),
      balance: Value(data['balance']?.toString()),
      createdAt: Value(_parseDate(data['created_at']) ?? DateTime.now()),
      updatedAt: Value(_parseDate(data['updated_at']) ?? DateTime.now()),
      isSynced: const Value(true),
      syncStatus: const Value('synced'),
    );

    await _appDatabase.upsertCustomers([companion]);
    return true;
  }

  Future<bool> _applyCustomerTransactionChange({
    required String? action,
    required String? entityId,
    required Map<String, dynamic> data,
  }) async {
    final serverId = (data['id'] ?? entityId)?.toString();
    if (serverId == null) return false;

    if (action == 'delete') {
      await _appDatabase.deleteCustomerTransactionByServerId(serverId);
      return true;
    }

    if (action != 'create' && action != 'update') {
      return false;
    }

    final existing = await _appDatabase.findCustomerTransactionByServerId(
      serverId,
    );
    if (existing != null && existing.isSynced == false) {
      return false;
    }

    final customerId = data['customer_id']?.toString();
    if (customerId == null || customerId.isEmpty) {
      return false;
    }

    final transactionType = data['transaction_type']?.toString() ?? '';
    if (transactionType.isEmpty) {
      return false;
    }

    final companion = CustomerTransactionsCompanion(
      serverId: Value(serverId),
      customerId: Value(customerId),
      transactionType: Value(transactionType),
      amount: Value(_normalizeAmount(data['amount'])),
      date: Value(_parseDate(data['date']) ?? DateTime.now()),
      referenceId: Value(data['reference_id']?.toString()),
      referenceType: Value(data['reference_type']?.toString()),
      remarks: Value(data['remarks']?.toString()),
      createdAt: Value(_parseDate(data['created_at'])),
      isSynced: const Value(true),
      syncStatus: const Value('synced'),
    );

    await _appDatabase.upsertCustomerTransactions([companion]);
    return true;
  }

  Future<bool> _applyInvoiceChange({
    required String? action,
    required String? entityId,
    required Map<String, dynamic> data,
  }) async {
    final serverId = (data['id'] ?? entityId)?.toString();
    if (serverId == null) return false;

    final local = await _appDatabase.findInvoiceByServerId(serverId);
    if (local != null && local.isSynced == false) {
      return false;
    }

    if (action == 'delete') {
      await _appDatabase.deleteInvoiceByServerId(serverId);
      await _appDatabase.deleteCustomerTransactionsByReference(
        referenceType: 'invoice',
        referenceId: serverId,
      );
      return true;
    }

    if (action != 'create' && action != 'update') {
      return false;
    }

    final invoiceNumber = data['invoice_number']?.toString() ?? '';
    final invoiceType = data['invoice_type']?.toString() ?? 'cash';
    final date = _parseDate(data['date']) ?? DateTime.now();

    final companion = InvoicesCompanion(
      serverId: Value(serverId),
      invoiceNumber: Value(invoiceNumber),
      customerId: Value(data['customer_id']?.toString()),
      invoiceType: Value(invoiceType),
      date: Value(date),
      subtotal: Value(_normalizeAmount(data['subtotal'])),
      taxAmount: Value(_normalizeAmount(data['tax_amount'])),
      discountAmount: Value(_normalizeAmount(data['discount_amount'])),
      totalAmount: Value(_normalizeAmount(data['total_amount'])),
      paidAmount: Value(_normalizeAmount(data['paid_amount'])),
      remarks: Value(data['remarks']?.toString()),
      pdfPath: Value(data['pdf_path']?.toString()),
      createdAt: Value(_parseDate(data['created_at'])),
      updatedAt: Value(_parseDate(data['updated_at'])),
      isSynced: const Value(true),
      syncStatus: const Value('synced'),
    );

    await _appDatabase.upsertInvoices([companion]);

    final itemsRaw = data['items'];
    if (itemsRaw is List) {
      final items = itemsRaw
          .whereType<Map>()
          .map((item) => InvoiceItemModel.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList();
      if (items.isNotEmpty) {
        await _appDatabase.replaceInvoiceItems(
          invoiceServerId: serverId,
          entries: _invoiceItemsCompanions(serverId, items),
        );
      }
    }

    if (invoiceType == 'credit' &&
        (data['customer_id']?.toString().isNotEmpty ?? false)) {
      await _appDatabase.upsertCustomerTransactions([
        CustomerTransactionsCompanion(
          serverId: Value(serverId),
          customerId: Value(data['customer_id']!.toString()),
          transactionType: const Value('credit'),
          amount: Value(_normalizeAmount(data['total_amount'])),
          date: Value(date),
          referenceId: Value(serverId),
          referenceType: const Value('invoice'),
          remarks: Value(data['remarks']?.toString()),
          createdAt: Value(_parseDate(data['created_at'])),
          isSynced: const Value(true),
          syncStatus: const Value('synced'),
        ),
      ]);
    }

    return true;
  }

  Future<bool> _applyStockItemChange({
    required String? action,
    required String? entityId,
    required Map<String, dynamic> data,
  }) async {
    final serverId = (data['id'] ?? entityId)?.toString();
    if (serverId == null) return false;

    final local = await _appDatabase.findStockItemByAnyId(serverId);
    if (local != null && local.isSynced == false) {
      return false;
    }

    if (action == 'delete') {
      final companion = StockItemsCompanion(
        isActive: const Value(false),
        isSynced: const Value(true),
        syncStatus: const Value('synced'),
        updatedAt: Value(DateTime.now()),
      );
      await _appDatabase.updateStockItemByServerId(
        serverId: serverId,
        companion: companion,
      );
      return true;
    }

    if (action != 'create' && action != 'update') {
      return false;
    }

    final name = data['name']?.toString();
    if (name == null || name.trim().isEmpty) {
      return false;
    }

    final companion = StockItemsCompanion(
      serverId: Value(serverId),
      name: Value(name),
      purchasePrice: Value(_normalizeAmount(data['purchase_price'])),
      salePrice: Value(_normalizeAmount(data['sale_price'])),
      unit: Value(data['unit']?.toString() ?? 'pcs'),
      currentStock: Value(_normalizeAmount(data['current_stock'])),
      description: Value(data['description']?.toString()),
      isActive: Value((data['is_active'] as bool?) ?? true),
      createdAt: Value(_parseDate(data['created_at'])),
      updatedAt: Value(_parseDate(data['updated_at'])),
      isSynced: const Value(true),
      syncStatus: const Value('synced'),
    );

    await _appDatabase.upsertStockItems([companion]);
    return true;
  }

  Future<bool> _applyInventoryTransactionChange({
    required String? action,
    required String? entityId,
    required Map<String, dynamic> data,
  }) async {
    final serverId = (data['id'] ?? entityId)?.toString();
    if (serverId == null) return false;

    if (action == 'delete') {
      return true;
    }

    if (action != 'create' && action != 'update') {
      return false;
    }

    final existing =
        await _appDatabase.findInventoryTransactionByServerId(serverId);
    if (existing != null) {
      return false;
    }

    final itemId = data['item_id']?.toString() ?? '';
    if (itemId.isEmpty) return false;

    final companion = InventoryTransactionsCompanion(
      serverId: Value(serverId),
      itemId: Value(itemId),
      transactionType: Value(data['transaction_type']?.toString() ?? ''),
      quantity: Value(_normalizeAmount(data['quantity'])),
      unitPrice: Value(data['unit_price']?.toString()),
      date: Value(_parseDate(data['date']) ?? DateTime.now()),
      referenceId: Value(data['reference_id']?.toString()),
      referenceType: Value(data['reference_type']?.toString()),
      remarks: Value(data['remarks']?.toString()),
      createdAt: Value(_parseDate(data['created_at'])),
      isSynced: const Value(true),
      syncStatus: const Value('synced'),
    );

    await _appDatabase.upsertInventoryTransactions([companion]);

    await _applyLocalStockFromTransaction(
      itemId: itemId,
      transactionType: data['transaction_type']?.toString() ?? '',
      quantity: _normalizeAmount(data['quantity']),
      markSynced: true,
      skipIfPending: true,
    );

    return true;
  }

  Future<bool> _applySupplierChange({
    required String? action,
    required String? entityId,
    required Map<String, dynamic> data,
  }) async {
    final serverId = (data['id'] ?? entityId)?.toString();
    if (serverId == null) return false;

    if (action == 'delete') {
      final companion = SuppliersCompanion(
        isActive: const Value(false),
        isSynced: const Value(true),
        syncStatus: const Value('synced'),
        updatedAt: Value(DateTime.now()),
      );
      await _appDatabase.updateSupplierByServerId(
        serverId: serverId,
        companion: companion,
      );
      return true;
    }

    if (action != 'create' && action != 'update') {
      return false;
    }

    final local = await _appDatabase.findSupplierByAnyId(serverId);
    if (local != null && local.isSynced == false) {
      return false;
    }

    final name = data['name']?.toString();
    if (name == null || name.trim().isEmpty) {
      return false;
    }

    final companion = SuppliersCompanion(
      serverId: Value(serverId),
      name: Value(name),
      phone: Value(data['phone']?.toString()),
      email: Value(data['email']?.toString()),
      address: Value(data['address']?.toString()),
      isActive: Value((data['is_active'] as bool?) ?? true),
      balance: Value(data['balance']?.toString()),
      createdAt: Value(_parseDate(data['created_at'])),
      updatedAt: Value(_parseDate(data['updated_at'])),
      isSynced: const Value(true),
      syncStatus: const Value('synced'),
    );

    await _appDatabase.upsertSuppliers([companion]);
    return true;
  }

  Future<bool> _applySupplierTransactionChange({
    required String? action,
    required String? entityId,
    required Map<String, dynamic> data,
  }) async {
    final serverId = (data['id'] ?? entityId)?.toString();
    if (serverId == null) return false;

    if (action == 'delete') {
      return true;
    }

    if (action != 'create' && action != 'update') {
      return false;
    }

    final existing =
        await _appDatabase.findSupplierTransactionByServerId(serverId);
    if (existing != null) {
      return false;
    }

    final supplierId = data['supplier_id']?.toString();
    if (supplierId == null || supplierId.isEmpty) return false;

    final companion = SupplierTransactionsCompanion(
      serverId: Value(serverId),
      supplierId: Value(supplierId),
      transactionType: Value(data['transaction_type']?.toString() ?? ''),
      amount: Value(_normalizeAmount(data['amount'])),
      date: Value(_parseDate(data['date']) ?? DateTime.now()),
      referenceId: Value(data['reference_id']?.toString()),
      referenceType: Value(data['reference_type']?.toString()),
      remarks: Value(data['remarks']?.toString()),
      createdAt: Value(_parseDate(data['created_at'])),
      isSynced: const Value(true),
      syncStatus: const Value('synced'),
    );

    await _appDatabase.upsertSupplierTransactions([companion]);
    return true;
  }

  Future<bool> _applyExpenseCategoryChange({
    required String? action,
    required String? entityId,
    required Map<String, dynamic> data,
  }) async {
    final serverId = (data['id'] ?? entityId)?.toString();
    if (serverId == null) return false;

    if (action == 'delete') {
      final companion = ExpenseCategoriesCompanion(
        isActive: const Value(false),
        isSynced: const Value(true),
        syncStatus: const Value('synced'),
        updatedAt: Value(DateTime.now()),
      );
      await _appDatabase.updateExpenseCategoryByServerId(
        serverId: serverId,
        companion: companion,
      );
      return true;
    }

    if (action != 'create' && action != 'update') {
      return false;
    }

    final local = await _appDatabase.findExpenseCategoryByAnyId(serverId);
    if (local != null && local.isSynced == false) {
      return false;
    }

    final name = data['name']?.toString();
    if (name == null || name.trim().isEmpty) {
      return false;
    }

    final companion = ExpenseCategoriesCompanion(
      serverId: Value(serverId),
      name: Value(name),
      description: Value(data['description']?.toString()),
      isActive: Value((data['is_active'] as bool?) ?? true),
      createdAt: Value(_parseDate(data['created_at'])),
      updatedAt: Value(_parseDate(data['updated_at'])),
      isSynced: const Value(true),
      syncStatus: const Value('synced'),
    );

    await _appDatabase.upsertExpenseCategories([companion]);
    return true;
  }

  Future<bool> _applyExpenseChange({
    required String? action,
    required String? entityId,
    required Map<String, dynamic> data,
  }) async {
    final serverId = (data['id'] ?? entityId)?.toString();
    if (serverId == null) return false;

    if (action == 'delete') {
      return true;
    }

    if (action != 'create' && action != 'update') {
      return false;
    }

    final local = await _appDatabase.findExpenseByServerId(serverId);
    if (local != null && local.isSynced == false) {
      return false;
    }

    final amount = data['amount'];
    if (amount == null) return false;

    final categoryId = data['category_id']?.toString() ?? '';

    final companion = ExpensesCompanion(
      serverId: Value(serverId),
      categoryId: Value(categoryId),
      amount: Value(_normalizeAmount(amount)),
      date: Value(_parseDate(data['date']) ?? DateTime.now()),
      paymentMode: Value(data['payment_mode']?.toString() ?? 'cash'),
      description: Value(data['description']?.toString()),
      createdAt: Value(_parseDate(data['created_at'])),
      isSynced: const Value(true),
      syncStatus: const Value('synced'),
    );

    await _appDatabase.upsertExpenses([companion]);
    return true;
  }

  Future<bool> _applyCashTransactionChange({
    required String? action,
    required String? entityId,
    required Map<String, dynamic> data,
  }) async {
    final serverId = (data['id'] ?? entityId)?.toString();
    if (serverId == null) return false;

    if (action == 'delete') {
      return true;
    }

    if (action != 'create' && action != 'update') {
      return false;
    }

    final existing = await _appDatabase.findCashTransactionByServerId(
      serverId,
    );
    if (existing != null) {
      return false;
    }

    final transactionType = data['transaction_type']?.toString();
    final amount = data['amount'];
    if (transactionType == null || amount == null) {
      return false;
    }

    final parsedDate = _parseDate(data['date']) ?? DateTime.now();
    final source = data['source']?.toString();
    final referenceType = data['reference_type']?.toString();
    final referenceId = data['reference_id']?.toString();

    final shouldReconcile = source == 'bank_transfer' ||
        referenceType == 'bank_transfer' ||
        source == 'salary' ||
        referenceType == 'salary';
    if (shouldReconcile) {
      final pendingMatches = await _appDatabase.fetchPendingCashTransactions(
        date: parsedDate,
        transactionType: transactionType,
        source: source,
        referenceType: referenceType,
        referenceId: referenceId,
      );

      final normalizedAmount = _amountToDouble(amount);
      final serverRemarks = data['remarks']?.toString();
      CashTransaction? match;
      for (final txn in pendingMatches) {
        final remarksMatch =
            serverRemarks == null || serverRemarks == txn.remarks;
        if (_amountsMatch(txn.amount, normalizedAmount) && remarksMatch) {
          match = txn;
          break;
        }
      }

      if (match != null && match.clientId != null) {
        await _appDatabase.updateCashTransactionByClientId(
          clientId: match.clientId!,
          companion: CashTransactionsCompanion(
            serverId: Value(serverId),
            transactionType: Value(transactionType),
            amount: Value(_normalizeAmount(amount)),
            date: Value(parsedDate),
            source: Value(source),
            remarks: Value(data['remarks']?.toString()),
            referenceId: Value(referenceId),
            referenceType: Value(referenceType),
            createdAt: Value(_parseDate(data['created_at'])),
            isSynced: const Value(true),
            syncStatus: const Value('synced'),
          ),
        );
        return true;
      }
    }

    final companion = CashTransactionsCompanion(
      serverId: Value(serverId),
      transactionType: Value(transactionType),
      amount: Value(_normalizeAmount(amount)),
      date: Value(parsedDate),
      source: Value(source),
      remarks: Value(data['remarks']?.toString()),
      referenceId: Value(referenceId),
      referenceType: Value(referenceType),
      createdAt: Value(_parseDate(data['created_at'])),
      isSynced: const Value(true),
      syncStatus: const Value('synced'),
    );

    await _appDatabase.upsertCashTransactions([companion]);
    return true;
  }

  Future<bool> _applyBankAccountChange({
    required String? action,
    required String? entityId,
    required Map<String, dynamic> data,
  }) async {
    final serverId = (data['id'] ?? entityId)?.toString();
    if (serverId == null) return false;

    if (action == 'delete') {
      final companion = BankAccountsCompanion(
        isActive: const Value(false),
        isSynced: const Value(true),
        syncStatus: const Value('synced'),
        updatedAt: Value(DateTime.now()),
      );
      await _appDatabase.updateBankAccountByServerId(
        serverId: serverId,
        companion: companion,
      );
      return true;
    }

    if (action != 'create' && action != 'update') {
      return false;
    }

    final local = await _appDatabase.findBankAccountByAnyId(serverId);
    if (local != null && local.isSynced == false) {
      return false;
    }

    final bankName = data['bank_name']?.toString();
    final accountNumber = data['account_number']?.toString();
    if (bankName == null || bankName.trim().isEmpty || accountNumber == null) {
      return false;
    }

    final companion = BankAccountsCompanion(
      serverId: Value(serverId),
      bankName: Value(bankName),
      accountNumber: Value(accountNumber),
      accountHolderName: Value(data['account_holder_name']?.toString()),
      branch: Value(data['branch']?.toString()),
      ifscCode: Value(data['ifsc_code']?.toString()),
      accountType: Value(data['account_type']?.toString()),
      openingBalance: Value(_normalizeAmount(data['opening_balance'])),
      currentBalance: Value(_normalizeAmount(data['current_balance'])),
      isActive: Value((data['is_active'] as bool?) ?? true),
      createdAt: Value(_parseDate(data['created_at'])),
      updatedAt: Value(_parseDate(data['updated_at'])),
      isSynced: const Value(true),
      syncStatus: const Value('synced'),
    );

    await _appDatabase.upsertBankAccounts([companion]);
    return true;
  }

  Future<bool> _applyBankTransactionChange({
    required String? action,
    required String? entityId,
    required Map<String, dynamic> data,
  }) async {
    final serverId = (data['id'] ?? entityId)?.toString();
    if (serverId == null) return false;

    if (action == 'delete') {
      return true;
    }

    if (action != 'create' && action != 'update') {
      return false;
    }

    final existing = await _appDatabase.findBankTransactionByServerId(serverId);
    if (existing != null) {
      return false;
    }

    final accountId = data['bank_account_id']?.toString();
    if (accountId == null || accountId.isEmpty) return false;

    final transactionType = data['transaction_type']?.toString() ?? '';
    final amount = data['amount'];
    if (amount == null) return false;

    final parsedDate = _parseDate(data['date']) ?? DateTime.now();
    final serverRemarks = data['remarks']?.toString();

    final pendingMatches = await _appDatabase.fetchPendingBankTransactions(
      date: parsedDate,
      transactionType: transactionType,
      accountId: accountId,
    );

    final normalizedAmount = _amountToDouble(amount);
    BankTransaction? match;
    for (final txn in pendingMatches) {
      final remarksMatch =
          serverRemarks == null || serverRemarks == txn.remarks;
      if (_amountsMatch(txn.amount, normalizedAmount) && remarksMatch) {
        match = txn;
        break;
      }
    }

    if (match != null && match.clientId != null) {
      await _appDatabase.updateBankTransactionByClientId(
        clientId: match.clientId!,
        companion: BankTransactionsCompanion(
          serverId: Value(serverId),
          accountId: Value(accountId),
          transactionType: Value(transactionType),
          amount: Value(_normalizeAmount(amount)),
          date: Value(parsedDate),
          referenceNumber: Value(data['reference_number']?.toString()),
          remarks: Value(serverRemarks),
          createdAt: Value(_parseDate(data['created_at'])),
          isSynced: const Value(true),
          syncStatus: const Value('synced'),
        ),
      );
      return true;
    }

    final companion = BankTransactionsCompanion(
      serverId: Value(serverId),
      accountId: Value(accountId),
      transactionType: Value(transactionType),
      amount: Value(_normalizeAmount(amount)),
      date: Value(parsedDate),
      referenceNumber: Value(data['reference_number']?.toString()),
      remarks: Value(serverRemarks),
      createdAt: Value(_parseDate(data['created_at'])),
      isSynced: const Value(true),
      syncStatus: const Value('synced'),
    );

    await _appDatabase.upsertBankTransactions([companion]);
    return true;
  }

  Future<bool> _applyStaffChange({
    required String? action,
    required String? entityId,
    required Map<String, dynamic> data,
  }) async {
    final serverId = (data['id'] ?? entityId)?.toString();
    if (serverId == null) return false;

    if (action == 'delete') {
      final companion = StaffsCompanion(
        isActive: const Value(false),
        isSynced: const Value(true),
        syncStatus: const Value('synced'),
        updatedAt: Value(DateTime.now()),
      );
      await _appDatabase.updateStaffByServerId(
        serverId: serverId,
        companion: companion,
      );
      return true;
    }

    if (action != 'create' && action != 'update') {
      return false;
    }

    final local = await _appDatabase.findStaffByAnyId(serverId);
    if (local != null && local.isSynced == false) {
      return false;
    }

    final name = data['name']?.toString();
    if (name == null || name.trim().isEmpty) {
      return false;
    }

    final companion = StaffsCompanion(
      serverId: Value(serverId),
      name: Value(name),
      phone: Value(data['phone']?.toString()),
      email: Value(data['email']?.toString()),
      role: Value(data['role']?.toString()),
      address: Value(data['address']?.toString()),
      isActive: Value((data['is_active'] as bool?) ?? true),
      createdAt: Value(_parseDate(data['created_at'])),
      updatedAt: Value(_parseDate(data['updated_at'])),
      isSynced: const Value(true),
      syncStatus: const Value('synced'),
    );

    await _appDatabase.upsertStaffs([companion]);
    return true;
  }

  Future<bool> _applyStaffSalaryChange({
    required String? action,
    required String? entityId,
    required Map<String, dynamic> data,
  }) async {
    final serverId = (data['id'] ?? entityId)?.toString();
    if (serverId == null) return false;

    if (action == 'delete') {
      return true;
    }

    if (action != 'create' && action != 'update') {
      return false;
    }

    final existing = await _appDatabase.findStaffSalaryByServerId(serverId);
    if (existing != null) {
      return false;
    }

    final staffId = data['staff_id']?.toString();
    if (staffId == null || staffId.isEmpty) return false;

    final companion = StaffSalariesCompanion(
      serverId: Value(serverId),
      staffId: Value(staffId),
      amount: Value(_normalizeAmount(data['amount'])),
      date: Value(_parseDate(data['date']) ?? DateTime.now()),
      paymentMode: Value(data['payment_mode']?.toString()),
      remarks: Value(data['remarks']?.toString()),
      referenceId: Value(data['reference_id']?.toString()),
      referenceType: Value(data['reference_type']?.toString()),
      createdAt: Value(_parseDate(data['created_at'])),
      isSynced: const Value(true),
      syncStatus: const Value('synced'),
    );

    await _appDatabase.upsertStaffSalaries([companion]);
    return true;
  }

  Future<bool> _applyReminderChange({
    required String? action,
    required String? entityId,
    required Map<String, dynamic> data,
  }) async {
    final serverId = (data['id'] ?? entityId)?.toString();
    if (serverId == null) return false;

    if (action == 'delete') {
      return true;
    }

    if (action != 'create' && action != 'update') {
      return false;
    }

    final companion = RemindersCompanion(
      serverId: Value(serverId),
      entityType: Value(data['entity_type']?.toString() ?? ''),
      entityId: Value(data['entity_id']?.toString() ?? ''),
      entityDisplayName: Value(data['entity_name']?.toString()),
      entityPhone: Value(data['entity_phone']?.toString()),
      amount: Value(_normalizeAmount(data['amount'])),
      dueDate: Value(_parseDate(data['due_date'])),
      message: Value(data['message']?.toString()),
      isResolved: Value((data['is_resolved'] as bool?) ?? false),
      resolvedAt: Value(_parseDate(data['resolved_at'])),
      createdAt: Value(_parseDate(data['created_at'])),
      updatedAt: Value(_parseDate(data['updated_at'])),
      isSynced: const Value(true),
      syncStatus: const Value('synced'),
    );

    await _appDatabase.upsertReminders([companion]);
    return true;
  }

  InvoicesCompanion _invoiceCompanionFromModel(InvoiceModel model) {
    return InvoicesCompanion(
      serverId: Value(model.id),
      invoiceNumber: Value(model.invoiceNumber),
      customerId: Value(model.customerId),
      invoiceType: Value(model.invoiceType),
      date: Value(model.date),
      subtotal: Value(model.subtotal),
      taxAmount: Value(model.taxAmount),
      discountAmount: Value(model.discountAmount),
      totalAmount: Value(model.totalAmount),
      paidAmount: Value(model.paidAmount),
      remarks: Value(model.remarks),
      pdfPath: Value(model.pdfPath),
      createdAt: Value(model.createdAt),
      updatedAt: Value(DateTime.now()),
      isSynced: const Value(true),
      syncStatus: const Value('synced'),
    );
  }

  List<InvoiceItemsCompanion> _invoiceItemsCompanions(
    String invoiceServerId,
    List<InvoiceItemModel> items,
  ) {
    return items
        .map(
          (item) => InvoiceItemsCompanion(
            serverId: Value(item.id.isEmpty ? null : item.id),
            invoiceServerId: Value(invoiceServerId),
            itemId: Value(item.itemId),
            itemName: Value(item.itemName),
            quantity: Value(item.quantity),
            unitPrice: Value(item.unitPrice),
            totalPrice: Value(item.totalPrice),
          ),
        )
        .toList();
  }

  StockItemsCompanion _stockItemCompanionFromModel(StockItemModel model) {
    return StockItemsCompanion(
      serverId: Value(model.id),
      name: Value(model.name),
      purchasePrice: Value(model.purchasePrice),
      salePrice: Value(model.salePrice),
      unit: Value(model.unit),
      currentStock: Value(model.currentStock),
      description: Value(model.description),
      isActive: Value(model.isActive ?? true),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
      isSynced: const Value(true),
      syncStatus: const Value('synced'),
    );
  }

  ExpenseCategoriesCompanion _expenseCategoryCompanionFromModel(
    ExpenseCategoryModel model,
  ) {
    return ExpenseCategoriesCompanion(
      serverId: Value(model.id),
      name: Value(model.name),
      description: Value(model.description),
      isActive: Value(model.isActive ?? true),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
      isSynced: const Value(true),
      syncStatus: const Value('synced'),
    );
  }

  ExpensesCompanion _expenseCompanionFromModel(ExpenseModel model) {
    return ExpensesCompanion(
      serverId: Value(model.id),
      categoryId: Value(model.categoryId),
      amount: Value(model.amount),
      date: Value(model.date),
      paymentMode: Value(model.paymentMode),
      description: Value(model.description),
      createdAt: Value(model.createdAt),
      isSynced: const Value(true),
      syncStatus: const Value('synced'),
    );
  }

  BankAccountsCompanion _bankAccountCompanionFromModel(
    BankAccountModel model,
  ) {
    return BankAccountsCompanion(
      serverId: Value(model.id),
      bankName: Value(model.bankName),
      accountNumber: Value(model.accountNumber),
      accountHolderName: Value(model.accountHolderName),
      branch: Value(model.branch),
      ifscCode: Value(model.ifscCode),
      accountType: Value(model.accountType),
      openingBalance: Value(model.openingBalance),
      currentBalance: Value(model.currentBalance),
      isActive: Value(model.isActive ?? true),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
      isSynced: const Value(true),
      syncStatus: const Value('synced'),
    );
  }

  StaffsCompanion _staffCompanionFromModel(StaffModel model) {
    return StaffsCompanion(
      serverId: Value(model.id),
      name: Value(model.name),
      phone: Value(model.phone),
      email: Value(model.email),
      role: Value(model.role),
      address: Value(model.address),
      isActive: Value(model.isActive ?? true),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
      isSynced: const Value(true),
      syncStatus: const Value('synced'),
    );
  }

  SuppliersCompanion _supplierCompanionFromModel(SupplierModel model) {
    return SuppliersCompanion(
      serverId: Value(model.id),
      name: Value(model.name),
      phone: Value(model.phone),
      email: Value(model.email),
      address: Value(model.address),
      isActive: Value(model.isActive ?? true),
      balance: Value(model.balance),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
      isSynced: const Value(true),
      syncStatus: const Value('synced'),
    );
  }

  Future<Map<String, dynamic>> _mapInventoryTransactionPayload(
    Map<String, dynamic> data,
  ) async {
    final payload = Map<String, dynamic>.from(data);
    final itemId = payload['item_id']?.toString();
    if (itemId == null || itemId.isEmpty) {
      throw const SyncException('Missing item_id');
    }

    final localItem = await _appDatabase.findStockItemByAnyId(itemId);
    if (localItem != null) {
      if (localItem.serverId != null) {
        payload['item_id'] = localItem.serverId;
      } else {
        throw const SyncException('Dependent item not synced');
      }
    }

    return payload;
  }

  Future<Map<String, dynamic>> _mapInvoicePayload(
    Map<String, dynamic> data,
  ) async {
    final payload = Map<String, dynamic>.from(data);
    final customerId = payload['customer_id']?.toString();
    if (customerId != null && customerId.isNotEmpty) {
      payload['customer_id'] = await _resolveCustomerServerId(customerId);
    }
    final items = payload['items'];
    if (items is List) {
      final mapped = <Map<String, dynamic>>[];
      for (final item in items) {
        if (item is! Map) continue;
        final itemMap = Map<String, dynamic>.from(item);
        final itemId = itemMap['item_id']?.toString();
        if (itemId != null) {
          final localItem = await _appDatabase.findStockItemByAnyId(itemId);
          if (localItem != null && localItem.serverId != null) {
            itemMap['item_id'] = localItem.serverId;
          } else if (localItem != null && localItem.serverId == null) {
            itemMap.remove('item_id');
          }
        }
        mapped.add(itemMap);
      }
      payload['items'] = mapped;
    }
    return payload;
  }

  Future<Map<String, dynamic>> _mapExpensePayload(
    Map<String, dynamic> data,
  ) async {
    final payload = Map<String, dynamic>.from(data);
    final categoryId = payload['category_id']?.toString();
    if (categoryId != null && categoryId.isNotEmpty) {
      final localCategory = await _appDatabase.findExpenseCategoryByAnyId(
        categoryId,
      );
      if (localCategory != null) {
        if (localCategory.serverId != null) {
          payload['category_id'] = localCategory.serverId;
        } else {
          throw const SyncException('Dependent category not synced');
        }
      }
    }
    return payload;
  }

  Future<String> _resolveBankAccountServerId(String accountId) async {
    final localAccount = await _appDatabase.findBankAccountByAnyId(accountId);
    if (localAccount != null) {
      if (localAccount.serverId != null) {
        return localAccount.serverId!;
      }
      throw const SyncException('Dependent bank account not synced');
    }
    return accountId;
  }

  Future<String> _resolveStaffServerId(String staffId) async {
    final localStaff = await _appDatabase.findStaffByAnyId(staffId);
    if (localStaff != null) {
      if (localStaff.serverId != null) {
        return localStaff.serverId!;
      }
      throw const SyncException('Dependent staff not synced');
    }
    return staffId;
  }

  Future<void> _saveScopedSyncCursor(String cursor) async {
    await _secureStorage.saveSyncCursor(cursor);
    final scope = await _getSyncScope();
    if (scope == null) return;
    await _secureStorage.saveScopedSyncCursor(
      userId: scope.userId,
      businessId: scope.businessId,
      cursor: cursor,
    );
  }

  Future<void> _saveScopedLastSyncAt(String isoTimestamp) async {
    await _localStorage.saveLastSyncAt(isoTimestamp);
    final scope = await _getSyncScope();
    if (scope == null) return;
    await _localStorage.saveString(
      '${StorageConstants.lastSyncAtScopedPrefix}_${scope.userId}_${scope.businessId}',
      isoTimestamp,
    );
  }

  Future<_SyncScope?> _getSyncScope() async {
    final userId = _localStorage.getUserId();
    final businessId = await _secureStorage.getBusinessId();
    if (userId == null ||
        userId.isEmpty ||
        businessId == null ||
        businessId.isEmpty) {
      return null;
    }
    return _SyncScope(userId: userId, businessId: businessId);
  }

  double _amountToDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  bool _amountsMatch(String? storedAmount, double incomingAmount) {
    final stored = double.tryParse(storedAmount ?? '') ?? 0;
    return (stored - incomingAmount).abs() < 0.01;
  }

  Future<void> _markBankAccountSynced(String accountId) async {
    final account = await _appDatabase.findBankAccountByAnyId(accountId);
    if (account == null) return;

    final companion = BankAccountsCompanion(
      isSynced: const Value(true),
      syncStatus: const Value('synced'),
      updatedAt: Value(DateTime.now()),
    );

    if (account.serverId != null) {
      await _appDatabase.updateBankAccountByServerId(
        serverId: account.serverId!,
        companion: companion,
      );
    } else if (account.clientId != null) {
      await _appDatabase.updateBankAccountByClientId(
        clientId: account.clientId!,
        companion: companion,
      );
    }
  }

  Future<String> _resolveSupplierServerId(String supplierId) async {
    final localSupplier = await _appDatabase.findSupplierByAnyId(supplierId);
    if (localSupplier != null) {
      if (localSupplier.serverId != null) {
        return localSupplier.serverId!;
      }
      throw const SyncException('Dependent supplier not synced');
    }
    return supplierId;
  }

  Future<String> _resolveCustomerServerId(String customerId) async {
    final localCustomer = await _appDatabase.findCustomerByAnyId(customerId);
    if (localCustomer != null) {
      if (localCustomer.serverId != null) {
        return localCustomer.serverId!;
      }
      throw const SyncException('Dependent customer not synced');
    }
    return customerId;
  }

  Future<List<Map<String, dynamic>>> _mapSupplierPurchaseItems(
    List items,
  ) async {
    final mapped = <Map<String, dynamic>>[];
    for (final raw in items) {
      if (raw is! Map) continue;
      final itemMap = Map<String, dynamic>.from(raw);
      final itemId = itemMap['item_id']?.toString();
      if (itemId != null && itemId.isNotEmpty) {
        final localItem = await _appDatabase.findStockItemByAnyId(itemId);
        if (localItem != null) {
          if (localItem.serverId != null) {
            itemMap['item_id'] = localItem.serverId;
          } else {
            throw const SyncException('Dependent item not synced');
          }
        }
      }
      mapped.add(itemMap);
    }
    return mapped;
  }

  Future<void> _applyLocalStockFromTransaction({
    required String itemId,
    required String transactionType,
    required String quantity,
    required bool markSynced,
    bool skipIfPending = false,
  }) async {
    final item = await _appDatabase.findStockItemByAnyId(itemId);
    if (item == null) return;
    if (skipIfPending && item.isSynced == false) return;

    final current = _toDouble(item.currentStock);
    final qty = _toDouble(quantity);
    final next = _computeNextStock(
      current: current,
      transactionType: transactionType,
      quantity: qty,
    );

    final companion = StockItemsCompanion(
      currentStock: Value(_formatAmount(next)),
      updatedAt: Value(DateTime.now()),
      isSynced: Value(markSynced),
      syncStatus: Value(markSynced ? 'synced' : 'pending'),
    );

    if (item.serverId != null) {
      await _appDatabase.updateStockItemByServerId(
        serverId: item.serverId!,
        companion: companion,
      );
    } else if (item.clientId != null) {
      await _appDatabase.updateStockItemByClientId(
        clientId: item.clientId!,
        companion: companion,
      );
    }
  }

  Future<void> _markStockItemSynced(String itemId) async {
    final item = await _appDatabase.findStockItemByAnyId(itemId);
    if (item == null) return;

    final companion = StockItemsCompanion(
      isSynced: const Value(true),
      syncStatus: const Value('synced'),
      updatedAt: Value(DateTime.now()),
    );

    if (item.serverId != null) {
      await _appDatabase.updateStockItemByServerId(
        serverId: item.serverId!,
        companion: companion,
      );
    } else if (item.clientId != null) {
      await _appDatabase.updateStockItemByClientId(
        clientId: item.clientId!,
        companion: companion,
      );
    }
  }

  double _computeNextStock({
    required double current,
    required String transactionType,
    required double quantity,
  }) {
    switch (transactionType) {
      case 'stock_in':
        return current + quantity;
      case 'stock_out':
      case 'wastage':
        return current - quantity;
      case 'adjustment':
        return quantity;
      default:
        return current;
    }
  }

  double _toDouble(String? value) {
    return double.tryParse(value ?? '') ?? 0;
  }

  String _formatAmount(double value) {
    return value.toStringAsFixed(3);
  }

  DateTime? _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  String _normalizeAmount(dynamic value) {
    if (value == null) return '0';
    if (value is String) return value;
    if (value is num) return value.toString();
    return value.toString();
  }
}

class _SyncScope {
  const _SyncScope({
    required this.userId,
    required this.businessId,
  });

  final String userId;
  final String businessId;
}
