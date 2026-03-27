import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/result.dart';
import '../../core/constants/api_constants.dart';
import '../../core/database/app_database.dart';
import '../../core/sync/sync_queue.dart';
import '../../shared/models/customer_model.dart';

/// Customer Repository
class CustomerRepository {
  CustomerRepository({
    required ApiClient apiClient,
    required AppDatabase appDatabase,
    required SyncQueue syncQueue,
  })  : _apiClient = apiClient,
        _appDatabase = appDatabase,
        _syncQueue = syncQueue;

  final ApiClient _apiClient;
  final AppDatabase _appDatabase;
  final SyncQueue _syncQueue;

  /// Create customer
  Future<Result<CustomerModel>> createCustomer({
    required String name,
    String? phone,
    String? email,
    String? address,
  }) async {
    final payload = <String, dynamic>{
      'name': name,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
    };

    try {
      final response = await _apiClient.post(
        ApiConstants.customers,
        data: payload,
      );

      final customer = CustomerModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      await _appDatabase.upsertCustomers([
        _customerCompanionFromModel(customer),
      ]);

      return Result.success(customer);
    } on AppException catch (e) {
      if (e is NetworkException || e is TimeoutException) {
        final customer = await _createCustomerOffline(payload);
        return Result.success(customer);
      }
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  /// Get customers
  Future<Result<List<CustomerModel>>> getCustomers({
    bool? isActive,
    String? search,
    int limit = 100,
    int offset = 0,
  }) async {
    List<CustomerModel> localCustomers = [];
    try {
      final localRows = await _appDatabase.fetchCustomers(
        isActive: isActive,
        search: search,
        limit: limit,
        offset: offset,
      );
      localCustomers = localRows.map(_customerFromRow).toList();
    } catch (_) {}

    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };

      if (isActive != null) {
        queryParams['is_active'] = isActive;
      }
      if (search != null) {
        queryParams['search'] = search;
      }

      final response = await _apiClient.get(
        ApiConstants.customers,
        queryParameters: queryParams,
      );

      final customers = (response.data as List<dynamic>)
          .map((e) => CustomerModel.fromJson(e as Map<String, dynamic>))
          .toList();

      await _appDatabase.upsertCustomers(
        customers.map(_customerCompanionFromModel).toList(),
      );

      return Result.success(customers);
    } on AppException catch (e) {
      if (localCustomers.isNotEmpty ||
          e is NetworkException ||
          e is TimeoutException) {
        return Result.success(localCustomers);
      }
      return Result.failure(_mapExceptionToFailure(e));
    } catch (e) {
      return Result.success(localCustomers);
    }
  }

  /// Record customer payment
  Future<Result<void>> recordPayment({
    required String customerId,
    required String amount,
    required DateTime date,
    String? invoiceId,
    String? remarks,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.customers}/$customerId/payments',
        data: {
          'amount': amount,
          'date': date.toIso8601String(),
          if (invoiceId != null) 'invoice_id': invoiceId,
          if (remarks != null) 'remarks': remarks,
        },
      );

      await _cacheCustomerTransactionFromResponse(
        response.data,
        fallback: {
          'customer_id': customerId,
          'transaction_type': 'payment',
          'amount': amount,
          'date': date.toIso8601String(),
          if (invoiceId != null) 'reference_id': invoiceId,
          if (invoiceId != null) 'reference_type': 'invoice',
          if (remarks != null) 'remarks': remarks,
        },
      );

      return const Result.success(null);
    } on AppException catch (e) {
      if (e is NetworkException || e is TimeoutException) {
        await _createCustomerTransactionOffline(
          customerId: customerId,
          transactionType: 'payment',
          amount: amount,
          date: date,
          referenceId: invoiceId,
          referenceType: invoiceId != null ? 'invoice' : null,
          remarks: remarks,
        );
        return const Result.success(null);
      }
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  Future<Result<void>> updatePaymentTransaction({
    required String customerId,
    required String transactionId,
    required String amount,
    required DateTime date,
    String? remarks,
  }) async {
    final payload = <String, dynamic>{
      'amount': amount,
      'date': date.toIso8601String(),
      if (remarks != null) 'remarks': remarks,
    };

    try {
      final response = await _apiClient.patch(
        '${ApiConstants.customers}/$customerId/payments/$transactionId',
        data: payload,
      );

      await _cacheCustomerTransactionFromResponse(
        response.data,
        fallback: {
          'id': transactionId,
          'customer_id': customerId,
          'transaction_type': 'payment',
          'amount': amount,
          'date': date.toIso8601String(),
          if (remarks != null) 'remarks': remarks,
        },
      );
      return const Result.success(null);
    } on AppException catch (e) {
      if (e is NetworkException || e is TimeoutException) {
        final local = await _findLocalCustomerTransaction(transactionId);
        if (local == null) {
          return Result.failure(_mapExceptionToFailure(e));
        }

        final companion = CustomerTransactionsCompanion(
          amount: Value(amount),
          date: Value(date),
          remarks: Value(remarks),
          isSynced: const Value(false),
          syncStatus: const Value('pending'),
        );

        if (local.serverId != null && local.serverId!.isNotEmpty) {
          await _appDatabase.updateCustomerTransactionByServerId(
            serverId: local.serverId!,
            companion: companion,
          );
          await _syncQueue.enqueue(
            entityType: 'customer_transaction',
            action: 'update',
            entityServerId: local.serverId,
            data: {
              'customer_id': customerId,
              'transaction_id': local.serverId,
              'amount': amount,
              'date': date.toIso8601String(),
              if (remarks != null) 'remarks': remarks,
              'updated_at': DateTime.now().toIso8601String(),
            },
          );
          return const Result.success(null);
        }

        if (local.clientId != null && local.clientId!.isNotEmpty) {
          await _appDatabase.updateCustomerTransactionByClientId(
            clientId: local.clientId!,
            companion: companion,
          );
          await _syncQueue.mergePendingCreatePayload(
            entityType: 'customer_transaction',
            clientId: local.clientId!,
            updates: {
              'amount': amount,
              'date': date.toIso8601String(),
              if (remarks != null) 'remarks': remarks,
              'updated_at': DateTime.now().toIso8601String(),
            },
          );
          return const Result.success(null);
        }
      }
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  Future<Result<void>> deletePaymentTransaction({
    required String customerId,
    required String transactionId,
  }) async {
    try {
      await _apiClient.delete(
        '${ApiConstants.customers}/$customerId/payments/$transactionId',
      );
      final deleted =
          await _appDatabase.deleteCustomerTransactionByServerId(transactionId);
      if (deleted == 0) {
        await _appDatabase.deleteCustomerTransactionByClientId(transactionId);
      }
      await _syncQueue.removeByEntity(
        entityType: 'customer_transaction',
        entityId: transactionId,
      );
      return const Result.success(null);
    } on AppException catch (e) {
      if (e is NetworkException || e is TimeoutException) {
        final local = await _findLocalCustomerTransaction(transactionId);
        if (local == null) {
          return Result.failure(_mapExceptionToFailure(e));
        }

        if (local.serverId == null && local.clientId != null) {
          await _syncQueue.removePendingCreateByClientIdForEntity(
            entityType: 'customer_transaction',
            clientId: local.clientId!,
          );
          await _appDatabase
              .deleteCustomerTransactionByClientId(local.clientId!);
          return const Result.success(null);
        }

        final serverId = local.serverId ?? transactionId;
        await _appDatabase.deleteCustomerTransactionByServerId(serverId);
        await _syncQueue.enqueue(
          entityType: 'customer_transaction',
          action: 'delete',
          entityServerId: serverId,
          data: {
            'customer_id': customerId,
            'transaction_id': serverId,
            'updated_at': DateTime.now().toIso8601String(),
          },
        );
        return const Result.success(null);
      }
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  /// Get customer transactions
  Future<Result<List<Map<String, dynamic>>>> getTransactions(
      String customerId) async {
    List<Map<String, dynamic>> localTransactions = [];
    try {
      localTransactions = await _loadLocalTransactions(customerId);
    } catch (_) {}

    try {
      final response = await _apiClient.get(
        '${ApiConstants.customers}/$customerId/transactions',
      );

      final transactions = (response.data as List<dynamic>)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      await _cacheCustomerTransactions(
        customerId: customerId,
        transactions: transactions,
      );

      final mergedLocal = await _loadLocalTransactions(customerId);
      return Result.success(mergedLocal);
    } on AppException catch (e) {
      if (localTransactions.isNotEmpty ||
          e is NetworkException ||
          e is TimeoutException) {
        return Result.success(localTransactions);
      }
      return Result.failure(_mapExceptionToFailure(e));
    } catch (e) {
      return Result.success(localTransactions);
    }
  }

  /// Delete (deactivate) customer
  Future<Result<void>> deleteCustomer(String customerId) async {
    try {
      await _apiClient.delete(
        '${ApiConstants.customers}/$customerId',
      );
      await _markCustomerDeletedSynced(customerId);
      return const Result.success(null);
    } on AppException catch (e) {
      if (e is NetworkException || e is TimeoutException) {
        await _queueCustomerDelete(customerId);
        return const Result.success(null);
      }
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  Failure _mapExceptionToFailure(AppException exception) {
    return switch (exception) {
      NetworkException() => NetworkFailure(exception.message),
      ServerException() => ServerFailure(exception.message),
      TimeoutException() => TimeoutFailure(exception.message),
      ValidationException() => ValidationFailure(
          exception.message,
          exception.errors,
        ),
      _ => UnknownFailure(exception.message),
    };
  }

  CustomerModel _customerFromRow(Customer row) {
    return CustomerModel(
      id: row.serverId ?? row.clientId ?? row.id.toString(),
      name: row.name,
      phone: row.phone,
      email: row.email,
      address: row.address,
      isActive: row.isActive,
      balance: row.balance,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  CustomersCompanion _customerCompanionFromModel(CustomerModel model) {
    return CustomersCompanion(
      serverId: Value(model.id),
      name: Value(model.name),
      phone: Value(model.phone),
      email: Value(model.email),
      address: Value(model.address),
      isActive: Value(model.isActive ?? true),
      balance: Value(model.balance),
      createdAt: Value(model.createdAt ?? DateTime.now()),
      updatedAt: Value(model.updatedAt ?? DateTime.now()),
      isSynced: const Value(true),
      syncStatus: const Value('synced'),
    );
  }

  Map<String, dynamic> _customerTransactionFromRow(CustomerTransaction row) {
    return {
      'id': row.serverId ?? row.clientId ?? row.id.toString(),
      'customer_id': row.customerId,
      'transaction_type': row.transactionType,
      'amount': row.amount,
      'date': row.date.toIso8601String(),
      if (row.referenceId != null) 'reference_id': row.referenceId,
      if (row.referenceType != null) 'reference_type': row.referenceType,
      if (row.remarks != null) 'remarks': row.remarks,
      if (row.createdAt != null) 'created_at': row.createdAt!.toIso8601String(),
    };
  }

  Future<CustomerModel> _createCustomerOffline(
    Map<String, dynamic> payload,
  ) async {
    final now = DateTime.now();
    final clientId = const Uuid().v4();

    final localId = await _appDatabase.into(_appDatabase.customers).insert(
          CustomersCompanion.insert(
            name: payload['name'] as String,
            clientId: Value(clientId),
            phone: Value(payload['phone'] as String?),
            email: Value(payload['email'] as String?),
            address: Value(payload['address'] as String?),
            isActive: const Value(true),
            balance: const Value.absent(),
            createdAt: Value(now),
            updatedAt: Value(now),
            isSynced: const Value(false),
            syncStatus: const Value('pending'),
          ),
        );

    await _syncQueue.enqueue(
      entityType: 'customer',
      action: 'create',
      entityId: localId,
      data: {
        ...payload,
        'client_id': clientId,
        'updated_at': now.toIso8601String(),
      },
    );

    return CustomerModel(
      id: clientId,
      name: payload['name'] as String,
      phone: payload['phone'] as String?,
      email: payload['email'] as String?,
      address: payload['address'] as String?,
      isActive: true,
      balance: null,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<void> _createCustomerTransactionOffline({
    required String customerId,
    required String transactionType,
    required String amount,
    required DateTime date,
    String? referenceId,
    String? referenceType,
    String? remarks,
  }) async {
    final now = DateTime.now();
    final clientId = const Uuid().v4();

    final localId =
        await _appDatabase.into(_appDatabase.customerTransactions).insert(
              CustomerTransactionsCompanion.insert(
                clientId: Value(clientId),
                customerId: customerId,
                transactionType: transactionType,
                amount: amount,
                date: date,
                referenceId: Value(referenceId),
                referenceType: Value(referenceType),
                remarks: Value(remarks),
                createdAt: Value(now),
                isSynced: const Value(false),
                syncStatus: const Value('pending'),
              ),
            );

    await _syncQueue.enqueue(
      entityType: 'customer_transaction',
      action: 'create',
      entityId: localId,
      data: {
        'customer_id': customerId,
        'transaction_type': transactionType,
        'amount': amount,
        'date': date.toIso8601String(),
        if (referenceId != null) 'reference_id': referenceId,
        if (referenceType != null) 'reference_type': referenceType,
        if (remarks != null) 'remarks': remarks,
        'client_id': clientId,
        'updated_at': now.toIso8601String(),
      },
    );
  }

  Future<CustomerTransaction?> _findLocalCustomerTransaction(String id) async {
    final byServerId = await _appDatabase.findCustomerTransactionByServerId(id);
    if (byServerId != null) return byServerId;
    return _appDatabase.findCustomerTransactionByClientId(id);
  }

  Future<List<Map<String, dynamic>>> _loadLocalTransactions(
    String customerId,
  ) async {
    final localRows = await _appDatabase.fetchCustomerTransactions(
      customerId: customerId,
      limit: 1000000,
    );
    final localTransactions =
        localRows.map(_customerTransactionFromRow).toList();

    final invoiceRows = await _appDatabase.fetchInvoices(
      customerId: customerId,
      invoiceType: 'credit',
      limit: 1000000,
    );
    final localInvoiceReferences = localTransactions
        .where(
          (txn) =>
              txn['transaction_type']?.toString() == 'credit' &&
              txn['reference_type']?.toString() == 'invoice' &&
              (txn['reference_id']?.toString().isNotEmpty ?? false),
        )
        .map((txn) => txn['reference_id']!.toString())
        .toSet();

    for (final invoice in invoiceRows) {
      final invoiceId = invoice.serverId;
      if (localInvoiceReferences.contains(invoiceId)) {
        continue;
      }
      localTransactions.add({
        'id': invoiceId,
        'customer_id': customerId,
        'transaction_type': 'credit',
        'amount': invoice.totalAmount,
        'date': invoice.date.toIso8601String(),
        'reference_id': invoiceId,
        'reference_type': 'invoice',
        'invoice_number': invoice.invoiceNumber,
        if (invoice.remarks != null) 'remarks': invoice.remarks,
        if (invoice.createdAt != null)
          'created_at': invoice.createdAt!.toIso8601String(),
      });
    }

    localTransactions.sort((a, b) {
      final aDate = DateTime.tryParse(a['date']?.toString() ?? '');
      final bDate = DateTime.tryParse(b['date']?.toString() ?? '');
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });

    return localTransactions;
  }

  Future<void> _cacheCustomerTransactions({
    required String customerId,
    required List<Map<String, dynamic>> transactions,
  }) async {
    if (transactions.isEmpty) return;
    final companions = <CustomerTransactionsCompanion>[];
    for (final transaction in transactions) {
      final companion = _customerTransactionCompanionFromMap(
        transaction,
        customerIdFallback: customerId,
      );
      if (companion != null) {
        companions.add(companion);
      }
    }
    await _appDatabase.upsertCustomerTransactions(companions);
  }

  CustomerTransactionsCompanion? _customerTransactionCompanionFromMap(
    Map<String, dynamic> transaction, {
    String? customerIdFallback,
    String? fallbackClientId,
  }) {
    final serverId =
        transaction['id']?.toString() ?? transaction['_id']?.toString();
    final clientId = transaction['client_id']?.toString() ?? fallbackClientId;
    if ((serverId == null || serverId.isEmpty) &&
        (clientId == null || clientId.isEmpty)) {
      return null;
    }

    final customerId =
        transaction['customer_id']?.toString() ?? customerIdFallback ?? '';
    if (customerId.isEmpty) return null;

    final transactionType = transaction['transaction_type']?.toString() ?? '';
    if (transactionType.isEmpty) return null;

    return CustomerTransactionsCompanion(
      serverId: Value(serverId),
      clientId: Value(clientId),
      customerId: Value(customerId),
      transactionType: Value(transactionType),
      amount: Value(transaction['amount']?.toString() ?? '0'),
      date: Value(_parseDate(transaction['date']) ?? DateTime.now()),
      referenceId: Value(transaction['reference_id']?.toString()),
      referenceType: Value(transaction['reference_type']?.toString()),
      remarks: Value(transaction['remarks']?.toString()),
      createdAt: Value(_parseDate(transaction['created_at'])),
      isSynced: const Value(true),
      syncStatus: const Value('synced'),
    );
  }

  Future<void> _cacheCustomerTransactionFromResponse(
    dynamic responseData, {
    required Map<String, dynamic> fallback,
  }) async {
    if (responseData is Map<String, dynamic>) {
      final companion = _customerTransactionCompanionFromMap(
        responseData,
        customerIdFallback: fallback['customer_id']?.toString(),
      );
      if (companion != null) {
        await _appDatabase.upsertCustomerTransactions([companion]);
        return;
      }
    }

    final companion = _customerTransactionCompanionFromMap(
      fallback,
      fallbackClientId: const Uuid().v4(),
    );
    if (companion != null) {
      await _appDatabase.upsertCustomerTransactions([companion]);
    }
  }

  DateTime? _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  Future<void> _queueCustomerDelete(String customerId) async {
    final local = await _appDatabase.findCustomerByAnyId(customerId);
    if (local != null) {
      if (local.serverId == null && local.clientId != null) {
        await _syncQueue.removePendingCreateByClientId(local.clientId!);
        await _appDatabase.deleteCustomerByClientId(local.clientId!);
        return;
      }

      final pendingUpdate = CustomersCompanion(
        isActive: const Value(false),
        isSynced: const Value(false),
        syncStatus: const Value('pending'),
        updatedAt: Value(DateTime.now()),
      );

      if (local.serverId != null) {
        await _appDatabase.updateCustomerByServerId(
          serverId: local.serverId!,
          companion: pendingUpdate,
        );
      } else if (local.clientId != null) {
        await _appDatabase.updateCustomerByClientId(
          clientId: local.clientId!,
          companion: pendingUpdate,
        );
      }

      await _syncQueue.enqueue(
        entityType: 'customer',
        action: 'delete',
        entityServerId: local.serverId,
        data: {
          'server_id': local.serverId,
          'client_id': local.clientId,
          'updated_at': DateTime.now().toIso8601String(),
        },
      );
      return;
    }

    await _syncQueue.enqueue(
      entityType: 'customer',
      action: 'delete',
      entityServerId: customerId,
      data: {
        'server_id': customerId,
        'updated_at': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> _markCustomerDeletedSynced(String customerId) async {
    final syncedUpdate = CustomersCompanion(
      isActive: const Value(false),
      isSynced: const Value(true),
      syncStatus: const Value('synced'),
      updatedAt: Value(DateTime.now()),
    );

    final updated = await _appDatabase.updateCustomerByServerId(
      serverId: customerId,
      companion: syncedUpdate,
    );

    if (updated == 0) {
      final local = await _appDatabase.findCustomerByAnyId(customerId);
      if (local?.clientId != null) {
        await _appDatabase.updateCustomerByClientId(
          clientId: local!.clientId!,
          companion: syncedUpdate,
        );
      }
    }
  }
}
