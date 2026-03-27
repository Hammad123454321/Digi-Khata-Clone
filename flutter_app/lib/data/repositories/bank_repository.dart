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
import '../../shared/models/bank_account_model.dart';
import '../../shared/models/bank_transaction_model.dart';

/// Bank Repository
class BankRepository {
  BankRepository({
    required ApiClient apiClient,
    required AppDatabase appDatabase,
    required SyncQueue syncQueue,
  })  : _apiClient = apiClient,
        _appDatabase = appDatabase,
        _syncQueue = syncQueue;

  final ApiClient _apiClient;
  final AppDatabase _appDatabase;
  final SyncQueue _syncQueue;

  /// Create bank account
  Future<Result<BankAccountModel>> createAccount({
    required String bankName,
    required String accountNumber,
    String? accountHolderName,
    String? branch,
    String? ifscCode,
    String? accountType,
    required String openingBalance,
  }) async {
    final payload = <String, dynamic>{
      'bank_name': bankName,
      'account_number': accountNumber,
      if (accountHolderName != null) 'account_holder_name': accountHolderName,
      if (branch != null) 'branch': branch,
      if (ifscCode != null) 'ifsc_code': ifscCode,
      if (accountType != null) 'account_type': accountType,
      'opening_balance': openingBalance,
    };
    try {
      final response = await _apiClient.post(
        ApiConstants.bankAccounts,
        data: payload,
      );

      final account = BankAccountModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      await _appDatabase.upsertBankAccounts([
        _bankAccountCompanionFromModel(account),
      ]);

      return Result.success(account);
    } on AppException catch (e) {
      if (e is NetworkException || e is TimeoutException) {
        final account = await _createAccountOffline(payload);
        return Result.success(account);
      }
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  /// Get bank accounts
  Future<Result<List<BankAccountModel>>> getAccounts({
    bool? isActive,
    int limit = 100,
    int offset = 0,
  }) async {
    List<BankAccountModel> localAccounts = [];
    try {
      final localRows = await _appDatabase.fetchBankAccounts(
        isActive: isActive,
        limit: limit,
        offset: offset,
      );
      localAccounts = localRows.map(_bankAccountFromRow).toList();
    } catch (_) {}

    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };

      if (isActive != null) {
        queryParams['is_active'] = isActive;
      }

      final response = await _apiClient.get(
        ApiConstants.bankAccounts,
        queryParameters: queryParams,
      );

      final accounts = (response.data as List<dynamic>)
          .map((e) => BankAccountModel.fromJson(e as Map<String, dynamic>))
          .toList();

      await _appDatabase.upsertBankAccounts(
        accounts.map(_bankAccountCompanionFromModel).toList(),
      );

      return Result.success(accounts);
    } on AppException catch (e) {
      if (localAccounts.isNotEmpty ||
          e is NetworkException ||
          e is TimeoutException) {
        return Result.success(localAccounts);
      }
      return Result.failure(_mapExceptionToFailure(e));
    } catch (e) {
      return Result.success(localAccounts);
    }
  }

  /// Create bank transaction
  Future<Result<BankTransactionModel>> createTransaction({
    required String accountId,
    required String transactionType,
    required String amount,
    required DateTime date,
    String? referenceNumber,
    String? remarks,
  }) async {
    final payload = <String, dynamic>{
      'bank_account_id': accountId,
      'transaction_type': transactionType,
      'amount': amount,
      'date': date.toIso8601String(),
      if (referenceNumber != null) 'reference_number': referenceNumber,
      if (remarks != null) 'remarks': remarks,
    };
    try {
      final response = await _apiClient.post(
        ApiConstants.bankTransactions,
        data: payload,
      );

      final transaction = BankTransactionModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      await _cacheTransaction(transaction);
      await _applyLocalAccountBalanceChange(
        accountId: transaction.accountId,
        transactionType: transaction.transactionType,
        amount: transaction.amount,
        markSynced: true,
      );

      return Result.success(transaction);
    } on AppException catch (e) {
      if (e is NetworkException || e is TimeoutException) {
        final transaction = await _createTransactionOffline(payload);
        return Result.success(transaction);
      }
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  /// Cash-Bank transfer
  Future<Result<void>> transfer({
    required String accountId,
    required String transferType,
    required String amount,
    required DateTime date,
    String? remarks,
  }) async {
    try {
      await _apiClient.post(
        ApiConstants.bankTransfers,
        data: {
          'bank_account_id': accountId,
          'transfer_type': transferType,
          'amount': amount,
          'date': date.toIso8601String(),
          if (remarks != null) 'remarks': remarks,
        },
      );

      await _applyLocalTransferBalance(
        accountId: accountId,
        transferType: transferType,
        amount: amount,
        markSynced: true,
      );

      return const Result.success(null);
    } on AppException catch (e) {
      if (e is NetworkException || e is TimeoutException) {
        await _createTransferOffline(
          accountId: accountId,
          transferType: transferType,
          amount: amount,
          date: date,
          remarks: remarks,
        );
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

  BankAccountModel _bankAccountFromRow(BankAccount row) {
    return BankAccountModel(
      id: row.serverId ?? row.clientId ?? row.id.toString(),
      bankName: row.bankName,
      accountNumber: row.accountNumber,
      accountHolderName: row.accountHolderName,
      branch: row.branch,
      ifscCode: row.ifscCode,
      accountType: row.accountType,
      openingBalance: row.openingBalance,
      currentBalance: row.currentBalance,
      isActive: row.isActive,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
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

  BankTransactionsCompanion _bankTransactionCompanionFromModel(
    BankTransactionModel model,
  ) {
    return BankTransactionsCompanion(
      serverId: Value(model.id),
      accountId: Value(model.accountId),
      transactionType: Value(model.transactionType),
      amount: Value(model.amount),
      date: Value(model.date),
      referenceNumber: Value(model.referenceNumber),
      remarks: Value(model.remarks),
      createdAt: Value(model.createdAt),
      isSynced: const Value(true),
      syncStatus: const Value('synced'),
    );
  }

  Future<BankAccountModel> _createAccountOffline(
    Map<String, dynamic> payload,
  ) async {
    final now = DateTime.now();
    final clientId = const Uuid().v4();
    final openingBalance = payload['opening_balance']?.toString() ?? '0';

    final localId = await _appDatabase.into(_appDatabase.bankAccounts).insert(
          BankAccountsCompanion.insert(
            bankName: payload['bank_name'] as String,
            accountNumber: payload['account_number'] as String,
            clientId: Value(clientId),
            accountHolderName: Value(payload['account_holder_name'] as String?),
            branch: Value(payload['branch'] as String?),
            ifscCode: Value(payload['ifsc_code'] as String?),
            accountType: Value(payload['account_type'] as String?),
            openingBalance: openingBalance,
            currentBalance: openingBalance,
            isActive: const Value(true),
            createdAt: Value(now),
            updatedAt: Value(now),
            isSynced: const Value(false),
            syncStatus: const Value('pending'),
          ),
        );

    await _syncQueue.enqueue(
      entityType: 'bank_account',
      action: 'create',
      entityId: localId,
      data: {
        ...payload,
        'client_id': clientId,
        'updated_at': now.toIso8601String(),
      },
    );

    return BankAccountModel(
      id: clientId,
      bankName: payload['bank_name'] as String,
      accountNumber: payload['account_number'] as String,
      accountHolderName: payload['account_holder_name'] as String?,
      branch: payload['branch'] as String?,
      ifscCode: payload['ifsc_code'] as String?,
      accountType: payload['account_type'] as String?,
      openingBalance: openingBalance,
      currentBalance: openingBalance,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<void> _cacheTransaction(BankTransactionModel transaction) async {
    await _appDatabase.upsertBankTransactions([
      _bankTransactionCompanionFromModel(transaction),
    ]);
  }

  Future<BankTransactionModel> _createTransactionOffline(
    Map<String, dynamic> payload,
  ) async {
    final now = DateTime.now();
    final clientId = const Uuid().v4();
    final accountId = payload['bank_account_id']?.toString() ?? '';
    final date = DateTime.parse(payload['date'] as String);

    final localId =
        await _appDatabase.into(_appDatabase.bankTransactions).insert(
              BankTransactionsCompanion.insert(
                clientId: Value(clientId),
                accountId: accountId,
                transactionType: payload['transaction_type'] as String,
                amount: payload['amount']?.toString() ?? '0',
                date: date,
                referenceNumber: Value(payload['reference_number'] as String?),
                remarks: Value(payload['remarks'] as String?),
                createdAt: Value(now),
                isSynced: const Value(false),
                syncStatus: const Value('pending'),
              ),
            );

    await _applyLocalAccountBalanceChange(
      accountId: accountId,
      transactionType: payload['transaction_type'] as String,
      amount: payload['amount']?.toString() ?? '0',
      markSynced: false,
    );

    await _syncQueue.enqueue(
      entityType: 'bank_transaction',
      action: 'create',
      entityId: localId,
      data: {
        ...payload,
        'client_id': clientId,
        'updated_at': now.toIso8601String(),
      },
    );

    return BankTransactionModel(
      id: clientId,
      accountId: accountId,
      transactionType: payload['transaction_type'] as String,
      amount: payload['amount']?.toString() ?? '0',
      date: date,
      referenceNumber: payload['reference_number'] as String?,
      remarks: payload['remarks'] as String?,
      createdAt: now,
    );
  }

  Future<void> _createTransferOffline({
    required String accountId,
    required String transferType,
    required String amount,
    required DateTime date,
    String? remarks,
  }) async {
    final now = DateTime.now();
    final clientId = const Uuid().v4();

    await _applyLocalTransferBalance(
      accountId: accountId,
      transferType: transferType,
      amount: amount,
      markSynced: false,
    );

    await _createLocalCashTransferTransaction(
      accountId: accountId,
      transferType: transferType,
      amount: amount,
      date: date,
      remarks: remarks,
    );

    await _syncQueue.enqueue(
      entityType: 'cash_bank_transfer',
      action: 'create',
      data: {
        'bank_account_id': accountId,
        'transfer_type': transferType,
        'amount': amount,
        'date': date.toIso8601String(),
        if (remarks != null) 'remarks': remarks,
        'client_id': clientId,
        'updated_at': now.toIso8601String(),
      },
    );
  }

  Future<void> _applyLocalAccountBalanceChange({
    required String accountId,
    required String transactionType,
    required String amount,
    required bool markSynced,
  }) async {
    final account = await _appDatabase.findBankAccountByAnyId(accountId);
    if (account == null) return;

    final current = _parseAmount(account.currentBalance);
    final delta = _parseAmount(amount);
    final next = _computeNextBalance(
      current: current,
      transactionType: transactionType,
      amount: delta,
    );

    final companion = BankAccountsCompanion(
      currentBalance: Value(_formatAmount(next)),
      updatedAt: Value(DateTime.now()),
      isSynced: Value(markSynced),
      syncStatus: Value(markSynced ? 'synced' : 'pending'),
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

  Future<void> _applyLocalTransferBalance({
    required String accountId,
    required String transferType,
    required String amount,
    required bool markSynced,
  }) async {
    final transactionType =
        transferType == 'cash_to_bank' ? 'deposit' : 'withdrawal';
    await _applyLocalAccountBalanceChange(
      accountId: accountId,
      transactionType: transactionType,
      amount: amount,
      markSynced: markSynced,
    );
  }

  Future<void> _createLocalCashTransferTransaction({
    required String accountId,
    required String transferType,
    required String amount,
    required DateTime date,
    String? remarks,
  }) async {
    final account = await _appDatabase.findBankAccountByAnyId(accountId);
    final bankName = account?.bankName ?? '';
    final normalizedDate = AppDateUtils.normalizeToStartOfDay(date);
    final fallbackRemarks = transferType == 'cash_to_bank'
        ? 'Transfer to ${bankName.isEmpty ? 'bank' : bankName}'
        : 'Transfer from ${bankName.isEmpty ? 'bank' : bankName}';

    await _appDatabase.into(_appDatabase.cashTransactions).insert(
          CashTransactionsCompanion.insert(
            clientId: Value(const Uuid().v4()),
            transactionType:
                transferType == 'cash_to_bank' ? 'cash_out' : 'cash_in',
            amount: amount,
            date: normalizedDate,
            source: const Value('bank_transfer'),
            remarks: Value(remarks ?? fallbackRemarks),
            referenceId: Value(accountId),
            referenceType: const Value('bank_transfer'),
            createdAt: Value(DateTime.now()),
            isSynced: const Value(false),
            syncStatus: const Value('pending'),
          ),
        );
  }

  double _computeNextBalance({
    required double current,
    required String transactionType,
    required double amount,
  }) {
    switch (transactionType) {
      case 'deposit':
        return current + amount;
      case 'withdrawal':
        return current - amount;
      default:
        return current;
    }
  }

  double _parseAmount(String? value) {
    return double.tryParse(value ?? '') ?? 0;
  }

  String _formatAmount(double value) {
    return value.toStringAsFixed(2);
  }
}
