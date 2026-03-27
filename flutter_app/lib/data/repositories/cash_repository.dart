import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/result.dart';
import '../../core/utils/date_utils.dart';
import '../../core/constants/api_constants.dart';
import '../../core/database/app_database.dart';
import '../../core/sync/sync_queue.dart';
import '../../shared/models/cash_balance_model.dart';
import '../../shared/models/cash_transaction_model.dart';

/// Cash Repository
class CashRepository {
  CashRepository({
    required ApiClient apiClient,
    required AppDatabase appDatabase,
    required SyncQueue syncQueue,
  })  : _apiClient = apiClient,
        _appDatabase = appDatabase,
        _syncQueue = syncQueue;

  final ApiClient _apiClient;
  final AppDatabase _appDatabase;
  final SyncQueue _syncQueue;

  /// Create cash transaction
  Future<Result<CashTransactionModel>> createTransaction({
    required String transactionType,
    required String amount,
    required DateTime date,
    String? source,
    String? remarks,
  }) async {
    final payload = <String, dynamic>{
      'transaction_type': transactionType,
      'amount': amount,
      // Normalize date to start of day to avoid timezone issues
      'date': AppDateUtils.formatDateTimeForApi(date),
      if (source != null) 'source': source,
      if (remarks != null) 'remarks': remarks,
    };

    try {
      final response = await _apiClient.post(
        ApiConstants.cashTransactions,
        data: payload,
      );

      final transaction = CashTransactionModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      await _cacheTransaction(transaction);

      return Result.success(transaction);
    } on AppException catch (e) {
      if (e is NetworkException || e is TimeoutException) {
        final transaction = await _createTransactionOffline(payload);
        return Result.success(transaction);
      }
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  /// Get cash transactions
  Future<Result<List<CashTransactionModel>>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
    int offset = 0,
  }) async {
    List<CashTransactionModel> localTransactions = [];
    try {
      final localRows = await _appDatabase.fetchCashTransactions(
        startDate: startDate != null
            ? AppDateUtils.normalizeToStartOfDay(startDate)
            : null,
        endDate: endDate != null
            ? AppDateUtils.normalizeToStartOfDay(endDate)
                .add(const Duration(days: 1))
                .subtract(const Duration(milliseconds: 1))
            : null,
        limit: limit,
        offset: offset,
      );
      localTransactions = localRows.map(_cashTransactionFromRow).toList();
    } catch (_) {}

    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };

      if (startDate != null) {
        // Normalize to start of day to avoid timezone issues
        final normalized = AppDateUtils.normalizeToStartOfDay(startDate);
        queryParams['start_date'] =
            AppDateUtils.formatDateTimeForApi(normalized);
      }
      if (endDate != null) {
        // Normalize to start of day to avoid timezone issues
        final normalized = AppDateUtils.normalizeToStartOfDay(endDate);
        queryParams['end_date'] = AppDateUtils.formatDateTimeForApi(normalized);
      }

      final response = await _apiClient.get(
        ApiConstants.cashTransactions,
        queryParameters: queryParams,
      );

      final transactions = (response.data as List<dynamic>)
          .map((e) => CashTransactionModel.fromJson(e as Map<String, dynamic>))
          .toList();

      await _appDatabase.upsertCashTransactions(
        transactions.map(_cashTransactionCompanionFromModel).toList(),
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

  /// Get daily balance
  Future<Result<CashBalanceModel>> getDailyBalance(DateTime date) async {
    try {
      // Normalize date to start of day to avoid timezone issues
      final normalizedDate = AppDateUtils.normalizeToStartOfDay(date);
      final dateStr = AppDateUtils.formatDateForApi(normalizedDate);

      final response = await _apiClient.get(
        '${ApiConstants.cashBalance}/$dateStr',
      );

      final balance = CashBalanceModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      return Result.success(balance);
    } on AppException catch (e) {
      if (e is NetworkException || e is TimeoutException) {
        final balance = await _computeLocalDailyBalance(date);
        if (balance != null) {
          return Result.success(balance);
        }
      }
      return Result.failure(_mapExceptionToFailure(e));
    } catch (e) {
      final balance = await _computeLocalDailyBalance(date);
      if (balance != null) {
        return Result.success(balance);
      }
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  /// Get cash summary
  Future<Result<Map<String, dynamic>>> getSummary({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Normalize dates to start of day to avoid timezone issues
      final normalizedStartDate = AppDateUtils.normalizeToStartOfDay(startDate);
      final normalizedEndDate = AppDateUtils.normalizeToStartOfDay(endDate);

      final response = await _apiClient.post(
        ApiConstants.cashSummary,
        data: {
          'start_date': AppDateUtils.formatDateTimeForApi(normalizedStartDate),
          'end_date': AppDateUtils.formatDateTimeForApi(normalizedEndDate),
        },
      );

      return Result.success(response.data as Map<String, dynamic>);
    } on AppException catch (e) {
      if (e is NetworkException || e is TimeoutException) {
        final summary = await _computeLocalSummary(
          startDate: startDate,
          endDate: endDate,
        );
        if (summary != null) {
          return Result.success(summary);
        }
      }
      return Result.failure(_mapExceptionToFailure(e));
    } catch (e) {
      final summary = await _computeLocalSummary(
        startDate: startDate,
        endDate: endDate,
      );
      if (summary != null) {
        return Result.success(summary);
      }
      return Result.failure(UnknownFailure(e.toString()));
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

  Future<void> _cacheTransaction(CashTransactionModel transaction) async {
    await _appDatabase.upsertCashTransactions([
      _cashTransactionCompanionFromModel(transaction),
    ]);
  }

  CashTransactionModel _cashTransactionFromRow(CashTransaction row) {
    return CashTransactionModel(
      id: row.serverId ?? row.clientId ?? row.id.toString(),
      transactionType: row.transactionType,
      amount: row.amount,
      date: row.date,
      source: row.source,
      remarks: row.remarks,
      createdAt: row.createdAt,
    );
  }

  CashTransactionsCompanion _cashTransactionCompanionFromModel(
    CashTransactionModel model,
  ) {
    return CashTransactionsCompanion(
      serverId: Value(model.id),
      transactionType: Value(model.transactionType),
      amount: Value(model.amount),
      date: Value(model.date),
      source: Value(model.source),
      remarks: Value(model.remarks),
      createdAt: Value(model.createdAt),
      isSynced: const Value(true),
      syncStatus: const Value('synced'),
    );
  }

  Future<CashTransactionModel> _createTransactionOffline(
    Map<String, dynamic> payload,
  ) async {
    final now = DateTime.now();
    final clientId = const Uuid().v4();
    final date = DateTime.parse(payload['date'] as String);

    final localId =
        await _appDatabase.into(_appDatabase.cashTransactions).insert(
              CashTransactionsCompanion.insert(
                clientId: Value(clientId),
                transactionType: payload['transaction_type'] as String,
                amount: payload['amount']?.toString() ?? '0',
                date: date,
                source: Value(payload['source'] as String?),
                remarks: Value(payload['remarks'] as String?),
                createdAt: Value(now),
                isSynced: const Value(false),
                syncStatus: const Value('pending'),
              ),
            );

    await _syncQueue.enqueue(
      entityType: 'cash_transaction',
      action: 'create',
      entityId: localId,
      data: {
        ...payload,
        'client_id': clientId,
        'updated_at': now.toIso8601String(),
      },
    );

    return CashTransactionModel(
      id: clientId,
      transactionType: payload['transaction_type'] as String,
      amount: payload['amount']?.toString() ?? '0',
      date: date,
      source: payload['source'] as String?,
      remarks: payload['remarks'] as String?,
      createdAt: now,
    );
  }

  Future<CashBalanceModel?> _computeLocalDailyBalance(DateTime date) async {
    try {
      final dayStart = AppDateUtils.normalizeToStartOfDay(date);
      final dayEnd = dayStart
          .add(const Duration(days: 1))
          .subtract(const Duration(milliseconds: 1));

      final beforeTransactions = await _appDatabase.fetchCashTransactions(
        endDate: dayStart.subtract(const Duration(milliseconds: 1)),
        limit: 1000000,
      );
      final dayTransactions = await _appDatabase.fetchCashTransactions(
        startDate: dayStart,
        endDate: dayEnd,
        limit: 1000000,
      );

      final openingBalance = _computeBalance(beforeTransactions);
      final totals = _computeTotals(dayTransactions);
      final closingBalance =
          openingBalance + totals.totalCashIn - totals.totalCashOut;

      return CashBalanceModel(
        date: dayStart,
        openingBalance: _formatAmount(openingBalance),
        totalCashIn: _formatAmount(totals.totalCashIn),
        totalCashOut: _formatAmount(totals.totalCashOut),
        closingBalance: _formatAmount(closingBalance),
      );
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _computeLocalSummary({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final rangeStart = AppDateUtils.normalizeToStartOfDay(startDate);
      final rangeEnd = AppDateUtils.normalizeToStartOfDay(endDate)
          .add(const Duration(days: 1))
          .subtract(const Duration(milliseconds: 1));

      final beforeTransactions = await _appDatabase.fetchCashTransactions(
        endDate: rangeStart.subtract(const Duration(milliseconds: 1)),
        limit: 1000000,
      );
      final rangeTransactions = await _appDatabase.fetchCashTransactions(
        startDate: rangeStart,
        endDate: rangeEnd,
        limit: 1000000,
      );

      final openingBalance = _computeBalance(beforeTransactions);
      final totals = _computeTotals(rangeTransactions);
      final closingBalance =
          openingBalance + totals.totalCashIn - totals.totalCashOut;

      return {
        'start_date': rangeStart.toIso8601String(),
        'end_date': rangeEnd.toIso8601String(),
        'opening_balance': _formatAmount(openingBalance),
        'total_cash_in': _formatAmount(totals.totalCashIn),
        'total_cash_out': _formatAmount(totals.totalCashOut),
        'closing_balance': _formatAmount(closingBalance),
        'transactions': rangeTransactions
            .map((txn) => _cashTransactionToJson(txn))
            .toList(),
      };
    } catch (_) {
      return null;
    }
  }

  double _computeBalance(List<CashTransaction> transactions) {
    return transactions.fold<double>(0, (sum, txn) {
      final amount = _parseAmount(txn.amount);
      return txn.transactionType == 'cash_in' ? sum + amount : sum - amount;
    });
  }

  _CashTotals _computeTotals(List<CashTransaction> transactions) {
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
    return _CashTotals(totalCashIn: totalIn, totalCashOut: totalOut);
  }

  Map<String, dynamic> _cashTransactionToJson(CashTransaction txn) {
    return {
      'id': txn.serverId ?? txn.clientId ?? txn.id.toString(),
      'transaction_type': txn.transactionType,
      'amount': txn.amount,
      'date': txn.date.toIso8601String(),
      if (txn.source != null) 'source': txn.source,
      if (txn.remarks != null) 'remarks': txn.remarks,
      if (txn.referenceId != null) 'reference_id': txn.referenceId,
      if (txn.referenceType != null) 'reference_type': txn.referenceType,
      if (txn.createdAt != null) 'created_at': txn.createdAt!.toIso8601String(),
    };
  }

  double _parseAmount(String? value) {
    return double.tryParse(value ?? '') ?? 0;
  }

  String _formatAmount(double value) {
    return value.toStringAsFixed(2);
  }
}

class _CashTotals {
  const _CashTotals({
    required this.totalCashIn,
    required this.totalCashOut,
  });

  final double totalCashIn;
  final double totalCashOut;
}
