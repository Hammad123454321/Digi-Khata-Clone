import 'package:drift/drift.dart';
import 'package:drift_sqflite/drift_sqflite.dart';

part 'app_database.g.dart';

class Customers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverId => text().nullable().unique()();
  TextColumn get clientId => text().nullable().unique()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get balance => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
}

class Suppliers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverId => text().nullable().unique()();
  TextColumn get clientId => text().nullable().unique()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get balance => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
}

class ExpenseCategories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverId => text().nullable().unique()();
  TextColumn get clientId => text().nullable().unique()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
}

class SyncQueueEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text()();
  IntColumn get entityLocalId => integer().nullable()();
  TextColumn get entityServerId => text().nullable()();
  TextColumn get action => text()();
  TextColumn get payload => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();
  DateTimeColumn get nextAttemptAt => dateTime().nullable()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  BoolColumn get isDeadLetter => boolean().withDefault(const Constant(false))();
}

class Invoices extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverId => text().unique()();
  TextColumn get invoiceNumber => text()();
  TextColumn get customerId => text().nullable()();
  TextColumn get invoiceType => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get subtotal => text()();
  TextColumn get taxAmount => text()();
  TextColumn get discountAmount => text()();
  TextColumn get totalAmount => text()();
  TextColumn get paidAmount => text()();
  TextColumn get remarks => text().nullable()();
  TextColumn get pdfPath => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
}

class InvoiceItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverId => text().nullable().unique()();
  TextColumn get invoiceServerId => text()();
  TextColumn get itemId => text().nullable()();
  TextColumn get itemName => text()();
  TextColumn get quantity => text()();
  TextColumn get unitPrice => text()();
  TextColumn get totalPrice => text()();
}

class StockItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverId => text().nullable().unique()();
  TextColumn get clientId => text().nullable().unique()();
  TextColumn get name => text()();
  TextColumn get purchasePrice => text()();
  TextColumn get salePrice => text()();
  TextColumn get unit => text()();
  TextColumn get currentStock => text()();
  TextColumn get description => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
}

class InventoryTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverId => text().nullable().unique()();
  TextColumn get clientId => text().nullable().unique()();
  TextColumn get itemId => text()();
  TextColumn get transactionType => text()();
  TextColumn get quantity => text()();
  TextColumn get unitPrice => text().nullable()();
  DateTimeColumn get date => dateTime()();
  TextColumn get referenceId => text().nullable()();
  TextColumn get referenceType => text().nullable()();
  TextColumn get remarks => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
}

class CustomerTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverId => text().nullable().unique()();
  TextColumn get clientId => text().nullable().unique()();
  TextColumn get customerId => text()();
  TextColumn get transactionType => text()();
  TextColumn get amount => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get referenceId => text().nullable()();
  TextColumn get referenceType => text().nullable()();
  TextColumn get remarks => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
}

class SupplierTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverId => text().nullable().unique()();
  TextColumn get clientId => text().nullable().unique()();
  TextColumn get supplierId => text()();
  TextColumn get transactionType => text()();
  TextColumn get amount => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get referenceId => text().nullable()();
  TextColumn get referenceType => text().nullable()();
  TextColumn get remarks => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
}

class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverId => text().nullable().unique()();
  TextColumn get clientId => text().nullable().unique()();
  TextColumn get categoryId => text()();
  TextColumn get amount => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get paymentMode => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
}

class CashTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverId => text().nullable().unique()();
  TextColumn get clientId => text().nullable().unique()();
  TextColumn get transactionType => text()();
  TextColumn get amount => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get source => text().nullable()();
  TextColumn get remarks => text().nullable()();
  TextColumn get referenceId => text().nullable()();
  TextColumn get referenceType => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
}

class BankAccounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverId => text().nullable().unique()();
  TextColumn get clientId => text().nullable().unique()();
  TextColumn get bankName => text()();
  TextColumn get accountNumber => text()();
  TextColumn get accountHolderName => text().nullable()();
  TextColumn get branch => text().nullable()();
  TextColumn get ifscCode => text().nullable()();
  TextColumn get accountType => text().nullable()();
  TextColumn get openingBalance => text()();
  TextColumn get currentBalance => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
}

class BankTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverId => text().nullable().unique()();
  TextColumn get clientId => text().nullable().unique()();
  TextColumn get accountId => text()();
  TextColumn get transactionType => text()();
  TextColumn get amount => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get referenceNumber => text().nullable()();
  TextColumn get remarks => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
}

class Staffs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverId => text().nullable().unique()();
  TextColumn get clientId => text().nullable().unique()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get role => text().nullable()();
  TextColumn get address => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
}

class StaffSalaries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverId => text().nullable().unique()();
  TextColumn get clientId => text().nullable().unique()();
  TextColumn get staffId => text()();
  TextColumn get amount => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get paymentMode => text().nullable()();
  TextColumn get remarks => text().nullable()();
  TextColumn get referenceId => text().nullable()();
  TextColumn get referenceType => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
}

class Reminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverId => text().nullable().unique()();
  TextColumn get clientId => text().nullable().unique()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get entityDisplayName => text().named('entity_name').nullable()();
  TextColumn get entityPhone => text().nullable()();
  TextColumn get amount => text()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  TextColumn get message => text().nullable()();
  BoolColumn get isResolved => boolean().withDefault(const Constant(false))();
  DateTimeColumn get resolvedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
}

@DriftDatabase(tables: [
  Customers,
  Suppliers,
  ExpenseCategories,
  SyncQueueEntries,
  Invoices,
  InvoiceItems,
  StockItems,
  InventoryTransactions,
  CustomerTransactions,
  SupplierTransactions,
  Expenses,
  CashTransactions,
  BankAccounts,
  BankTransactions,
  Staffs,
  StaffSalaries,
  Reminders,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 13;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(invoices);
            await m.createTable(invoiceItems);
          }
          if (from < 3) {
            await m.addColumn(invoices, invoices.isSynced);
            await m.addColumn(invoices, invoices.syncStatus);
          }
          if (from < 4) {
            await m.createTable(stockItems);
          }
          if (from < 5) {
            await m.createTable(inventoryTransactions);
          }
          if (from < 6) {
            await m.createTable(suppliers);
            await m.createTable(supplierTransactions);
          }
          if (from < 7) {
            await m.createTable(expenseCategories);
            await m.createTable(expenses);
          }
          if (from < 8) {
            await m.createTable(cashTransactions);
          }
          if (from < 9) {
            await m.createTable(bankAccounts);
            await m.createTable(bankTransactions);
          }
          if (from < 10) {
            await m.createTable(staffs);
            await m.createTable(staffSalaries);
          }
          if (from < 11) {
            await m.createTable(reminders);
          }
          if (from < 12) {
            await m.createTable(customerTransactions);
          }
          if (from < 13) {
            await m.addColumn(syncQueueEntries, syncQueueEntries.lastAttemptAt);
            await m.addColumn(syncQueueEntries, syncQueueEntries.nextAttemptAt);
            await m.addColumn(syncQueueEntries, syncQueueEntries.isDeadLetter);
          }
        },
      );

  Future<List<Customer>> fetchCustomers({
    bool? isActive,
    String? search,
    int limit = 100,
    int offset = 0,
  }) async {
    final query = select(customers);
    if (isActive != null) {
      query.where((tbl) => tbl.isActive.equals(isActive));
    }
    if (search != null && search.trim().isNotEmpty) {
      final like = '%${search.trim()}%';
      query.where((tbl) => tbl.name.like(like));
    }
    query
      ..limit(limit, offset: offset)
      ..orderBy([
        (tbl) => OrderingTerm(expression: tbl.name, mode: OrderingMode.asc),
      ]);
    return query.get();
  }

  Future<void> upsertCustomers(List<CustomersCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(customers, entries);
    });
  }

  Future<void> upsertSuppliers(List<SuppliersCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(suppliers, entries);
    });
  }

  Future<void> upsertExpenseCategories(
    List<ExpenseCategoriesCompanion> entries,
  ) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(expenseCategories, entries);
    });
  }

  Future<void> upsertInvoices(List<InvoicesCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(invoices, entries);
    });
  }

  Future<void> replaceInvoiceItems({
    required String invoiceServerId,
    required List<InvoiceItemsCompanion> entries,
  }) async {
    await batch((batch) {
      batch.deleteWhere(
        invoiceItems,
        (tbl) => tbl.invoiceServerId.equals(invoiceServerId),
      );
      if (entries.isNotEmpty) {
        batch.insertAllOnConflictUpdate(invoiceItems, entries);
      }
    });
  }

  Future<List<Invoice>> fetchInvoices({
    DateTime? startDate,
    DateTime? endDate,
    String? customerId,
    String? invoiceType,
    int limit = 100,
    int offset = 0,
  }) async {
    final query = select(invoices);
    if (customerId != null) {
      query.where((tbl) => tbl.customerId.equals(customerId));
    }
    if (invoiceType != null) {
      query.where((tbl) => tbl.invoiceType.equals(invoiceType));
    }
    if (startDate != null) {
      query.where((tbl) => tbl.date.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      query.where((tbl) => tbl.date.isSmallerOrEqualValue(endDate));
    }
    query
      ..limit(limit, offset: offset)
      ..orderBy([
        (tbl) => OrderingTerm(expression: tbl.date, mode: OrderingMode.desc),
      ]);
    return query.get();
  }

  Future<Invoice?> findInvoiceByServerId(String serverId) {
    return (select(invoices)..where((tbl) => tbl.serverId.equals(serverId)))
        .getSingleOrNull();
  }

  Future<List<InvoiceItem>> fetchInvoiceItems(String invoiceServerId) {
    return (select(invoiceItems)
          ..where((tbl) => tbl.invoiceServerId.equals(invoiceServerId)))
        .get();
  }

  Future<void> upsertStockItems(List<StockItemsCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(stockItems, entries);
    });
  }

  Future<List<StockItem>> fetchStockItems({
    bool? isActive,
    String? search,
    int limit = 100,
    int offset = 0,
  }) async {
    final query = select(stockItems);
    if (isActive != null) {
      query.where((tbl) => tbl.isActive.equals(isActive));
    }
    if (search != null && search.trim().isNotEmpty) {
      final like = '%${search.trim()}%';
      query.where((tbl) => tbl.name.like(like));
    }
    query
      ..limit(limit, offset: offset)
      ..orderBy([
        (tbl) => OrderingTerm(expression: tbl.name, mode: OrderingMode.asc),
      ]);
    return query.get();
  }

  Future<int> updateStockItemByClientId({
    required String clientId,
    required StockItemsCompanion companion,
  }) {
    return (update(stockItems)..where((tbl) => tbl.clientId.equals(clientId)))
        .write(companion);
  }

  Future<int> updateStockItemByServerId({
    required String serverId,
    required StockItemsCompanion companion,
  }) {
    return (update(stockItems)..where((tbl) => tbl.serverId.equals(serverId)))
        .write(companion);
  }

  Future<StockItem?> findStockItemByAnyId(String id) {
    return (select(stockItems)
          ..where(
            (tbl) => tbl.serverId.equals(id) | tbl.clientId.equals(id),
          ))
        .getSingleOrNull();
  }

  Future<int> deleteStockItemByClientId(String clientId) {
    return (delete(stockItems)..where((tbl) => tbl.clientId.equals(clientId)))
        .go();
  }

  Future<List<Supplier>> fetchSuppliers({
    bool? isActive,
    String? search,
    int limit = 100,
    int offset = 0,
  }) async {
    final query = select(suppliers);
    if (isActive != null) {
      query.where((tbl) => tbl.isActive.equals(isActive));
    }
    if (search != null && search.trim().isNotEmpty) {
      final like = '%${search.trim()}%';
      query.where((tbl) => tbl.name.like(like));
    }
    query
      ..limit(limit, offset: offset)
      ..orderBy([
        (tbl) => OrderingTerm(expression: tbl.name, mode: OrderingMode.asc),
      ]);
    return query.get();
  }

  Future<int> updateSupplierByClientId({
    required String clientId,
    required SuppliersCompanion companion,
  }) {
    return (update(suppliers)..where((tbl) => tbl.clientId.equals(clientId)))
        .write(companion);
  }

  Future<int> updateSupplierByServerId({
    required String serverId,
    required SuppliersCompanion companion,
  }) {
    return (update(suppliers)..where((tbl) => tbl.serverId.equals(serverId)))
        .write(companion);
  }

  Future<Supplier?> findSupplierByAnyId(String id) {
    return (select(suppliers)
          ..where(
            (tbl) => tbl.serverId.equals(id) | tbl.clientId.equals(id),
          ))
        .getSingleOrNull();
  }

  Future<int> deleteSupplierByClientId(String clientId) {
    return (delete(suppliers)..where((tbl) => tbl.clientId.equals(clientId)))
        .go();
  }

  Future<int> updateSupplierTransactionsSupplierId({
    required String oldId,
    required String newId,
  }) {
    return (update(supplierTransactions)
          ..where((tbl) => tbl.supplierId.equals(oldId)))
        .write(SupplierTransactionsCompanion(supplierId: Value(newId)));
  }

  Future<int> updateExpensesCategoryId({
    required String oldId,
    required String newId,
  }) {
    return (update(expenses)..where((tbl) => tbl.categoryId.equals(oldId)))
        .write(ExpensesCompanion(categoryId: Value(newId)));
  }

  Future<void> upsertInventoryTransactions(
    List<InventoryTransactionsCompanion> entries,
  ) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(inventoryTransactions, entries);
    });
  }

  Future<int> updateInventoryTransactionByClientId({
    required String clientId,
    required InventoryTransactionsCompanion companion,
  }) {
    return (update(inventoryTransactions)
          ..where((tbl) => tbl.clientId.equals(clientId)))
        .write(companion);
  }

  Future<InventoryTransaction?> findInventoryTransactionByServerId(
    String serverId,
  ) {
    return (select(inventoryTransactions)
          ..where((tbl) => tbl.serverId.equals(serverId)))
        .getSingleOrNull();
  }

  Future<List<InventoryTransaction>> fetchInventoryTransactions({
    String? itemId,
    int limit = 100,
    int offset = 0,
  }) async {
    final query = select(inventoryTransactions);
    if (itemId != null) {
      query.where((tbl) => tbl.itemId.equals(itemId));
    }
    query
      ..limit(limit, offset: offset)
      ..orderBy([
        (tbl) => OrderingTerm(expression: tbl.date, mode: OrderingMode.desc),
      ]);
    return query.get();
  }

  Future<int> updateCustomerTransactionsCustomerId({
    required String oldId,
    required String newId,
  }) {
    return (update(customerTransactions)
          ..where((tbl) => tbl.customerId.equals(oldId)))
        .write(CustomerTransactionsCompanion(customerId: Value(newId)));
  }

  Future<int> updateInvoicesCustomerId({
    required String oldId,
    required String newId,
  }) {
    return (update(invoices)..where((tbl) => tbl.customerId.equals(oldId)))
        .write(InvoicesCompanion(customerId: Value(newId)));
  }

  Future<void> upsertCustomerTransactions(
    List<CustomerTransactionsCompanion> entries,
  ) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(customerTransactions, entries);
    });
  }

  Future<int> updateCustomerTransactionByClientId({
    required String clientId,
    required CustomerTransactionsCompanion companion,
  }) {
    return (update(customerTransactions)
          ..where((tbl) => tbl.clientId.equals(clientId)))
        .write(companion);
  }

  Future<int> updateCustomerTransactionByServerId({
    required String serverId,
    required CustomerTransactionsCompanion companion,
  }) {
    return (update(customerTransactions)
          ..where((tbl) => tbl.serverId.equals(serverId)))
        .write(companion);
  }

  Future<CustomerTransaction?> findCustomerTransactionByClientId(
    String clientId,
  ) {
    return (select(customerTransactions)
          ..where((tbl) => tbl.clientId.equals(clientId)))
        .getSingleOrNull();
  }

  Future<int> updateCustomerTransactionsReferenceId({
    required String oldId,
    required String newId,
  }) {
    return (update(customerTransactions)
          ..where(
            (tbl) =>
                tbl.referenceType.equals('invoice') &
                tbl.referenceId.equals(oldId),
          ))
        .write(CustomerTransactionsCompanion(referenceId: Value(newId)));
  }

  Future<CustomerTransaction?> findCustomerTransactionByServerId(
    String serverId,
  ) {
    return (select(customerTransactions)
          ..where((tbl) => tbl.serverId.equals(serverId)))
        .getSingleOrNull();
  }

  Future<List<CustomerTransaction>> fetchCustomerTransactions({
    String? customerId,
    int limit = 100,
    int offset = 0,
  }) async {
    final query = select(customerTransactions);
    if (customerId != null) {
      query.where((tbl) => tbl.customerId.equals(customerId));
    }
    query
      ..limit(limit, offset: offset)
      ..orderBy([
        (tbl) => OrderingTerm(expression: tbl.date, mode: OrderingMode.desc),
      ]);
    return query.get();
  }

  Future<int> deleteCustomerTransactionsByReference({
    required String referenceType,
    required String referenceId,
  }) {
    return (delete(customerTransactions)
          ..where(
            (tbl) =>
                tbl.referenceType.equals(referenceType) &
                tbl.referenceId.equals(referenceId),
          ))
        .go();
  }

  Future<int> deleteCustomerTransactionByServerId(String serverId) {
    return (delete(customerTransactions)
          ..where((tbl) => tbl.serverId.equals(serverId)))
        .go();
  }

  Future<int> deleteCustomerTransactionByClientId(String clientId) {
    return (delete(customerTransactions)
          ..where((tbl) => tbl.clientId.equals(clientId)))
        .go();
  }

  Future<void> upsertSupplierTransactions(
    List<SupplierTransactionsCompanion> entries,
  ) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(supplierTransactions, entries);
    });
  }

  Future<int> updateSupplierTransactionByClientId({
    required String clientId,
    required SupplierTransactionsCompanion companion,
  }) {
    return (update(supplierTransactions)
          ..where((tbl) => tbl.clientId.equals(clientId)))
        .write(companion);
  }

  Future<SupplierTransaction?> findSupplierTransactionByServerId(
    String serverId,
  ) {
    return (select(supplierTransactions)
          ..where((tbl) => tbl.serverId.equals(serverId)))
        .getSingleOrNull();
  }

  Future<List<SupplierTransaction>> fetchSupplierTransactions({
    String? supplierId,
    int limit = 100,
    int offset = 0,
  }) async {
    final query = select(supplierTransactions);
    if (supplierId != null) {
      query.where((tbl) => tbl.supplierId.equals(supplierId));
    }
    query
      ..limit(limit, offset: offset)
      ..orderBy([
        (tbl) => OrderingTerm(expression: tbl.date, mode: OrderingMode.desc),
      ]);
    return query.get();
  }

  Future<List<ExpenseCategory>> fetchExpenseCategories({
    bool? isActive,
    String? search,
    int limit = 100,
    int offset = 0,
  }) async {
    final query = select(expenseCategories);
    if (isActive != null) {
      query.where((tbl) => tbl.isActive.equals(isActive));
    }
    if (search != null && search.trim().isNotEmpty) {
      final like = '%${search.trim()}%';
      query.where((tbl) => tbl.name.like(like));
    }
    query
      ..limit(limit, offset: offset)
      ..orderBy([
        (tbl) => OrderingTerm(expression: tbl.name, mode: OrderingMode.asc),
      ]);
    return query.get();
  }

  Future<int> updateExpenseCategoryByClientId({
    required String clientId,
    required ExpenseCategoriesCompanion companion,
  }) {
    return (update(expenseCategories)
          ..where((tbl) => tbl.clientId.equals(clientId)))
        .write(companion);
  }

  Future<int> updateExpenseCategoryByServerId({
    required String serverId,
    required ExpenseCategoriesCompanion companion,
  }) {
    return (update(expenseCategories)
          ..where((tbl) => tbl.serverId.equals(serverId)))
        .write(companion);
  }

  Future<ExpenseCategory?> findExpenseCategoryByAnyId(String id) {
    return (select(expenseCategories)
          ..where(
            (tbl) => tbl.serverId.equals(id) | tbl.clientId.equals(id),
          ))
        .getSingleOrNull();
  }

  Future<void> upsertExpenses(List<ExpensesCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(expenses, entries);
    });
  }

  Future<Expense?> findExpenseByServerId(String serverId) {
    return (select(expenses)..where((tbl) => tbl.serverId.equals(serverId)))
        .getSingleOrNull();
  }

  Future<Expense?> findExpenseByAnyId(String id) {
    return (select(expenses)
          ..where(
            (tbl) => tbl.serverId.equals(id) | tbl.clientId.equals(id),
          ))
        .getSingleOrNull();
  }

  Future<int> updateExpenseByClientId({
    required String clientId,
    required ExpensesCompanion companion,
  }) {
    return (update(expenses)..where((tbl) => tbl.clientId.equals(clientId)))
        .write(companion);
  }

  Future<int> updateExpenseByServerId({
    required String serverId,
    required ExpensesCompanion companion,
  }) {
    return (update(expenses)..where((tbl) => tbl.serverId.equals(serverId)))
        .write(companion);
  }

  Future<List<Expense>> fetchExpenses({
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    int limit = 100,
    int offset = 0,
  }) async {
    final query = select(expenses);
    if (categoryId != null) {
      query.where((tbl) => tbl.categoryId.equals(categoryId));
    }
    if (startDate != null) {
      query.where((tbl) => tbl.date.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      query.where((tbl) => tbl.date.isSmallerOrEqualValue(endDate));
    }
    query
      ..limit(limit, offset: offset)
      ..orderBy([
        (tbl) => OrderingTerm(expression: tbl.date, mode: OrderingMode.desc),
      ]);
    return query.get();
  }

  Future<void> upsertCashTransactions(
    List<CashTransactionsCompanion> entries,
  ) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(cashTransactions, entries);
    });
  }

  Future<int> updateCashTransactionByClientId({
    required String clientId,
    required CashTransactionsCompanion companion,
  }) {
    return (update(cashTransactions)
          ..where((tbl) => tbl.clientId.equals(clientId)))
        .write(companion);
  }

  Future<CashTransaction?> findCashTransactionByServerId(String serverId) {
    return (select(cashTransactions)
          ..where((tbl) => tbl.serverId.equals(serverId)))
        .getSingleOrNull();
  }

  Future<List<CashTransaction>> fetchCashTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? transactionType,
    int limit = 100,
    int offset = 0,
  }) async {
    final query = select(cashTransactions);
    if (transactionType != null) {
      query.where((tbl) => tbl.transactionType.equals(transactionType));
    }
    if (startDate != null) {
      query.where((tbl) => tbl.date.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      query.where((tbl) => tbl.date.isSmallerOrEqualValue(endDate));
    }
    query
      ..limit(limit, offset: offset)
      ..orderBy([
        (tbl) => OrderingTerm(expression: tbl.date, mode: OrderingMode.desc),
      ]);
    return query.get();
  }

  Future<void> upsertBankAccounts(List<BankAccountsCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(bankAccounts, entries);
    });
  }

  Future<List<BankAccount>> fetchBankAccounts({
    bool? isActive,
    String? search,
    int limit = 100,
    int offset = 0,
  }) async {
    final query = select(bankAccounts);
    if (isActive != null) {
      query.where((tbl) => tbl.isActive.equals(isActive));
    }
    if (search != null && search.trim().isNotEmpty) {
      final like = '%${search.trim()}%';
      query.where(
        (tbl) =>
            tbl.bankName.like(like) |
            tbl.accountNumber.like(like) |
            tbl.accountHolderName.like(like),
      );
    }
    query
      ..limit(limit, offset: offset)
      ..orderBy([
        (tbl) => OrderingTerm(expression: tbl.bankName, mode: OrderingMode.asc),
      ]);
    return query.get();
  }

  Future<int> updateBankAccountByClientId({
    required String clientId,
    required BankAccountsCompanion companion,
  }) {
    return (update(bankAccounts)..where((tbl) => tbl.clientId.equals(clientId)))
        .write(companion);
  }

  Future<int> updateBankAccountByServerId({
    required String serverId,
    required BankAccountsCompanion companion,
  }) {
    return (update(bankAccounts)..where((tbl) => tbl.serverId.equals(serverId)))
        .write(companion);
  }

  Future<BankAccount?> findBankAccountByAnyId(String id) {
    return (select(bankAccounts)
          ..where(
            (tbl) => tbl.serverId.equals(id) | tbl.clientId.equals(id),
          ))
        .getSingleOrNull();
  }

  Future<int> updateBankTransactionsAccountId({
    required String oldId,
    required String newId,
  }) {
    return (update(bankTransactions)
          ..where((tbl) => tbl.accountId.equals(oldId)))
        .write(BankTransactionsCompanion(accountId: Value(newId)));
  }

  Future<void> upsertBankTransactions(
    List<BankTransactionsCompanion> entries,
  ) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(bankTransactions, entries);
    });
  }

  Future<int> updateBankTransactionByClientId({
    required String clientId,
    required BankTransactionsCompanion companion,
  }) {
    return (update(bankTransactions)
          ..where((tbl) => tbl.clientId.equals(clientId)))
        .write(companion);
  }

  Future<BankTransaction?> findBankTransactionByServerId(String serverId) {
    return (select(bankTransactions)
          ..where((tbl) => tbl.serverId.equals(serverId)))
        .getSingleOrNull();
  }

  Future<List<BankTransaction>> fetchBankTransactions({
    String? accountId,
    DateTime? startDate,
    DateTime? endDate,
    String? transactionType,
    int limit = 100,
    int offset = 0,
  }) async {
    final query = select(bankTransactions);
    if (accountId != null) {
      query.where((tbl) => tbl.accountId.equals(accountId));
    }
    if (transactionType != null) {
      query.where((tbl) => tbl.transactionType.equals(transactionType));
    }
    if (startDate != null) {
      query.where((tbl) => tbl.date.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      query.where((tbl) => tbl.date.isSmallerOrEqualValue(endDate));
    }
    query
      ..limit(limit, offset: offset)
      ..orderBy([
        (tbl) => OrderingTerm(expression: tbl.date, mode: OrderingMode.desc),
      ]);
    return query.get();
  }

  Future<void> upsertStaffs(List<StaffsCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(staffs, entries);
    });
  }

  Future<List<Staff>> fetchStaffs({
    bool? isActive,
    String? search,
    int limit = 100,
    int offset = 0,
  }) async {
    final query = select(staffs);
    if (isActive != null) {
      query.where((tbl) => tbl.isActive.equals(isActive));
    }
    if (search != null && search.trim().isNotEmpty) {
      final like = '%${search.trim()}%';
      query.where(
        (tbl) =>
            tbl.name.like(like) | tbl.phone.like(like) | tbl.email.like(like),
      );
    }
    query
      ..limit(limit, offset: offset)
      ..orderBy([
        (tbl) => OrderingTerm(expression: tbl.name, mode: OrderingMode.asc),
      ]);
    return query.get();
  }

  Future<int> updateStaffByClientId({
    required String clientId,
    required StaffsCompanion companion,
  }) {
    return (update(staffs)..where((tbl) => tbl.clientId.equals(clientId)))
        .write(companion);
  }

  Future<int> updateStaffByServerId({
    required String serverId,
    required StaffsCompanion companion,
  }) {
    return (update(staffs)..where((tbl) => tbl.serverId.equals(serverId)))
        .write(companion);
  }

  Future<Staff?> findStaffByAnyId(String id) {
    return (select(staffs)
          ..where(
            (tbl) => tbl.serverId.equals(id) | tbl.clientId.equals(id),
          ))
        .getSingleOrNull();
  }

  Future<void> upsertStaffSalaries(
    List<StaffSalariesCompanion> entries,
  ) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(staffSalaries, entries);
    });
  }

  Future<int> updateStaffSalaryByClientId({
    required String clientId,
    required StaffSalariesCompanion companion,
  }) {
    return (update(staffSalaries)
          ..where((tbl) => tbl.clientId.equals(clientId)))
        .write(companion);
  }

  Future<StaffSalary?> findStaffSalaryByServerId(String serverId) {
    return (select(staffSalaries)
          ..where((tbl) => tbl.serverId.equals(serverId)))
        .getSingleOrNull();
  }

  Future<List<StaffSalary>> fetchStaffSalaries({
    String? staffId,
    int limit = 100,
    int offset = 0,
  }) async {
    final query = select(staffSalaries);
    if (staffId != null) {
      query.where((tbl) => tbl.staffId.equals(staffId));
    }
    query
      ..limit(limit, offset: offset)
      ..orderBy([
        (tbl) => OrderingTerm(expression: tbl.date, mode: OrderingMode.desc),
      ]);
    return query.get();
  }

  Future<int> updateStaffSalariesStaffId({
    required String oldId,
    required String newId,
  }) {
    return (update(staffSalaries)..where((tbl) => tbl.staffId.equals(oldId)))
        .write(StaffSalariesCompanion(staffId: Value(newId)));
  }

  Future<void> upsertReminders(List<RemindersCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(reminders, entries);
    });
  }

  Future<int> updateReminderByClientId({
    required String clientId,
    required RemindersCompanion companion,
  }) {
    return (update(reminders)..where((tbl) => tbl.clientId.equals(clientId)))
        .write(companion);
  }

  Future<int> updateReminderByServerId({
    required String serverId,
    required RemindersCompanion companion,
  }) {
    return (update(reminders)..where((tbl) => tbl.serverId.equals(serverId)))
        .write(companion);
  }

  Future<Reminder?> findReminderByAnyId(String id) {
    return (select(reminders)
          ..where(
            (tbl) => tbl.serverId.equals(id) | tbl.clientId.equals(id),
          ))
        .getSingleOrNull();
  }

  Future<Reminder?> findReminderByServerId(String serverId) {
    return (select(reminders)..where((tbl) => tbl.serverId.equals(serverId)))
        .getSingleOrNull();
  }

  Future<List<Reminder>> fetchReminders({
    String? entityType,
    bool? isResolved,
    int limit = 100,
    int offset = 0,
  }) async {
    final query = select(reminders);
    if (entityType != null && entityType.trim().isNotEmpty) {
      query.where((tbl) => tbl.entityType.equals(entityType));
    }
    if (isResolved != null) {
      query.where((tbl) => tbl.isResolved.equals(isResolved));
    }
    query
      ..limit(limit, offset: offset)
      ..orderBy([
        (tbl) =>
            OrderingTerm(expression: tbl.createdAt, mode: OrderingMode.desc),
      ]);
    return query.get();
  }

  Future<List<CashTransaction>> fetchPendingCashTransactions({
    required DateTime date,
    String? transactionType,
    String? source,
    String? referenceType,
    String? referenceId,
  }) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start
        .add(const Duration(days: 1))
        .subtract(const Duration(milliseconds: 1));
    final query = select(cashTransactions)
      ..where((tbl) => tbl.isSynced.equals(false))
      ..where((tbl) => tbl.date.isBiggerOrEqualValue(start))
      ..where((tbl) => tbl.date.isSmallerOrEqualValue(end));

    if (transactionType != null) {
      query.where((tbl) => tbl.transactionType.equals(transactionType));
    }
    if (source != null) {
      query.where((tbl) => tbl.source.equals(source));
    }
    if (referenceType != null) {
      query.where((tbl) => tbl.referenceType.equals(referenceType));
    }
    if (referenceId != null) {
      query.where((tbl) => tbl.referenceId.equals(referenceId));
    }

    return query.get();
  }

  Future<List<BankTransaction>> fetchPendingBankTransactions({
    required DateTime date,
    String? transactionType,
    String? accountId,
  }) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start
        .add(const Duration(days: 1))
        .subtract(const Duration(milliseconds: 1));
    final query = select(bankTransactions)
      ..where((tbl) => tbl.isSynced.equals(false))
      ..where((tbl) => tbl.date.isBiggerOrEqualValue(start))
      ..where((tbl) => tbl.date.isSmallerOrEqualValue(end));

    if (transactionType != null) {
      query.where((tbl) => tbl.transactionType.equals(transactionType));
    }
    if (accountId != null) {
      query.where((tbl) => tbl.accountId.equals(accountId));
    }

    return query.get();
  }

  Future<int> updateCustomerByClientId({
    required String clientId,
    required CustomersCompanion companion,
  }) {
    return (update(customers)..where((tbl) => tbl.clientId.equals(clientId)))
        .write(companion);
  }

  Future<int> updateCustomerByServerId({
    required String serverId,
    required CustomersCompanion companion,
  }) {
    return (update(customers)..where((tbl) => tbl.serverId.equals(serverId)))
        .write(companion);
  }

  Future<Customer?> findCustomerByAnyId(String id) {
    return (select(customers)
          ..where(
            (tbl) => tbl.serverId.equals(id) | tbl.clientId.equals(id),
          ))
        .getSingleOrNull();
  }

  Future<int> deleteCustomerByClientId(String clientId) {
    return (delete(customers)..where((tbl) => tbl.clientId.equals(clientId)))
        .go();
  }

  Future<void> clearAllData() async {
    await transaction(() async {
      await delete(syncQueueEntries).go();
      await delete(reminders).go();
      await delete(staffSalaries).go();
      await delete(staffs).go();
      await delete(bankTransactions).go();
      await delete(bankAccounts).go();
      await delete(cashTransactions).go();
      await delete(expenses).go();
      await delete(expenseCategories).go();
      await delete(supplierTransactions).go();
      await delete(customerTransactions).go();
      await delete(inventoryTransactions).go();
      await delete(stockItems).go();
      await delete(invoiceItems).go();
      await delete(invoices).go();
      await delete(suppliers).go();
      await delete(customers).go();
    });
  }

  Future<void> updateInvoiceServerId({
    required String oldId,
    required String newId,
    required InvoicesCompanion companion,
  }) async {
    await transaction(() async {
      await (update(invoices)..where((tbl) => tbl.serverId.equals(oldId)))
          .write(companion);
      await (update(invoiceItems)
            ..where((tbl) => tbl.invoiceServerId.equals(oldId)))
          .write(InvoiceItemsCompanion(invoiceServerId: Value(newId)));
    });
  }

  Future<void> deleteInvoiceByServerId(String serverId) async {
    await transaction(() async {
      await (delete(invoiceItems)
            ..where((tbl) => tbl.invoiceServerId.equals(serverId)))
          .go();
      await (delete(invoices)..where((tbl) => tbl.serverId.equals(serverId)))
          .go();
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    return SqfliteQueryExecutor.inDatabaseFolder(
      path: 'enshaal_khata.sqlite',
      logStatements: false,
    );
  });
}
