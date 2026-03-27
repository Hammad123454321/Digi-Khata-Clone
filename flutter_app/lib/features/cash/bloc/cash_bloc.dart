import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/result.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/repositories/cash_repository.dart';
import '../../../shared/models/cash_balance_model.dart';
import '../../../shared/models/cash_transaction_model.dart';
import 'cash_event.dart';
import 'cash_state.dart';

/// Cash BLoC - handles cash management state
class CashBloc extends Bloc<CashEvent, CashState> {
  CashBloc({required CashRepository cashRepository})
      : _cashRepository = cashRepository,
        super(const CashInitial()) {
    on<CreateCashTransactionEvent>(_onCreateTransaction);
    on<LoadCashTransactionsEvent>(_onLoadTransactions);
    on<LoadDailyBalanceEvent>(_onLoadDailyBalance);
    on<LoadCashSummaryEvent>(_onLoadSummary);
  }

  final CashRepository _cashRepository;

  /// Extract current balance from state
  CashBalanceModel? _currentBalance() {
    if (state is CashBalanceLoaded) return (state as CashBalanceLoaded).balance;
    if (state is CashTransactionsLoaded)
      return (state as CashTransactionsLoaded).balance;
    return null;
  }

  /// Extract current transactions from state
  List<CashTransactionModel>? _currentTransactions() {
    if (state is CashBalanceLoaded)
      return (state as CashBalanceLoaded).transactions;
    if (state is CashTransactionsLoaded)
      return (state as CashTransactionsLoaded).transactions;
    return null;
  }

  Future<void> _onCreateTransaction(
    CreateCashTransactionEvent event,
    Emitter<CashState> emit,
  ) async {
    final preserveBalance = _currentBalance();
    final preserveTransactions = _currentTransactions();

    emit(const CashLoading());
    final result = await _cashRepository.createTransaction(
      transactionType: event.transactionType,
      amount: event.amount,
      date: event.date,
      source: event.source,
      remarks: event.remarks,
    );

    switch (result) {
      case Success(:final data):
        emit(CashTransactionCreated(data));
        final now = AppDateUtils.today();
        await _reloadBalanceAndTransactions(
            emit, now, preserveBalance, preserveTransactions);
      case FailureResult(:final failure):
        emit(CashError(failure.message ?? 'Failed to create transaction'));
    }
  }

  Future<void> _reloadBalanceAndTransactions(
    Emitter<CashState> emit,
    DateTime date,
    CashBalanceModel? preserveBalance,
    List<CashTransactionModel>? preserveTransactions,
  ) async {
    final balanceResult = await _cashRepository.getDailyBalance(date);
    final transactionsResult = await _cashRepository.getTransactions(
      startDate: DateTime(date.year, date.month, 1),
      endDate: date,
    );

    final balance = balanceResult.dataOrNull ?? preserveBalance;
    final transactions = transactionsResult.dataOrNull ?? preserveTransactions;

    if (balance != null) {
      emit(CashBalanceLoaded(balance, transactions: transactions));
    } else if (transactions != null) {
      emit(CashTransactionsLoaded(
          transactions: transactions, balance: preserveBalance));
    }
  }

  Future<void> _onLoadTransactions(
    LoadCashTransactionsEvent event,
    Emitter<CashState> emit,
  ) async {
    final currentBalance = _currentBalance();

    if (state is CashInitial || _currentTransactions() == null) {
      emit(const CashLoading());
    }

    final result = await _cashRepository.getTransactions(
      startDate: event.startDate,
      endDate: event.endDate,
    );

    switch (result) {
      case Success(:final data):
        emit(CashTransactionsLoaded(
            transactions: data, balance: currentBalance));
      case FailureResult(:final failure):
        if (currentBalance != null) {
          emit(CashTransactionsLoaded(
              transactions: const [], balance: currentBalance));
        } else {
          emit(CashError(failure.message ?? 'Failed to load transactions'));
        }
    }
  }

  Future<void> _onLoadDailyBalance(
    LoadDailyBalanceEvent event,
    Emitter<CashState> emit,
  ) async {
    final currentTransactions = _currentTransactions();

    if (state is CashInitial || _currentBalance() == null) {
      emit(const CashLoading());
    }

    final result = await _cashRepository.getDailyBalance(event.date);

    switch (result) {
      case Success(:final data):
        emit(CashBalanceLoaded(data, transactions: currentTransactions));
      case FailureResult(:final failure):
        if (currentTransactions != null) {
          emit(CashBalanceLoaded(
            CashBalanceModel(
              date: event.date,
              openingBalance: '0.00',
              closingBalance: '0.00',
              totalCashIn: '0.00',
              totalCashOut: '0.00',
            ),
            transactions: currentTransactions,
          ));
        } else {
          emit(CashError(failure.message ?? 'Failed to load balance'));
        }
    }
  }

  Future<void> _onLoadSummary(
    LoadCashSummaryEvent event,
    Emitter<CashState> emit,
  ) async {
    if (state is! CashSummaryLoaded) emit(const CashLoading());

    final result = await _cashRepository.getSummary(
      startDate: event.startDate,
      endDate: event.endDate,
    );

    switch (result) {
      case Success(:final data):
        emit(CashSummaryLoaded(data));
      case FailureResult(:final failure):
        emit(CashError(failure.message ?? 'Failed to load summary'));
    }
  }
}
