import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/result.dart';
import '../../core/constants/api_constants.dart';
import '../../core/database/app_database.dart';
import '../../core/sync/sync_queue.dart';
import '../../shared/models/inventory_transaction_model.dart';
import '../../shared/models/stock_alert_model.dart';
import '../../shared/models/stock_item_model.dart';

/// Stock Repository
class StockRepository {
  StockRepository({
    required ApiClient apiClient,
    required AppDatabase appDatabase,
    required SyncQueue syncQueue,
  })  : _apiClient = apiClient,
        _appDatabase = appDatabase,
        _syncQueue = syncQueue;

  final ApiClient _apiClient;
  final AppDatabase _appDatabase;
  final SyncQueue _syncQueue;

  /// Create stock item
  Future<Result<StockItemModel>> createItem({
    required String name,
    required String purchasePrice,
    required String salePrice,
    required String unit,
    required String openingStock,
    String? description,
  }) async {
    final payload = {
      'name': name,
      'purchase_price': purchasePrice,
      'sale_price': salePrice,
      'unit': unit,
      'opening_stock': openingStock,
      if (description != null) 'description': description,
    };
    try {
      final response = await _apiClient.post(
        ApiConstants.stockItems,
        data: payload,
      );

      final item = StockItemModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      await _cacheItem(item);

      return Result.success(item);
    } on AppException catch (e) {
      if (e is NetworkException || e is TimeoutException) {
        final item = await _createItemOffline(payload);
        return Result.success(item);
      }
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  /// Get stock items
  Future<Result<List<StockItemModel>>> getItems({
    bool? isActive,
    String? search,
    int limit = 100,
    int offset = 0,
  }) async {
    List<StockItemModel> localItems = [];
    try {
      final localRows = await _appDatabase.fetchStockItems(
        isActive: isActive,
        search: search,
        limit: limit,
        offset: offset,
      );
      localItems = localRows.map(_stockItemFromRow).toList();
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
        ApiConstants.stockItems,
        queryParameters: queryParams,
      );

      final items = (response.data as List<dynamic>)
          .map((e) => StockItemModel.fromJson(e as Map<String, dynamic>))
          .toList();

      await _appDatabase.upsertStockItems(
        items.map(_stockItemCompanionFromModel).toList(),
      );

      return Result.success(items);
    } on AppException catch (e) {
      if (localItems.isNotEmpty ||
          e is NetworkException ||
          e is TimeoutException) {
        return Result.success(localItems);
      }
      return Result.failure(_mapExceptionToFailure(e));
    } catch (e) {
      return Result.success(localItems);
    }
  }

  /// Create inventory transaction
  Future<Result<InventoryTransactionModel>> createTransaction({
    required String itemId,
    required String transactionType,
    required String quantity,
    required String unitPrice,
    required DateTime date,
    String? remarks,
  }) async {
    final payload = {
      'item_id': itemId,
      'transaction_type': transactionType,
      'quantity': quantity,
      'unit_price': unitPrice,
      'date': date.toIso8601String(),
      if (remarks != null) 'remarks': remarks,
    };
    try {
      final response = await _apiClient.post(
        ApiConstants.stockTransactions,
        data: payload,
      );

      final transaction = InventoryTransactionModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      await _cacheTransaction(transaction);
      await _applyLocalStockChange(
        itemId: transaction.itemId,
        transactionType: transaction.transactionType,
        quantity: transaction.quantity,
        markSynced: true,
      );

      return Result.success(transaction);
    } on AppException catch (e) {
      if (e is NetworkException || e is TimeoutException) {
        return _createTransactionOffline(payload);
      }
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  /// Get low stock alerts
  Future<Result<List<StockAlertModel>>> getAlerts() async {
    try {
      final response = await _apiClient.get(ApiConstants.stockAlerts);

      final alerts = (response.data as List<dynamic>)
          .map((e) => StockAlertModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return Result.success(alerts);
    } on AppException catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  /// Get inventory transactions (local-first)
  Future<Result<List<InventoryTransactionModel>>> getTransactions({
    String? itemId,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final rows = await _appDatabase.fetchInventoryTransactions(
        itemId: itemId,
        limit: limit,
        offset: offset,
      );
      final transactions = rows.map(_inventoryTransactionFromRow).toList();
      return Result.success(transactions);
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  /// Resolve stock alert
  Future<Result<void>> resolveAlert(String alertId) async {
    try {
      await _apiClient.post('${ApiConstants.stockAlerts}/$alertId/resolve');
      return const Result.success(null);
    } on AppException catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  /// Update stock item
  Future<Result<StockItemModel>> updateItem({
    required String itemId,
    String? name,
    String? purchasePrice,
    String? salePrice,
    String? unit,
    String? description,
    bool? isActive,
  }) async {
    final payload = <String, dynamic>{
      if (name != null) 'name': name,
      if (purchasePrice != null) 'purchase_price': purchasePrice,
      if (salePrice != null) 'sale_price': salePrice,
      if (unit != null) 'unit': unit,
      if (description != null) 'description': description,
      if (isActive != null) 'is_active': isActive,
    };

    try {
      final response = await _apiClient.patch(
        '${ApiConstants.stockItems}/$itemId',
        data: payload,
      );

      final item = StockItemModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      await _cacheItem(item);

      return Result.success(item);
    } on AppException catch (e) {
      if (e is NetworkException || e is TimeoutException) {
        return _updateItemOffline(itemId, payload);
      }
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  /// Deactivate stock item
  Future<Result<void>> deleteItem(String itemId) async {
    try {
      await _apiClient.patch(
        '${ApiConstants.stockItems}/$itemId',
        data: {'is_active': false},
      );
      await _deactivateItemLocal(itemId, synced: true);
      return const Result.success(null);
    } on AppException catch (e) {
      if (e is NetworkException || e is TimeoutException) {
        await _deactivateItemLocal(itemId, synced: false);
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

  Future<void> _cacheItem(StockItemModel item) async {
    await _appDatabase.upsertStockItems([
      _stockItemCompanionFromModel(item),
    ]);
  }

  StockItemModel _stockItemFromRow(StockItem row) {
    return StockItemModel(
      id: row.serverId ?? row.clientId ?? row.id.toString(),
      name: row.name,
      purchasePrice: row.purchasePrice,
      salePrice: row.salePrice,
      unit: row.unit,
      currentStock: row.currentStock,
      description: row.description,
      isActive: row.isActive,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
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

  InventoryTransactionModel _inventoryTransactionFromRow(
    InventoryTransaction row,
  ) {
    return InventoryTransactionModel(
      id: row.serverId ?? row.clientId ?? row.id.toString(),
      itemId: row.itemId,
      transactionType: row.transactionType,
      quantity: row.quantity,
      unitPrice: row.unitPrice ?? '0',
      date: row.date,
      remarks: row.remarks,
      createdAt: row.createdAt ?? row.date,
    );
  }

  Future<StockItemModel> _createItemOffline(
    Map<String, dynamic> payload,
  ) async {
    final now = DateTime.now();
    final clientId = const Uuid().v4();
    final currentStock = payload['opening_stock']?.toString() ?? '0';

    final localId = await _appDatabase.into(_appDatabase.stockItems).insert(
          StockItemsCompanion.insert(
            name: payload['name'] as String,
            clientId: Value(clientId),
            purchasePrice: payload['purchase_price']?.toString() ?? '0',
            salePrice: payload['sale_price']?.toString() ?? '0',
            unit: payload['unit'] as String,
            currentStock: currentStock,
            description: Value(payload['description']?.toString()),
            isActive: const Value(true),
            createdAt: Value(now),
            updatedAt: Value(now),
            isSynced: const Value(false),
            syncStatus: const Value('pending'),
          ),
        );

    await _syncQueue.enqueue(
      entityType: 'item',
      action: 'create',
      entityId: localId,
      data: {
        ...payload,
        'client_id': clientId,
        'updated_at': now.toIso8601String(),
      },
    );

    return StockItemModel(
      id: clientId,
      name: payload['name'] as String,
      purchasePrice: payload['purchase_price']?.toString() ?? '0',
      salePrice: payload['sale_price']?.toString() ?? '0',
      unit: payload['unit'] as String,
      currentStock: currentStock,
      description: payload['description']?.toString(),
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<Result<InventoryTransactionModel>> _createTransactionOffline(
    Map<String, dynamic> payload,
  ) async {
    final now = DateTime.now();
    final clientId = const Uuid().v4();
    final itemId = payload['item_id']?.toString() ?? '';
    if (itemId.isEmpty) {
      return const Result.failure(
        ValidationFailure('Item is required'),
      );
    }

    final localItem = await _appDatabase.findStockItemByAnyId(itemId);
    final quantityValue = _parseDouble(payload['quantity']?.toString());
    if (quantityValue <= 0) {
      return const Result.failure(
        ValidationFailure('Quantity must be greater than 0'),
      );
    }

    if (localItem != null) {
      final currentStock = _parseDouble(localItem.currentStock);
      final nextStock = _computeNextStock(
        current: currentStock,
        transactionType: payload['transaction_type']?.toString() ?? '',
        quantity: quantityValue,
      );
      if (nextStock < 0) {
        return const Result.failure(
          BusinessLogicFailure('Insufficient stock'),
        );
      }
    }

    final localId =
        await _appDatabase.into(_appDatabase.inventoryTransactions).insert(
              InventoryTransactionsCompanion.insert(
                clientId: Value(clientId),
                itemId: itemId,
                transactionType: payload['transaction_type']?.toString() ?? '',
                quantity: payload['quantity']?.toString() ?? '0',
                unitPrice: Value(payload['unit_price']?.toString()),
                date: DateTime.parse(payload['date'] as String),
                remarks: Value(payload['remarks']?.toString()),
                createdAt: Value(now),
                isSynced: const Value(false),
                syncStatus: const Value('pending'),
              ),
            );

    await _applyLocalStockChange(
      itemId: itemId,
      transactionType: payload['transaction_type']?.toString() ?? '',
      quantity: payload['quantity']?.toString() ?? '0',
      markSynced: false,
    );

    await _syncQueue.enqueue(
      entityType: 'inventory_transaction',
      action: 'create',
      entityId: localId,
      data: {
        ...payload,
        'client_id': clientId,
        'updated_at': now.toIso8601String(),
      },
    );

    return Result.success(
      InventoryTransactionModel(
        id: clientId,
        itemId: itemId,
        transactionType: payload['transaction_type']?.toString() ?? '',
        quantity: payload['quantity']?.toString() ?? '0',
        unitPrice: payload['unit_price']?.toString() ?? '0',
        date: DateTime.parse(payload['date'] as String),
        remarks: payload['remarks']?.toString(),
        createdAt: now,
      ),
    );
  }

  Future<void> _cacheTransaction(InventoryTransactionModel transaction) async {
    await _appDatabase.upsertInventoryTransactions([
      InventoryTransactionsCompanion(
        serverId: Value(transaction.id),
        itemId: Value(transaction.itemId),
        transactionType: Value(transaction.transactionType),
        quantity: Value(transaction.quantity),
        unitPrice: Value(transaction.unitPrice),
        date: Value(transaction.date),
        remarks: Value(transaction.remarks),
        createdAt: Value(transaction.createdAt ?? transaction.date),
        isSynced: const Value(true),
        syncStatus: const Value('synced'),
      ),
    ]);
  }

  Future<void> _applyLocalStockChange({
    required String itemId,
    required String transactionType,
    required String quantity,
    required bool markSynced,
  }) async {
    final item = await _appDatabase.findStockItemByAnyId(itemId);
    if (item == null) return;

    final current = _parseDouble(item.currentStock);
    final qty = _parseDouble(quantity);
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

  Future<Result<StockItemModel>> _updateItemOffline(
    String itemId,
    Map<String, dynamic> payload,
  ) async {
    final local = await _appDatabase.findStockItemByAnyId(itemId);
    if (local == null) {
      return Result.failure(UnknownFailure('Item not found'));
    }

    final now = DateTime.now();
    final companion = StockItemsCompanion(
      name: payload.containsKey('name')
          ? Value(payload['name']?.toString() ?? local.name)
          : const Value.absent(),
      purchasePrice: payload.containsKey('purchase_price')
          ? Value(payload['purchase_price']?.toString() ?? local.purchasePrice)
          : const Value.absent(),
      salePrice: payload.containsKey('sale_price')
          ? Value(payload['sale_price']?.toString() ?? local.salePrice)
          : const Value.absent(),
      unit: payload.containsKey('unit')
          ? Value(payload['unit']?.toString() ?? local.unit)
          : const Value.absent(),
      description: payload.containsKey('description')
          ? Value(payload['description']?.toString())
          : const Value.absent(),
      isActive: payload.containsKey('is_active')
          ? Value(payload['is_active'] as bool)
          : const Value.absent(),
      updatedAt: Value(now),
      isSynced: const Value(false),
      syncStatus: const Value('pending'),
    );

    if (local.serverId != null) {
      await _appDatabase.updateStockItemByServerId(
        serverId: local.serverId!,
        companion: companion,
      );

      await _syncQueue.enqueue(
        entityType: 'item',
        action: 'update',
        entityServerId: local.serverId,
        data: {
          'id': local.serverId,
          ...payload,
          'updated_at': now.toIso8601String(),
        },
      );
    } else if (local.clientId != null) {
      await _appDatabase.updateStockItemByClientId(
        clientId: local.clientId!,
        companion: companion,
      );
      await _syncQueue.mergePendingCreatePayload(
        entityType: 'item',
        clientId: local.clientId!,
        updates: {
          ...payload,
          'updated_at': now.toIso8601String(),
        },
      );
    }

    final refreshed = await _appDatabase.findStockItemByAnyId(itemId);
    if (refreshed == null) {
      return Result.failure(UnknownFailure('Failed to update item'));
    }

    return Result.success(_stockItemFromRow(refreshed));
  }

  Future<void> _deactivateItemLocal(String itemId,
      {required bool synced}) async {
    final local = await _appDatabase.findStockItemByAnyId(itemId);
    if (local == null) return;

    if (!synced && local.serverId == null && local.clientId != null) {
      await _syncQueue.removePendingCreateByClientIdForEntity(
        entityType: 'item',
        clientId: local.clientId!,
      );
      await _appDatabase.deleteStockItemByClientId(local.clientId!);
      return;
    }

    final companion = StockItemsCompanion(
      isActive: const Value(false),
      updatedAt: Value(DateTime.now()),
      isSynced: Value(synced),
      syncStatus: Value(synced ? 'synced' : 'pending'),
    );

    if (local.serverId != null) {
      await _appDatabase.updateStockItemByServerId(
        serverId: local.serverId!,
        companion: companion,
      );
    } else if (local.clientId != null) {
      await _appDatabase.updateStockItemByClientId(
        clientId: local.clientId!,
        companion: companion,
      );
    }

    if (!synced && local.serverId != null) {
      await _syncQueue.enqueue(
        entityType: 'item',
        action: 'update',
        entityServerId: local.serverId,
        data: {
          'id': local.serverId,
          'is_active': false,
          'updated_at': DateTime.now().toIso8601String(),
        },
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

  double _parseDouble(String? value) {
    return double.tryParse(value ?? '') ?? 0;
  }

  String _formatAmount(double value) {
    return value.toStringAsFixed(3);
  }
}
