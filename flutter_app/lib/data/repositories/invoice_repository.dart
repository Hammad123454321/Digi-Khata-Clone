import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/result.dart';
import '../../core/constants/api_constants.dart';
import '../../core/database/app_database.dart';
import '../../core/sync/sync_queue.dart';
import '../../shared/models/invoice_model.dart';

/// Invoice Repository
class InvoiceRepository {
  InvoiceRepository({
    required ApiClient apiClient,
    required AppDatabase appDatabase,
    required SyncQueue syncQueue,
  })  : _apiClient = apiClient,
        _appDatabase = appDatabase,
        _syncQueue = syncQueue;

  final ApiClient _apiClient;
  final AppDatabase _appDatabase;
  final SyncQueue _syncQueue;

  /// Create invoice
  Future<Result<InvoiceModel>> createInvoice({
    String? customerId,
    required String invoiceType,
    required DateTime date,
    required List<Map<String, dynamic>> items,
    required String taxAmount,
    required String discountAmount,
    String? remarks,
  }) async {
    final payload = {
      if (customerId != null) 'customer_id': customerId,
      'invoice_type': invoiceType,
      'date': date.toIso8601String(),
      'items': items,
      'tax_amount': taxAmount,
      'discount_amount': discountAmount,
      if (remarks != null) 'remarks': remarks,
    };
    try {
      final response = await _apiClient.post(
        ApiConstants.invoices,
        data: payload,
      );

      final invoice = InvoiceModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      await _cacheInvoice(invoice);

      return Result.success(invoice);
    } on AppException catch (e) {
      if (e is NetworkException || e is TimeoutException) {
        final invoice = await _createInvoiceOffline(payload);
        return Result.success(invoice);
      }
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  /// Update invoice
  Future<Result<InvoiceModel>> updateInvoice({
    required String invoiceId,
    required DateTime date,
    required List<Map<String, dynamic>> items,
    required String taxAmount,
    required String discountAmount,
    String? remarks,
  }) async {
    final payload = {
      'date': date.toIso8601String(),
      'items': _sanitizeInvoiceItemsForApi(items),
      'tax_amount': taxAmount,
      'discount_amount': discountAmount,
      if (remarks != null) 'remarks': remarks,
    };

    final localRow = await _appDatabase.findInvoiceByServerId(invoiceId);
    if (localRow != null && localRow.isSynced == false) {
      final localInvoice = await _updateInvoiceOffline(
        invoiceId: invoiceId,
        payload: payload,
      );
      if (localInvoice != null) {
        return Result.success(localInvoice);
      }
    }

    try {
      final response = await _apiClient.patch(
        '${ApiConstants.invoices}/$invoiceId',
        data: payload,
      );
      final invoice = InvoiceModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      await _cacheInvoice(invoice);
      return Result.success(invoice);
    } on AppException catch (e) {
      if (e is NetworkException || e is TimeoutException) {
        final invoice = await _updateInvoiceOffline(
          invoiceId: invoiceId,
          payload: payload,
        );
        if (invoice != null) {
          return Result.success(invoice);
        }
      }
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  /// Delete invoice
  Future<Result<void>> deleteInvoice(String invoiceId) async {
    final local = await _appDatabase.findInvoiceByServerId(invoiceId);
    if (local != null && local.isSynced == false) {
      await _syncQueue.removePendingCreateByClientIdForEntity(
        entityType: 'invoice',
        clientId: invoiceId,
      );
      await _deleteInvoiceLocal(invoiceId);
      return const Result.success(null);
    }

    try {
      await _apiClient.delete('${ApiConstants.invoices}/$invoiceId');
      await _deleteInvoiceLocal(invoiceId);
      await _syncQueue.removeByEntity(
          entityType: 'invoice', entityId: invoiceId);
      return const Result.success(null);
    } on AppException catch (e) {
      if (e is NetworkException || e is TimeoutException) {
        final local = await _appDatabase.findInvoiceByServerId(invoiceId);
        if (local != null && local.isSynced == false) {
          await _syncQueue.removePendingCreateByClientIdForEntity(
            entityType: 'invoice',
            clientId: invoiceId,
          );
          await _deleteInvoiceLocal(invoiceId);
          return const Result.success(null);
        }

        await _deleteInvoiceLocal(invoiceId);
        await _syncQueue.enqueue(
          entityType: 'invoice',
          action: 'delete',
          entityServerId: invoiceId,
          data: {
            'invoice_id': invoiceId,
            'updated_at': DateTime.now().toIso8601String(),
          },
        );
        return const Result.success(null);
      }
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  /// Get invoices
  Future<Result<List<InvoiceModel>>> getInvoices({
    DateTime? startDate,
    DateTime? endDate,
    String? customerId,
    String? invoiceType,
    int limit = 100,
    int offset = 0,
  }) async {
    List<InvoiceModel> localInvoices = [];
    try {
      final localRows = await _appDatabase.fetchInvoices(
        startDate: startDate,
        endDate: endDate,
        customerId: customerId,
        invoiceType: invoiceType,
        limit: limit,
        offset: offset,
      );
      localInvoices = localRows.map(_invoiceFromRow).toList();
    } catch (_) {}

    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };

      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }
      if (customerId != null) {
        queryParams['customer_id'] = customerId;
      }
      if (invoiceType != null) {
        queryParams['invoice_type'] = invoiceType;
      }

      final response = await _apiClient.get(
        ApiConstants.invoices,
        queryParameters: queryParams,
      );

      final invoices = (response.data as List<dynamic>)
          .map((e) => InvoiceModel.fromJson(e as Map<String, dynamic>))
          .toList();

      await _appDatabase.upsertInvoices(
        invoices.map(_invoiceCompanionFromModel).toList(),
      );

      return Result.success(invoices);
    } on AppException catch (e) {
      if (localInvoices.isNotEmpty ||
          e is NetworkException ||
          e is TimeoutException) {
        return Result.success(localInvoices);
      }
      return Result.failure(_mapExceptionToFailure(e));
    } catch (e) {
      return Result.success(localInvoices);
    }
  }

  /// Get invoice by ID (includes items)
  Future<Result<InvoiceModel>> getInvoiceById(String invoiceId) async {
    InvoiceModel? localInvoice;
    try {
      localInvoice = await _loadLocalInvoice(invoiceId);
    } catch (_) {}

    try {
      final response = await _apiClient.get(
        '${ApiConstants.invoices}/$invoiceId',
      );

      final invoice = InvoiceModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      await _cacheInvoice(invoice);

      return Result.success(invoice);
    } on AppException catch (e) {
      if (localInvoice != null) {
        return Result.success(localInvoice);
      }
      return Result.failure(_mapExceptionToFailure(e));
    } catch (e) {
      if (localInvoice != null) {
        return Result.success(localInvoice);
      }
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  /// Get invoice PDF
  Future<Result<List<int>>> getInvoicePdf(String invoiceId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.invoices}/$invoiceId/pdf',
        options: Options(responseType: ResponseType.bytes),
      );

      return Result.success(response.data as List<int>);
    } on AppException catch (e) {
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

  Future<InvoiceModel> _createInvoiceOffline(
    Map<String, dynamic> payload,
  ) async {
    final now = DateTime.now();
    final clientId = const Uuid().v4();
    final shortId = clientId.replaceAll('-', '').substring(0, 6).toUpperCase();
    final invoiceNumber = 'LOCAL-$shortId';

    final items = (payload['items'] as List<dynamic>? ?? [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();

    double subtotal = 0;
    final itemModels = <InvoiceItemModel>[];
    for (final item in items) {
      final quantityStr = item['quantity']?.toString() ?? '0';
      final unitPriceStr = item['unit_price']?.toString() ?? '0';
      final qty = double.tryParse(quantityStr) ?? 0;
      final unitPrice = double.tryParse(unitPriceStr) ?? 0;
      final total = qty * unitPrice;
      subtotal += total;
      itemModels.add(
        InvoiceItemModel(
          id: item['id']?.toString() ?? '',
          itemId: item['item_id']?.toString(),
          itemName: item['item_name']?.toString() ?? '',
          quantity: quantityStr,
          unitPrice: unitPriceStr,
          totalPrice: _formatMoney(total),
        ),
      );
    }

    final tax = double.tryParse(payload['tax_amount']?.toString() ?? '0') ?? 0;
    final discount =
        double.tryParse(payload['discount_amount']?.toString() ?? '0') ?? 0;
    final total = subtotal + tax - discount;
    final paidAmount = payload['invoice_type'] == 'cash' ? total : 0.0;

    final localId = await _appDatabase.into(_appDatabase.invoices).insert(
          InvoicesCompanion.insert(
            serverId: clientId,
            invoiceNumber: invoiceNumber,
            customerId: Value(payload['customer_id']?.toString()),
            invoiceType: payload['invoice_type'] as String,
            date: DateTime.parse(payload['date'] as String),
            subtotal: _formatMoney(subtotal),
            taxAmount: payload['tax_amount']?.toString() ?? '0',
            discountAmount: payload['discount_amount']?.toString() ?? '0',
            totalAmount: _formatMoney(total),
            paidAmount: _formatMoney(paidAmount),
            remarks: Value(payload['remarks']?.toString()),
            pdfPath: const Value.absent(),
            createdAt: Value(now),
            updatedAt: Value(now),
            isSynced: const Value(false),
            syncStatus: const Value('pending'),
          ),
        );

    if (itemModels.isNotEmpty) {
      await _appDatabase.replaceInvoiceItems(
        invoiceServerId: clientId,
        entries: _invoiceItemsCompanions(clientId, itemModels),
      );
    }

    await _syncQueue.enqueue(
      entityType: 'invoice',
      action: 'create',
      entityId: localId,
      data: {
        ...payload,
        'client_id': clientId,
        'updated_at': now.toIso8601String(),
      },
    );

    final customerId = payload['customer_id']?.toString();
    if (customerId != null && payload['invoice_type'] == 'credit') {
      await _upsertCustomerCreditTransaction(
        invoiceId: clientId,
        customerId: customerId,
        amount: _formatMoney(total),
        date: DateTime.parse(payload['date'] as String),
        remarks: payload['remarks']?.toString(),
        createdAt: now,
        isSynced: false,
      );
    }

    return InvoiceModel(
      id: clientId,
      invoiceNumber: invoiceNumber,
      customerId: payload['customer_id']?.toString(),
      invoiceType: payload['invoice_type'] as String,
      date: DateTime.parse(payload['date'] as String),
      subtotal: _formatMoney(subtotal),
      taxAmount: payload['tax_amount']?.toString() ?? '0',
      discountAmount: payload['discount_amount']?.toString() ?? '0',
      totalAmount: _formatMoney(total),
      paidAmount: _formatMoney(paidAmount),
      remarks: payload['remarks']?.toString(),
      pdfPath: null,
      items: itemModels.isEmpty ? null : itemModels,
      createdAt: now,
    );
  }

  String _formatMoney(double value) {
    return value.toStringAsFixed(2);
  }

  InvoiceModel _invoiceFromRow(Invoice row,
      [List<InvoiceItem> items = const []]) {
    final itemModels = items
        .map(
          (item) => InvoiceItemModel(
            id: item.serverId ?? item.id.toString(),
            itemId: item.itemId,
            itemName: item.itemName,
            quantity: item.quantity,
            unitPrice: item.unitPrice,
            totalPrice: item.totalPrice,
          ),
        )
        .toList();

    return InvoiceModel(
      id: row.serverId,
      invoiceNumber: row.invoiceNumber,
      customerId: row.customerId,
      invoiceType: row.invoiceType,
      date: row.date,
      subtotal: row.subtotal,
      taxAmount: row.taxAmount,
      discountAmount: row.discountAmount,
      totalAmount: row.totalAmount,
      paidAmount: row.paidAmount,
      remarks: row.remarks,
      pdfPath: row.pdfPath,
      items: itemModels.isEmpty ? null : itemModels,
      createdAt: row.createdAt,
    );
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
            serverId: item.id.isEmpty ? const Value.absent() : Value(item.id),
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

  Future<void> _cacheInvoice(InvoiceModel invoice) async {
    await _appDatabase.upsertInvoices([
      _invoiceCompanionFromModel(invoice),
    ]);
    if (invoice.items != null && invoice.items!.isNotEmpty) {
      await _appDatabase.replaceInvoiceItems(
        invoiceServerId: invoice.id,
        entries: _invoiceItemsCompanions(invoice.id, invoice.items!),
      );
    }

    if (invoice.customerId != null && invoice.invoiceType == 'credit') {
      await _upsertCustomerCreditTransaction(
        invoiceId: invoice.id,
        customerId: invoice.customerId!,
        amount: invoice.totalAmount,
        date: invoice.date,
        remarks: invoice.remarks,
        createdAt: invoice.createdAt,
        isSynced: true,
      );
    }
  }

  List<Map<String, dynamic>> _sanitizeInvoiceItemsForApi(
    List<Map<String, dynamic>> items,
  ) {
    return items
        .map(
          (item) => {
            if (item['item_id'] != null) 'item_id': item['item_id'],
            'item_name': item['item_name'],
            'quantity': item['quantity'],
            'unit_price': item['unit_price'],
          },
        )
        .toList();
  }

  Future<InvoiceModel?> _updateInvoiceOffline({
    required String invoiceId,
    required Map<String, dynamic> payload,
  }) async {
    final existing = await _loadLocalInvoice(invoiceId);
    if (existing == null) return null;

    final now = DateTime.now();
    final items = (payload['items'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
    final date =
        DateTime.tryParse(payload['date']?.toString() ?? '') ?? existing.date;
    final tax = double.tryParse(payload['tax_amount']?.toString() ?? '0') ?? 0;
    final discount =
        double.tryParse(payload['discount_amount']?.toString() ?? '0') ?? 0;

    double subtotal = 0;
    final itemModels = <InvoiceItemModel>[];
    for (final item in items) {
      final quantityStr = item['quantity']?.toString() ?? '0';
      final unitPriceStr = item['unit_price']?.toString() ?? '0';
      final qty = double.tryParse(quantityStr) ?? 0;
      final unitPrice = double.tryParse(unitPriceStr) ?? 0;
      final lineTotal = qty * unitPrice;
      subtotal += lineTotal;
      itemModels.add(
        InvoiceItemModel(
          id: item['id']?.toString() ?? '',
          itemId: item['item_id']?.toString(),
          itemName: item['item_name']?.toString() ?? '',
          quantity: quantityStr,
          unitPrice: unitPriceStr,
          totalPrice: _formatMoney(lineTotal),
        ),
      );
    }

    final total = subtotal + tax - discount;
    final existingPaid = double.tryParse(existing.paidAmount) ?? 0;
    if (existing.invoiceType == 'credit' && existingPaid > total) {
      return null;
    }
    final paidAmount = existing.invoiceType == 'cash' ? total : existingPaid;

    final updatedModel = InvoiceModel(
      id: existing.id,
      invoiceNumber: existing.invoiceNumber,
      customerId: existing.customerId,
      invoiceType: existing.invoiceType,
      date: date,
      subtotal: _formatMoney(subtotal),
      taxAmount: _formatMoney(tax),
      discountAmount: _formatMoney(discount),
      totalAmount: _formatMoney(total),
      paidAmount: _formatMoney(paidAmount),
      remarks: payload['remarks']?.toString() ?? existing.remarks,
      pdfPath: existing.pdfPath,
      items: itemModels,
      createdAt: existing.createdAt,
    );

    await _appDatabase
        .upsertInvoices([_invoiceCompanionFromModel(updatedModel)]);
    await _appDatabase.replaceInvoiceItems(
      invoiceServerId: existing.id,
      entries: _invoiceItemsCompanions(existing.id, itemModels),
    );

    if (existing.customerId != null && existing.invoiceType == 'credit') {
      await _upsertCustomerCreditTransaction(
        invoiceId: existing.id,
        customerId: existing.customerId!,
        amount: updatedModel.totalAmount,
        date: date,
        remarks: updatedModel.remarks,
        createdAt: now,
        isSynced: false,
      );
    }

    final localRow = await _appDatabase.findInvoiceByServerId(existing.id);
    final isUnsyncedLocal = localRow != null && localRow.isSynced == false;
    if (!isUnsyncedLocal) {
      await _syncQueue.enqueue(
        entityType: 'invoice',
        action: 'update',
        entityServerId: existing.id,
        data: {
          'invoice_id': existing.id,
          'date': date.toIso8601String(),
          'customer_id': existing.customerId,
          'items': _sanitizeInvoiceItemsForApi(items),
          'tax_amount': _formatMoney(tax),
          'discount_amount': _formatMoney(discount),
          if (updatedModel.remarks != null) 'remarks': updatedModel.remarks,
          'updated_at': now.toIso8601String(),
        },
      );
    } else {
      await _syncQueue.mergePendingCreatePayload(
        entityType: 'invoice',
        clientId: existing.id,
        updates: {
          'date': date.toIso8601String(),
          'items': _sanitizeInvoiceItemsForApi(items),
          'tax_amount': _formatMoney(tax),
          'discount_amount': _formatMoney(discount),
          if (updatedModel.remarks != null) 'remarks': updatedModel.remarks,
          'updated_at': now.toIso8601String(),
        },
      );
    }

    return updatedModel;
  }

  Future<void> _deleteInvoiceLocal(String invoiceId) async {
    await _appDatabase.deleteInvoiceByServerId(invoiceId);
    await _appDatabase.deleteCustomerTransactionsByReference(
      referenceType: 'invoice',
      referenceId: invoiceId,
    );
  }

  Future<InvoiceModel?> _loadLocalInvoice(String invoiceId) async {
    final local = await _appDatabase.findInvoiceByServerId(invoiceId);
    if (local == null) return null;
    final items = await _appDatabase.fetchInvoiceItems(invoiceId);
    return _invoiceFromRow(local, items);
  }

  Future<void> _upsertCustomerCreditTransaction({
    required String invoiceId,
    required String customerId,
    required String amount,
    required DateTime date,
    String? remarks,
    DateTime? createdAt,
    required bool isSynced,
  }) async {
    await _appDatabase.upsertCustomerTransactions([
      CustomerTransactionsCompanion(
        serverId: Value(isSynced ? invoiceId : null),
        clientId: Value(isSynced ? null : invoiceId),
        customerId: Value(customerId),
        transactionType: const Value('credit'),
        amount: Value(amount),
        date: Value(date),
        referenceId: Value(invoiceId),
        referenceType: const Value('invoice'),
        remarks: Value(remarks),
        createdAt: Value(createdAt),
        isSynced: Value(isSynced),
        syncStatus: Value(isSynced ? 'synced' : 'pending'),
      ),
    ]);
  }
}
