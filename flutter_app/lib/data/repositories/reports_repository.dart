import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/result.dart';
import '../../core/constants/api_constants.dart';
import '../../core/database/app_database.dart';
import '../../core/utils/date_utils.dart';

/// Reports Repository
class ReportsRepository {
  ReportsRepository({
    required ApiClient apiClient,
    required AppDatabase appDatabase,
  })  : _apiClient = apiClient,
        _appDatabase = appDatabase;

  final ApiClient _apiClient;
  final AppDatabase _appDatabase;

  /// Get sales report
  Future<Result<Map<String, dynamic>>> getSalesReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.reportsSales,
        queryParameters: {
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
          'start_datetime': startDate.toIso8601String(),
          'end_datetime': endDate.toIso8601String(),
        },
      );

      return Result.success(response.data as Map<String, dynamic>);
    } on AppException catch (e) {
      if (e is NetworkException || e is TimeoutException) {
        final report = await _buildLocalSalesReport(startDate, endDate);
        return Result.success(report);
      }
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  /// Get cash flow report
  Future<Result<Map<String, dynamic>>> getCashFlowReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.reportsCashFlow,
        queryParameters: {
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
          'start_datetime': startDate.toIso8601String(),
          'end_datetime': endDate.toIso8601String(),
        },
      );

      return Result.success(response.data as Map<String, dynamic>);
    } on AppException catch (e) {
      if (e is NetworkException || e is TimeoutException) {
        final report = await _buildLocalCashFlowReport(startDate, endDate);
        return Result.success(report);
      }
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  /// Get expense report
  Future<Result<Map<String, dynamic>>> getExpenseReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.reportsExpenses,
        queryParameters: {
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
          'start_datetime': startDate.toIso8601String(),
          'end_datetime': endDate.toIso8601String(),
        },
      );

      return Result.success(response.data as Map<String, dynamic>);
    } on AppException catch (e) {
      if (e is NetworkException || e is TimeoutException) {
        final report = await _buildLocalExpenseReport(startDate, endDate);
        return Result.success(report);
      }
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  /// Get stock report
  Future<Result<Map<String, dynamic>>> getStockReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.reportsStock,
        queryParameters: {
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
          'start_datetime': startDate.toIso8601String(),
          'end_datetime': endDate.toIso8601String(),
        },
      );

      return Result.success(response.data as Map<String, dynamic>);
    } on AppException catch (e) {
      if (e is NetworkException || e is TimeoutException) {
        final report = await _buildLocalStockReport(startDate, endDate);
        return Result.success(report);
      }
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  /// Get profit & loss report
  Future<Result<Map<String, dynamic>>> getProfitLossReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.reportsProfitLoss,
        queryParameters: {
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
          'start_datetime': startDate.toIso8601String(),
          'end_datetime': endDate.toIso8601String(),
        },
      );

      return Result.success(response.data as Map<String, dynamic>);
    } on AppException catch (e) {
      if (e is NetworkException || e is TimeoutException) {
        final report = await _buildLocalProfitLossReport(startDate, endDate);
        return Result.success(report);
      }
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  Future<Map<String, dynamic>> _buildLocalSalesReport(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final rangeStart = AppDateUtils.normalizeToStartOfDay(startDate);
    final rangeEnd = AppDateUtils.normalizeToStartOfDay(endDate)
        .add(const Duration(days: 1))
        .subtract(const Duration(milliseconds: 1));

    final invoices = await _appDatabase.fetchInvoices(
      startDate: rangeStart,
      endDate: rangeEnd,
      limit: 1000000,
    );
    final customers = await _appDatabase.fetchCustomers(limit: 1000000);
    final customerNameById = <String, String>{};
    for (final customer in customers) {
      if (customer.serverId != null && customer.serverId!.trim().isNotEmpty) {
        customerNameById[customer.serverId!] = customer.name;
      }
      if (customer.clientId != null && customer.clientId!.trim().isNotEmpty) {
        customerNameById[customer.clientId!] = customer.name;
      }
      customerNameById[customer.id.toString()] = customer.name;
    }

    double totalSales = 0;
    double cashSales = 0;
    double creditSales = 0;

    final daily = <DateTime, _SalesBucket>{};
    final weekly = <DateTime, _SalesBucket>{};
    final monthly = <DateTime, _SalesBucket>{};

    for (final invoice in invoices) {
      final amount = _parseAmount(invoice.totalAmount);
      totalSales += amount;
      if (invoice.invoiceType == 'cash') {
        cashSales += amount;
      } else {
        creditSales += amount;
      }

      final dayKey = AppDateUtils.normalizeToStartOfDay(invoice.date);
      final weekKey = _startOfWeek(invoice.date);
      final monthKey = DateTime(invoice.date.year, invoice.date.month);

      _addSalesBucket(daily, dayKey, invoice.invoiceType, amount);
      _addSalesBucket(weekly, weekKey, invoice.invoiceType, amount);
      _addSalesBucket(monthly, monthKey, invoice.invoiceType, amount);
    }

    final invoiceReferenceRows = invoices
        .map(
          (invoice) => <String, dynamic>{
            'reference_type': 'invoice',
            'reference_id': invoice.serverId,
            'invoice_number': invoice.invoiceNumber,
            'invoice_date': invoice.date.toIso8601String(),
            'customer_name': customerNameById[invoice.customerId ?? ''] ??
                'Unknown Customer',
            'invoice_type': invoice.invoiceType,
            'invoice_total': invoice.totalAmount,
            'invoice_status': invoice.invoiceType == 'cash'
                ? 'paid'
                : (_parseAmount(invoice.paidAmount) >=
                        _parseAmount(invoice.totalAmount)
                    ? 'paid'
                    : (_parseAmount(invoice.paidAmount) > 0
                        ? 'partially_paid'
                        : 'unpaid')),
          },
        )
        .toList(growable: false);

    return {
      'total_sales': totalSales.toStringAsFixed(2),
      'cash_sales': cashSales.toStringAsFixed(2),
      'credit_sales': creditSales.toStringAsFixed(2),
      'total_invoices': invoices.length,
      'daily_breakdown': _buildSalesBreakdown(daily, period: 'day'),
      'weekly_breakdown': _buildSalesBreakdown(weekly, period: 'week'),
      'monthly_breakdown': _buildSalesBreakdown(monthly, period: 'month'),
      'invoice_reference_rows': invoiceReferenceRows,
      'reference_rows': invoiceReferenceRows,
      'is_offline': true,
    };
  }

  Future<Map<String, dynamic>> _buildLocalCashFlowReport(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final rangeStart = AppDateUtils.normalizeToStartOfDay(startDate);
    final rangeEnd = AppDateUtils.normalizeToStartOfDay(endDate)
        .add(const Duration(days: 1))
        .subtract(const Duration(milliseconds: 1));

    final beforeTransactions = await _appDatabase.fetchCashTransactions(
      endDate: rangeStart.subtract(const Duration(milliseconds: 1)),
      limit: 1000000,
    );
    final transactions = await _appDatabase.fetchCashTransactions(
      startDate: rangeStart,
      endDate: rangeEnd,
      limit: 1000000,
    );

    final openingBalance = _computeCashBalance(beforeTransactions);
    final totals = _computeCashTotals(transactions);
    final closingBalance = openingBalance + totals.totalIn - totals.totalOut;

    final txns = transactions.map((txn) {
      final amount = _parseAmount(txn.amount);
      final isInflow = txn.transactionType == 'cash_in';
      return {
        'amount': amount.abs().toStringAsFixed(2),
        'type': isInflow ? 'inflow' : 'outflow',
        'date': txn.date.toIso8601String(),
        'description': txn.remarks ?? txn.source ?? 'Transaction',
      };
    }).toList();

    return {
      'opening_balance': openingBalance.toStringAsFixed(2),
      'closing_balance': closingBalance.toStringAsFixed(2),
      'total_inflow': totals.totalIn.toStringAsFixed(2),
      'total_outflow': totals.totalOut.toStringAsFixed(2),
      'transactions': txns,
      'reference_rows': txns,
      'is_offline': true,
    };
  }

  Future<Map<String, dynamic>> _buildLocalExpenseReport(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final rangeStart = AppDateUtils.normalizeToStartOfDay(startDate);
    final rangeEnd = AppDateUtils.normalizeToStartOfDay(endDate)
        .add(const Duration(days: 1))
        .subtract(const Duration(milliseconds: 1));

    final expenses = await _appDatabase.fetchExpenses(
      startDate: rangeStart,
      endDate: rangeEnd,
      limit: 1000000,
    );
    final categories = await _appDatabase.fetchExpenseCategories();
    final categoryMap = {
      for (final category in categories)
        category.serverId ?? category.clientId ?? category.id.toString():
            category.name,
    };

    double total = 0;
    double cash = 0;
    double bank = 0;
    final categoryTotals = <String, double>{};
    final dailyTotals = <DateTime, double>{};

    for (final expense in expenses) {
      final amount = _parseAmount(expense.amount);
      total += amount;
      if (expense.paymentMode == 'bank') {
        bank += amount;
      } else {
        cash += amount;
      }
      final categoryId = expense.categoryId;
      categoryTotals[categoryId] = (categoryTotals[categoryId] ?? 0) + amount;
      final dayKey = AppDateUtils.normalizeToStartOfDay(expense.date);
      dailyTotals[dayKey] = (dailyTotals[dayKey] ?? 0) + amount;
    }

    final categoryBreakdown = categoryTotals.entries.map((entry) {
      return {
        'category_name': categoryMap[entry.key] ?? 'Uncategorized',
        'amount': entry.value.toStringAsFixed(2),
      };
    }).toList()
      ..sort((a, b) {
        final bAmount = _parseAmount(b['amount']?.toString());
        final aAmount = _parseAmount(a['amount']?.toString());
        return bAmount.compareTo(aAmount);
      });

    final dailyBreakdown = dailyTotals.entries.map((entry) {
      return {
        'date': entry.key.toIso8601String(),
        'amount': entry.value.toStringAsFixed(2),
      };
    }).toList()
      ..sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));

    return {
      'total_expenses': total.toStringAsFixed(2),
      'cash_expenses': cash.toStringAsFixed(2),
      'bank_expenses': bank.toStringAsFixed(2),
      'total_count': expenses.length,
      'category_breakdown': categoryBreakdown,
      'daily_breakdown': dailyBreakdown,
      'reference_rows': expenses
          .map((expense) => <String, dynamic>{
                'reference_type': 'expense',
                'reference_id': expense.serverId,
                'date': expense.date.toIso8601String(),
                'amount': expense.amount,
                'payment_mode': expense.paymentMode,
                'category': categoryMap[expense.categoryId] ?? 'Uncategorized',
                'description': expense.description ?? 'Expense',
              })
          .toList(growable: false),
      'is_offline': true,
    };
  }

  Future<Map<String, dynamic>> _buildLocalStockReport(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final rangeStart = AppDateUtils.normalizeToStartOfDay(startDate);
    final rangeEnd = AppDateUtils.normalizeToStartOfDay(endDate)
        .add(const Duration(days: 1))
        .subtract(const Duration(milliseconds: 1));
    final daysInRange = rangeEnd.difference(rangeStart).inDays <= 0
        ? 1
        : rangeEnd.difference(rangeStart).inDays + 1;

    final items = await _appDatabase.fetchStockItems(
      isActive: true,
      limit: 1000000,
    );
    final transactions = await _appDatabase.fetchInventoryTransactions(
      limit: 1000000,
    );
    final invoices = await _appDatabase.fetchInvoices(
      startDate: rangeStart,
      endDate: rangeEnd,
      limit: 1000000,
    );
    final customers = await _appDatabase.fetchCustomers(limit: 1000000);

    final itemByCanonicalId = <String, StockItem>{};
    final itemIdentityToCanonicalId = <String, String>{};
    for (final item in items) {
      final canonicalId = item.serverId ?? item.clientId ?? item.id.toString();
      itemByCanonicalId[canonicalId] = item;
      final identities = <String?>[
        canonicalId,
        item.serverId,
        item.clientId,
        item.id.toString(),
      ];
      for (final identity in identities) {
        if (identity == null || identity.trim().isEmpty) continue;
        itemIdentityToCanonicalId[identity] = canonicalId;
      }
    }

    final txByItem = <String, List<InventoryTransaction>>{};
    for (final txn in transactions) {
      final canonicalId = itemIdentityToCanonicalId[txn.itemId] ?? txn.itemId;
      if (!itemByCanonicalId.containsKey(canonicalId)) continue;
      txByItem.putIfAbsent(canonicalId, () => []).add(txn);
    }
    for (final entry in txByItem.values) {
      entry.sort((a, b) => a.date.compareTo(b.date));
    }

    final customerNameById = <String, String>{};
    for (final customer in customers) {
      final customerName = customer.name.trim().isEmpty
          ? 'Unknown Customer'
          : customer.name.trim();
      final customerIds = <String?>[
        customer.serverId,
        customer.clientId,
        customer.id.toString(),
      ];
      for (final customerId in customerIds) {
        if (customerId == null || customerId.trim().isEmpty) continue;
        customerNameById[customerId] = customerName;
      }
    }

    String resolveCustomerName(String? customerId) {
      if (customerId == null || customerId.trim().isEmpty) {
        return 'Unknown Customer';
      }
      return customerNameById[customerId] ?? 'Unknown Customer';
    }

    final soldByItem = <String, _LocalSoldAggregate>{};
    final soldCustomerBreakdownByItem =
        <String, Map<String, _LocalCustomerAggregate>>{};
    final invoiceReferenceRows = <Map<String, dynamic>>[];
    var soldEntriesCount = 0;
    for (final invoice in invoices) {
      final invoiceId = invoice.serverId;
      if (invoiceId.trim().isEmpty) continue;
      final customerName = resolveCustomerName(invoice.customerId);
      final invoiceItems = await _appDatabase.fetchInvoiceItems(invoiceId);
      var invoiceSoldQty = 0.0;
      var invoiceSoldAmount = 0.0;
      for (final invoiceItem in invoiceItems) {
        final rawItemId = invoiceItem.itemId;
        if (rawItemId == null || rawItemId.trim().isEmpty) continue;
        final canonicalId = itemIdentityToCanonicalId[rawItemId];
        if (canonicalId == null ||
            !itemByCanonicalId.containsKey(canonicalId)) {
          continue;
        }

        final soldQty = _parseAmount(invoiceItem.quantity);
        final soldAmount = _parseAmount(invoiceItem.totalPrice);
        if (soldQty <= 0) continue;
        invoiceSoldQty += soldQty;
        invoiceSoldAmount += soldAmount;

        soldEntriesCount += 1;
        final soldAggregate =
            soldByItem.putIfAbsent(canonicalId, _LocalSoldAggregate.new);
        soldAggregate.qty += soldQty;
        soldAggregate.amount += soldAmount;
        soldAggregate.invoiceIds.add(invoiceId);
        if (soldAggregate.lastSaleAt == null ||
            invoice.date.isAfter(soldAggregate.lastSaleAt!)) {
          soldAggregate.lastSaleAt = invoice.date;
        }

        final customerBreakdown = soldCustomerBreakdownByItem.putIfAbsent(
          canonicalId,
          () => {},
        );
        final customerAggregate = customerBreakdown.putIfAbsent(
          customerName,
          () => _LocalCustomerAggregate(customerName),
        );
        customerAggregate.qty += soldQty;
        customerAggregate.amount += soldAmount;
        customerAggregate.invoiceIds.add(invoiceId);
        if (customerAggregate.lastSaleAt == null ||
            invoice.date.isAfter(customerAggregate.lastSaleAt!)) {
          customerAggregate.lastSaleAt = invoice.date;
        }
      }

      if (invoiceSoldQty > 0) {
        final totalAmount = _parseAmount(invoice.totalAmount);
        final paidAmount = _parseAmount(invoice.paidAmount);
        final status = invoice.invoiceType == 'cash'
            ? 'paid'
            : (paidAmount >= totalAmount
                ? 'paid'
                : (paidAmount > 0 ? 'partially_paid' : 'unpaid'));
        invoiceReferenceRows.add({
          'reference_type': 'invoice',
          'reference_id': invoiceId,
          'invoice_number': invoice.invoiceNumber,
          'invoice_date': invoice.date.toIso8601String(),
          'customer_name': customerName,
          'sold_qty': invoiceSoldQty.toStringAsFixed(3),
          'sold_amount': invoiceSoldAmount.toStringAsFixed(2),
          'status': status,
          'last_sale_at': invoice.date.toIso8601String(),
        });
      }
    }

    double totalStockValue = 0;
    double totalSoldQty = 0;
    double totalSoldValue = 0;
    double totalEstimatedMargin = 0;
    double totalCogs = 0;
    double totalLeftQty = 0;
    int outOfStockCount = 0;
    int deadStockCount = 0;
    final movementSummary = <String, Map<String, num>>{
      'all': {'entries': 0, 'qty': 0.0, 'amount': 0.0},
      'in': {'entries': 0, 'qty': 0.0, 'amount': 0.0},
      'out': {'entries': 0, 'qty': 0.0, 'amount': 0.0},
    };
    final movementEntries = <Map<String, dynamic>>[];

    final fastMoving = <Map<String, dynamic>>[];
    final deadStockItems = <Map<String, dynamic>>[];
    final soldItemsPayload = <Map<String, dynamic>>[];
    final itemMaps = <Map<String, dynamic>>[];

    for (final item in items) {
      final canonicalId = item.serverId ?? item.clientId ?? item.id.toString();
      final itemTxns = txByItem[canonicalId] ?? const <InventoryTransaction>[];

      double purchasedQty = 0;
      double soldQty = 0;
      double stockOutQty = 0;
      double wastageQty = 0;
      int adjustmentEvents = 0;
      final purchasePrice = _parseAmount(item.purchasePrice);
      final salePrice = _parseAmount(item.salePrice);

      for (final txn in itemTxns) {
        if (txn.date.isBefore(rangeStart) || txn.date.isAfter(rangeEnd)) {
          continue;
        }
        final qty = _parseAmount(txn.quantity);
        String? direction;
        var rate = _parseAmount(txn.unitPrice);
        switch (txn.transactionType) {
          case 'stock_in':
            purchasedQty += qty;
            direction = 'in';
            if (rate <= 0) rate = purchasePrice;
            break;
          case 'stock_out':
            stockOutQty += qty;
            direction = 'out';
            if (rate <= 0) {
              rate = txn.referenceType == 'invoice' ? salePrice : purchasePrice;
            }
            break;
          case 'wastage':
            wastageQty += qty;
            direction = 'out';
            if (rate <= 0) rate = purchasePrice;
            break;
          case 'adjustment':
            adjustmentEvents += 1;
            break;
        }

        if (direction != null && qty > 0) {
          final amount = qty * rate;
          movementSummary[direction]!['entries'] =
              (movementSummary[direction]!['entries'] as int) + 1;
          movementSummary[direction]!['qty'] =
              (movementSummary[direction]!['qty'] as double) + qty;
          movementSummary[direction]!['amount'] =
              (movementSummary[direction]!['amount'] as double) + amount;

          movementSummary['all']!['entries'] =
              (movementSummary['all']!['entries'] as int) + 1;
          movementSummary['all']!['qty'] =
              (movementSummary['all']!['qty'] as double) + qty;
          movementSummary['all']!['amount'] =
              (movementSummary['all']!['amount'] as double) + amount;

          movementEntries.add({
            'item_id': canonicalId,
            'name': item.name,
            'unit': item.unit,
            'direction': direction,
            'transaction_type': txn.transactionType,
            'quantity': qty.toStringAsFixed(3),
            'rate': rate.toStringAsFixed(2),
            'amount': amount.toStringAsFixed(2),
            'date': txn.date.toIso8601String(),
            'reference_type': txn.referenceType,
            'reference_id': txn.referenceId,
            'remarks': txn.remarks,
          });
        }
      }

      final soldAggregate = soldByItem[canonicalId];
      soldQty = soldAggregate?.qty ?? 0;
      final soldValue = soldAggregate?.amount ?? 0;
      final closingStock = _parseAmount(item.currentStock);
      final openingStock =
          closingStock - purchasedQty + stockOutQty + wastageQty;
      final stockValue = closingStock * purchasePrice;
      final estimatedCogs = soldQty * purchasePrice;
      final estimatedMargin = soldValue - estimatedCogs;
      final velocity = soldQty / daysInRange;
      final daysLeft =
          velocity > 0 && closingStock > 0 ? closingStock / velocity : null;

      if (closingStock > 0) {
        totalLeftQty += closingStock;
      }
      totalStockValue += stockValue;
      totalSoldQty += soldQty;
      totalSoldValue += soldValue;
      totalEstimatedMargin += estimatedMargin;
      totalCogs += estimatedCogs;

      final isOut = closingStock <= 0;
      if (isOut) outOfStockCount += 1;

      final isDead = soldQty <= 0 && closingStock > 0;
      if (isDead) {
        deadStockCount += 1;
        deadStockItems.add({
          'id': canonicalId,
          'name': item.name,
          'closing_stock': closingStock.toStringAsFixed(2),
          'stock_value': stockValue.toStringAsFixed(2),
          'unit': item.unit,
        });
      }

      if (soldQty > 0) {
        fastMoving.add({
          'id': canonicalId,
          'name': item.name,
          'sold_qty': soldQty.toStringAsFixed(2),
          'sold_value': soldValue.toStringAsFixed(2),
          'unit': item.unit,
        });

        final avgSaleRate = soldValue / soldQty;
        soldItemsPayload.add({
          'item_id': canonicalId,
          'item_name': item.name,
          'unit': item.unit,
          'sold_qty': soldQty.toStringAsFixed(3),
          'sold_amount': soldValue.toStringAsFixed(2),
          'avg_sale_rate': avgSaleRate.toStringAsFixed(2),
          'left_qty': closingStock.toStringAsFixed(3),
          'left_value': stockValue.toStringAsFixed(2),
          'gross_profit': estimatedMargin.toStringAsFixed(2),
        });
      }

      itemMaps.add({
        'id': canonicalId,
        'name': item.name,
        'unit': item.unit,
        'purchase_price': purchasePrice.toStringAsFixed(2),
        'sale_price': salePrice.toStringAsFixed(2),
        'opening_stock': openingStock.toStringAsFixed(2),
        'purchased_qty': purchasedQty.toStringAsFixed(2),
        'sold_qty': soldQty.toStringAsFixed(2),
        'stock_out_qty': stockOutQty.toStringAsFixed(2),
        'wastage_qty': wastageQty.toStringAsFixed(2),
        'adjustment_events': adjustmentEvents,
        'closing_stock': closingStock.toStringAsFixed(2),
        'current_stock': closingStock.toStringAsFixed(2),
        'stock_value': stockValue.toStringAsFixed(2),
        'value': stockValue.toStringAsFixed(2),
        'sold_value': soldValue.toStringAsFixed(2),
        'estimated_margin': estimatedMargin.toStringAsFixed(2),
        'sales_velocity_per_day': velocity.toStringAsFixed(4),
        'days_of_stock_left': daysLeft?.toStringAsFixed(2),
        'is_out_of_stock': isOut,
        'is_low_stock': false,
        'is_dead_stock': isDead,
        'low_stock_threshold': null,
      });
    }

    fastMoving.sort(
      (a, b) => _parseAmount(b['sold_qty']?.toString()).compareTo(
        _parseAmount(a['sold_qty']?.toString()),
      ),
    );
    deadStockItems.sort(
      (a, b) => _parseAmount(b['stock_value']?.toString()).compareTo(
        _parseAmount(a['stock_value']?.toString()),
      ),
    );
    itemMaps.sort(
      (a, b) => _parseAmount(b['stock_value']?.toString()).compareTo(
        _parseAmount(a['stock_value']?.toString()),
      ),
    );
    soldItemsPayload.sort(
      (a, b) => _parseAmount(b['sold_amount']?.toString()).compareTo(
        _parseAmount(a['sold_amount']?.toString()),
      ),
    );
    movementEntries.sort(
      (a, b) => (b['date'] as String).compareTo(a['date'] as String),
    );

    final remainingStockSnapshot = itemMaps
        .where((item) => _parseAmount(item['closing_stock']?.toString()) > 0)
        .map(
          (item) => <String, dynamic>{
            'item_name': item['name'],
            'unit': item['unit'],
            'left_qty': _parseAmount(item['closing_stock']?.toString())
                .toStringAsFixed(3),
            'left_value': _parseAmount(item['stock_value']?.toString())
                .toStringAsFixed(2),
          },
        )
        .toList(growable: false);

    final soldItemsCustomerBreakdown = <Map<String, dynamic>>[];
    const topCustomersLimit = 10;
    const inlineCustomersLimit = 3;
    for (final soldItem in soldItemsPayload) {
      final itemId = soldItem['item_id']?.toString() ?? '';
      final breakdownMap = soldCustomerBreakdownByItem[itemId] ??
          <String, _LocalCustomerAggregate>{};
      final sortedCustomers = breakdownMap.values.toList()
        ..sort((a, b) => b.amount.compareTo(a.amount));

      final topCustomers = sortedCustomers.take(topCustomersLimit).toList();
      final overflowCustomers = sortedCustomers.skip(topCustomersLimit);
      if (overflowCustomers.isNotEmpty) {
        final others = _LocalCustomerAggregate('Others');
        for (final entry in overflowCustomers) {
          others.qty += entry.qty;
          others.amount += entry.amount;
          others.invoiceIds.addAll(entry.invoiceIds);
          if (entry.lastSaleAt != null &&
              (others.lastSaleAt == null ||
                  entry.lastSaleAt!.isAfter(others.lastSaleAt!))) {
            others.lastSaleAt = entry.lastSaleAt;
          }
        }
        topCustomers.add(others);
      }

      final customersPayload = topCustomers
          .map(
            (entry) => <String, dynamic>{
              'customer_name': entry.customerName,
              'qty': entry.qty.toStringAsFixed(3),
              'amount': entry.amount.toStringAsFixed(2),
              'invoice_count': entry.invoiceIds.length,
              'last_sale_at': entry.lastSaleAt?.toIso8601String(),
            },
          )
          .toList(growable: false);

      soldItem['top_customers'] =
          customersPayload.take(inlineCustomersLimit).toList(growable: false);
      soldItemsCustomerBreakdown.add({
        'item_id': itemId,
        'item_name': soldItem['item_name'],
        'unit': soldItem['unit'],
        'customers': customersPayload,
      });
    }

    soldItemsCustomerBreakdown.sort((a, b) {
      final aItem = soldItemsPayload.firstWhere(
        (item) => item['item_id'] == a['item_id'],
        orElse: () => const {'sold_amount': '0'},
      );
      final bItem = soldItemsPayload.firstWhere(
        (item) => item['item_id'] == b['item_id'],
        orElse: () => const {'sold_amount': '0'},
      );
      return _parseAmount(bItem['sold_amount']?.toString())
          .compareTo(_parseAmount(aItem['sold_amount']?.toString()));
    });

    final grossProfit = totalSoldValue - totalCogs;
    final grossMarginPercent =
        totalSoldValue > 0 ? (grossProfit / totalSoldValue) * 100 : 0.0;

    final periodSummary = {
      'start_date': rangeStart.toIso8601String(),
      'end_date': rangeEnd.toIso8601String(),
      'days_in_range': daysInRange,
      'sold_entries': soldEntriesCount,
      'sold_qty': totalSoldQty.toStringAsFixed(3),
      'sold_value': totalSoldValue.toStringAsFixed(2),
      'outgoing_entries': movementSummary['out']?['entries'] ?? 0,
      'outgoing_qty':
          (movementSummary['out']?['qty'] as double? ?? 0).toStringAsFixed(3),
      'outgoing_value': (movementSummary['out']?['amount'] as double? ?? 0)
          .toStringAsFixed(2),
      'left_qty': totalLeftQty.toStringAsFixed(3),
      'left_value': totalStockValue.toStringAsFixed(2),
    };

    final profitLossSummary = {
      'sales_revenue': totalSoldValue.toStringAsFixed(2),
      'cogs': totalCogs.toStringAsFixed(2),
      'gross_profit': grossProfit.toStringAsFixed(2),
      'gross_margin_percent': grossMarginPercent.toStringAsFixed(2),
    };

    final movementSummaryPayload = movementSummary.map((key, value) {
      return MapEntry(
        key,
        {
          'entries': value['entries'],
          'qty': (value['qty'] as double).toStringAsFixed(3),
          'amount': (value['amount'] as double).toStringAsFixed(2),
        },
      );
    });

    return {
      'start_date': rangeStart.toIso8601String(),
      'end_date': rangeEnd.toIso8601String(),
      'days_in_range': daysInRange,
      'total_items': items.length,
      'total_value': totalStockValue.toStringAsFixed(2),
      'total_stock_value': totalStockValue.toStringAsFixed(2),
      'total_sold_qty': totalSoldQty.toStringAsFixed(2),
      'total_sold_value': totalSoldValue.toStringAsFixed(2),
      'total_estimated_margin': totalEstimatedMargin.toStringAsFixed(2),
      'out_of_stock_items': outOfStockCount,
      'low_stock_items': 0,
      'dead_stock_items_count': deadStockCount,
      'fast_moving_items': fastMoving.take(10).toList(),
      'dead_stock_items': deadStockItems.take(20).toList(),
      'items': itemMaps,
      'entries': movementSummaryPayload['all']?['entries'] ?? 0,
      'total_qty': movementSummaryPayload['all']?['qty'] ?? '0.00',
      'total_amount': movementSummaryPayload['all']?['amount'] ?? '0.00',
      'in_summary': movementSummaryPayload['in'],
      'out_summary': movementSummaryPayload['out'],
      'movement_summary': movementSummaryPayload,
      'movement_entries': movementEntries,
      'period_summary': periodSummary,
      'sold_items': soldItemsPayload,
      'sold_items_customer_breakdown': soldItemsCustomerBreakdown,
      'remaining_stock_snapshot': remainingStockSnapshot,
      'invoice_reference_rows': invoiceReferenceRows,
      'reference_rows': invoiceReferenceRows,
      'profit_loss_summary': profitLossSummary,
      'is_offline': true,
    };
  }

  Future<Map<String, dynamic>> _buildLocalProfitLossReport(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final rangeStart = AppDateUtils.normalizeToStartOfDay(startDate);
    final rangeEnd = AppDateUtils.normalizeToStartOfDay(endDate)
        .add(const Duration(days: 1))
        .subtract(const Duration(milliseconds: 1));

    final invoices = await _appDatabase.fetchInvoices(
      startDate: rangeStart,
      endDate: rangeEnd,
      limit: 1000000,
    );
    final expenses = await _appDatabase.fetchExpenses(
      startDate: rangeStart,
      endDate: rangeEnd,
      limit: 1000000,
    );

    double revenue = 0;
    final revenueBreakdown = <String, double>{};
    for (final invoice in invoices) {
      final amount = _parseAmount(invoice.totalAmount);
      revenue += amount;
      final key = invoice.invoiceType;
      revenueBreakdown[key] = (revenueBreakdown[key] ?? 0) + amount;
    }

    double totalExpenses = 0;
    final expenseBreakdown = <String, double>{};
    for (final expense in expenses) {
      final amount = _parseAmount(expense.amount);
      totalExpenses += amount;
      final key = expense.paymentMode;
      expenseBreakdown[key] = (expenseBreakdown[key] ?? 0) + amount;
    }

    return {
      'total_revenue': revenue.toStringAsFixed(2),
      'total_expenses': totalExpenses.toStringAsFixed(2),
      'revenue_breakdown': revenueBreakdown.map(
        (key, value) => MapEntry(key, value.toStringAsFixed(2)),
      ),
      'expense_breakdown': expenseBreakdown.map(
        (key, value) => MapEntry(key, value.toStringAsFixed(2)),
      ),
      'reference_rows': [
        ...invoices.map((invoice) => <String, dynamic>{
              'reference_type': 'invoice',
              'reference_id': invoice.serverId,
              'invoice_number': invoice.invoiceNumber,
              'invoice_date': invoice.date.toIso8601String(),
              'invoice_total': invoice.totalAmount,
            }),
        ...expenses.map((expense) => <String, dynamic>{
              'reference_type': 'expense',
              'reference_id': expense.serverId,
              'date': expense.date.toIso8601String(),
              'amount': expense.amount,
            }),
      ],
      'is_offline': true,
    };
  }

  void _addSalesBucket(
    Map<DateTime, _SalesBucket> buckets,
    DateTime key,
    String invoiceType,
    double amount,
  ) {
    final bucket = buckets.putIfAbsent(key, () => _SalesBucket());
    bucket.total += amount;
    bucket.count += 1;
    if (invoiceType == 'cash') {
      bucket.cash += amount;
    } else {
      bucket.credit += amount;
    }
  }

  List<Map<String, dynamic>> _buildSalesBreakdown(
    Map<DateTime, _SalesBucket> buckets, {
    required String period,
  }) {
    final entries = buckets.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return entries.map((entry) {
      final bucket = entry.value;
      if (period == 'week') {
        return {
          'week_start': entry.key.toIso8601String(),
          'total': bucket.total.toStringAsFixed(2),
          'cash': bucket.cash.toStringAsFixed(2),
          'credit': bucket.credit.toStringAsFixed(2),
          'count': bucket.count,
        };
      }
      if (period == 'month') {
        return {
          'month': entry.key.toIso8601String(),
          'total': bucket.total.toStringAsFixed(2),
          'cash': bucket.cash.toStringAsFixed(2),
          'credit': bucket.credit.toStringAsFixed(2),
          'count': bucket.count,
        };
      }
      return {
        'date': entry.key.toIso8601String(),
        'total': bucket.total.toStringAsFixed(2),
        'cash': bucket.cash.toStringAsFixed(2),
        'credit': bucket.credit.toStringAsFixed(2),
        'count': bucket.count,
      };
    }).toList();
  }

  DateTime _startOfWeek(DateTime date) {
    final normalized = AppDateUtils.normalizeToStartOfDay(date);
    return normalized.subtract(Duration(days: normalized.weekday - 1));
  }

  double _computeCashBalance(List<CashTransaction> transactions) {
    return transactions.fold<double>(0, (sum, txn) {
      final amount = _parseAmount(txn.amount);
      return txn.transactionType == 'cash_in' ? sum + amount : sum - amount;
    });
  }

  _CashTotals _computeCashTotals(List<CashTransaction> transactions) {
    var totalIn = 0.0;
    var totalOut = 0.0;
    for (final txn in transactions) {
      final amount = _parseAmount(txn.amount);
      if (txn.transactionType == 'cash_in') {
        totalIn += amount;
      } else {
        totalOut += amount;
      }
    }
    return _CashTotals(totalIn: totalIn, totalOut: totalOut);
  }

  double _parseAmount(String? value) {
    return double.tryParse(value ?? '') ?? 0;
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
}

class _SalesBucket {
  double total = 0;
  double cash = 0;
  double credit = 0;
  int count = 0;
}

class _CashTotals {
  _CashTotals({
    required this.totalIn,
    required this.totalOut,
  });

  final double totalIn;
  final double totalOut;
}

class _LocalSoldAggregate {
  double qty = 0;
  double amount = 0;
  final Set<String> invoiceIds = <String>{};
  DateTime? lastSaleAt;
}

class _LocalCustomerAggregate {
  _LocalCustomerAggregate(this.customerName);

  final String customerName;
  double qty = 0;
  double amount = 0;
  final Set<String> invoiceIds = <String>{};
  DateTime? lastSaleAt;
}
