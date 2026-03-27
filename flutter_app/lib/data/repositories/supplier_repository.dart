import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/result.dart';
import '../../core/constants/api_constants.dart';
import '../../core/database/app_database.dart';
import '../../core/sync/sync_queue.dart';
import '../../shared/models/supplier_model.dart';

/// Supplier Repository
class SupplierRepository {
  SupplierRepository({
    required ApiClient apiClient,
    required AppDatabase appDatabase,
    required SyncQueue syncQueue,
  })  : _apiClient = apiClient,
        _appDatabase = appDatabase,
        _syncQueue = syncQueue;

  final ApiClient _apiClient;
  final AppDatabase _appDatabase;
  final SyncQueue _syncQueue;

  /// Create supplier
  Future<Result<SupplierModel>> createSupplier({
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
        ApiConstants.suppliers,
        data: payload,
      );

      final supplier = SupplierModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      await _appDatabase.upsertSuppliers([
        _supplierCompanionFromModel(supplier),
      ]);

      return Result.success(supplier);
    } on AppException catch (e) {
      if (e is NetworkException || e is TimeoutException) {
        final supplier = await _createSupplierOffline(payload);
        return Result.success(supplier);
      }
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  /// Get suppliers
  Future<Result<List<SupplierModel>>> getSuppliers({
    bool? isActive,
    String? search,
    int limit = 100,
    int offset = 0,
  }) async {
    List<SupplierModel> localSuppliers = [];
    try {
      final localRows = await _appDatabase.fetchSuppliers(
        isActive: isActive,
        search: search,
        limit: limit,
        offset: offset,
      );
      localSuppliers = localRows.map(_supplierFromRow).toList();
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
        ApiConstants.suppliers,
        queryParameters: queryParams,
      );

      final suppliers = (response.data as List<dynamic>)
          .map((e) => SupplierModel.fromJson(e as Map<String, dynamic>))
          .toList();

      await _appDatabase.upsertSuppliers(
        suppliers.map(_supplierCompanionFromModel).toList(),
      );

      return Result.success(suppliers);
    } on AppException catch (e) {
      if (localSuppliers.isNotEmpty ||
          e is NetworkException ||
          e is TimeoutException) {
        return Result.success(localSuppliers);
      }
      return Result.failure(_mapExceptionToFailure(e));
    } catch (e) {
      return Result.success(localSuppliers);
    }
  }

  /// Record supplier payment
  Future<Result<void>> recordPayment({
    required String supplierId,
    required String amount,
    required DateTime date,
    String? remarks,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.suppliers}/$supplierId/payments',
        data: {
          'amount': amount,
          'date': date.toIso8601String(),
          if (remarks != null) 'remarks': remarks,
        },
      );

      await _cacheSupplierTransactionFromResponse(
        response.data,
        fallback: {
          'supplier_id': supplierId,
          'transaction_type': 'payment',
          'amount': amount,
          'date': date.toIso8601String(),
          if (remarks != null) 'remarks': remarks,
        },
      );

      return const Result.success(null);
    } on AppException catch (e) {
      if (e is NetworkException || e is TimeoutException) {
        await _createSupplierTransactionOffline(
          supplierId: supplierId,
          transactionType: 'payment',
          amount: amount,
          date: date,
          remarks: remarks,
        );
        return const Result.success(null);
      }
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  /// Record supplier purchase
  Future<Result<void>> recordPurchase({
    required String supplierId,
    required String amount,
    required DateTime date,
    List<Map<String, dynamic>>? items,
    String? remarks,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.suppliers}/$supplierId/purchases',
        data: {
          'amount': amount,
          'date': date.toIso8601String(),
          if (items != null) 'items': items,
          if (remarks != null) 'remarks': remarks,
        },
      );

      await _cacheSupplierTransactionFromResponse(
        response.data,
        fallback: {
          'supplier_id': supplierId,
          'transaction_type': 'purchase',
          'amount': amount,
          'date': date.toIso8601String(),
          if (remarks != null) 'remarks': remarks,
        },
      );

      return const Result.success(null);
    } on AppException catch (e) {
      if (e is NetworkException || e is TimeoutException) {
        await _createSupplierTransactionOffline(
          supplierId: supplierId,
          transactionType: 'purchase',
          amount: amount,
          date: date,
          items: items,
          remarks: remarks,
        );
        return const Result.success(null);
      }
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  /// Get supplier transactions
  Future<Result<List<Map<String, dynamic>>>> getTransactions(
      String supplierId) async {
    List<Map<String, dynamic>> localTransactions = [];
    try {
      final localRows = await _appDatabase.fetchSupplierTransactions(
        supplierId: supplierId,
      );
      localTransactions = localRows.map(_supplierTransactionFromRow).toList();
    } catch (_) {}

    try {
      final response = await _apiClient.get(
        '${ApiConstants.suppliers}/$supplierId/transactions',
      );

      final transactions =
          (response.data as List<dynamic>).cast<Map<String, dynamic>>();

      await _cacheSupplierTransactions(
        supplierId: supplierId,
        transactions: transactions,
      );

      return Result.success(transactions);
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

  SupplierModel _supplierFromRow(Supplier row) {
    return SupplierModel(
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

  SuppliersCompanion _supplierCompanionFromModel(SupplierModel model) {
    return SuppliersCompanion(
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

  Map<String, dynamic> _supplierTransactionFromRow(
    SupplierTransaction row,
  ) {
    return {
      'id': row.serverId ?? row.clientId ?? row.id.toString(),
      'supplier_id': row.supplierId,
      'transaction_type': row.transactionType,
      'amount': row.amount,
      'date': row.date.toIso8601String(),
      if (row.referenceId != null) 'reference_id': row.referenceId,
      if (row.referenceType != null) 'reference_type': row.referenceType,
      if (row.remarks != null) 'remarks': row.remarks,
      if (row.createdAt != null) 'created_at': row.createdAt!.toIso8601String(),
    };
  }

  Future<SupplierModel> _createSupplierOffline(
    Map<String, dynamic> payload,
  ) async {
    final now = DateTime.now();
    final clientId = const Uuid().v4();

    final localId = await _appDatabase.into(_appDatabase.suppliers).insert(
          SuppliersCompanion.insert(
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
      entityType: 'supplier',
      action: 'create',
      entityId: localId,
      data: {
        ...payload,
        'client_id': clientId,
        'updated_at': now.toIso8601String(),
      },
    );

    return SupplierModel(
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

  Future<void> _createSupplierTransactionOffline({
    required String supplierId,
    required String transactionType,
    required String amount,
    required DateTime date,
    List<Map<String, dynamic>>? items,
    String? remarks,
  }) async {
    final now = DateTime.now();
    final clientId = const Uuid().v4();

    final localId =
        await _appDatabase.into(_appDatabase.supplierTransactions).insert(
              SupplierTransactionsCompanion.insert(
                clientId: Value(clientId),
                supplierId: supplierId,
                transactionType: transactionType,
                amount: amount,
                date: date,
                remarks: Value(remarks),
                createdAt: Value(now),
                isSynced: const Value(false),
                syncStatus: const Value('pending'),
              ),
            );

    await _syncQueue.enqueue(
      entityType: 'supplier_transaction',
      action: 'create',
      entityId: localId,
      data: {
        'supplier_id': supplierId,
        'transaction_type': transactionType,
        'amount': amount,
        'date': date.toIso8601String(),
        if (items != null) 'items': items,
        if (remarks != null) 'remarks': remarks,
        'client_id': clientId,
        'updated_at': now.toIso8601String(),
      },
    );
  }

  Future<void> _cacheSupplierTransactions({
    required String supplierId,
    required List<Map<String, dynamic>> transactions,
  }) async {
    if (transactions.isEmpty) return;

    final companions = <SupplierTransactionsCompanion>[];
    for (final transaction in transactions) {
      final companion = _supplierTransactionCompanionFromMap(
        transaction,
        supplierIdFallback: supplierId,
      );
      if (companion != null) {
        companions.add(companion);
      }
    }
    await _appDatabase.upsertSupplierTransactions(companions);
  }

  SupplierTransactionsCompanion? _supplierTransactionCompanionFromMap(
    Map<String, dynamic> transaction, {
    String? supplierIdFallback,
  }) {
    final serverId =
        transaction['id']?.toString() ?? transaction['_id']?.toString();
    if (serverId == null || serverId.isEmpty) {
      return null;
    }
    final supplierId =
        transaction['supplier_id']?.toString() ?? supplierIdFallback ?? '';
    if (supplierId.isEmpty) return null;

    return SupplierTransactionsCompanion(
      serverId: Value(serverId),
      supplierId: Value(supplierId),
      transactionType: Value(
        transaction['transaction_type']?.toString() ?? '',
      ),
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

  Future<void> _cacheSupplierTransactionFromResponse(
    dynamic responseData, {
    required Map<String, dynamic> fallback,
  }) async {
    if (responseData is Map<String, dynamic>) {
      final companion = _supplierTransactionCompanionFromMap(responseData);
      if (companion != null) {
        await _appDatabase.upsertSupplierTransactions([companion]);
        return;
      }
    }

    final companion = _supplierTransactionCompanionFromMap(fallback);
    if (companion != null) {
      await _appDatabase.upsertSupplierTransactions([companion]);
    }
  }

  DateTime? _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
