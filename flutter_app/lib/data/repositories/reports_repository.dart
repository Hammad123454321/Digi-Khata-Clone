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
  Future<Result<Map<String, dynamic>>> getStockReport() async {
    try {
      final response = await _apiClient.get(ApiConstants.reportsStock);

      return Result.success(response.data as Map<String, dynamic>);
    } on AppException catch (e) {
      if (e is NetworkException || e is TimeoutException) {
        final report = await _buildLocalStockReport();
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

    return {
      'total_sales': totalSales.toStringAsFixed(2),
      'cash_sales': cashSales.toStringAsFixed(2),
      'credit_sales': creditSales.toStringAsFixed(2),
      'total_invoices': invoices.length,
      'daily_breakdown': _buildSalesBreakdown(daily, period: 'day'),
      'weekly_breakdown': _buildSalesBreakdown(weekly, period: 'week'),
      'monthly_breakdown': _buildSalesBreakdown(monthly, period: 'month'),
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
      'is_offline': true,
    };
  }

  Future<Map<String, dynamic>> _buildLocalStockReport() async {
    final items = await _appDatabase.fetchStockItems(limit: 1000000);
    double totalValue = 0;
    int outOfStock = 0;

    final itemMaps = items.map((item) {
      final current = _parseAmount(item.currentStock);
      final price = _parseAmount(item.purchasePrice);
      final value = current * price;
      totalValue += value;
      if (current <= 0) {
        outOfStock += 1;
      }
      return {
        'name': item.name,
        'current_stock': current.toStringAsFixed(2),
        'unit': item.unit,
        'value': value.toStringAsFixed(2),
      };
    }).toList();

    return {
      'total_items': items.length,
      'total_value': totalValue.toStringAsFixed(2),
      'out_of_stock_items': outOfStock,
      'items': itemMaps,
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
