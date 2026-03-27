import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/result.dart';
import '../../../data/repositories/bank_repository.dart';
import '../../../shared/models/bank_account_model.dart';
import '../../../shared/models/bank_transaction_model.dart';
import 'bank_event.dart';
import 'bank_state.dart';

/// Bank BLoC
class BankBloc extends Bloc<BankEvent, BankState> {
  BankBloc({
    required BankRepository bankRepository,
  })  : _bankRepository = bankRepository,
        super(const BankInitial()) {
    on<CreateBankAccountEvent>(_onCreateAccount);
    on<LoadBankAccountsEvent>(_onLoadAccounts);
    on<CreateBankTransactionEvent>(_onCreateTransaction);
    on<CashBankTransferEvent>(_onTransfer);
  }

  final BankRepository _bankRepository;

  Future<void> _onCreateAccount(
    CreateBankAccountEvent event,
    Emitter<BankState> emit,
  ) async {
    emit(const BankLoading());
    final result = await _bankRepository.createAccount(
      bankName: event.bankName,
      accountNumber: event.accountNumber,
      accountHolderName: event.accountHolderName,
      branch: event.branch,
      ifscCode: event.ifscCode,
      accountType: event.accountType,
      openingBalance: event.openingBalance,
    );

    switch (result) {
      case Success(:final data):
        emit(BankAccountCreated(data));
      case FailureResult(:final failure):
        emit(BankError(failure.message ?? 'Failed to create account'));
    }
  }

  Future<void> _onLoadAccounts(
    LoadBankAccountsEvent event,
    Emitter<BankState> emit,
  ) async {
    emit(const BankLoading());
    final result = await _bankRepository.getAccounts(
      isActive: event.isActive,
    );

    switch (result) {
      case Success(:final data):
        emit(BankAccountsLoaded(accounts: data));
      case FailureResult(:final failure):
        emit(BankError(failure.message ?? 'Failed to load accounts'));
    }
  }

  Future<void> _onCreateTransaction(
    CreateBankTransactionEvent event,
    Emitter<BankState> emit,
  ) async {
    emit(const BankLoading());
    final result = await _bankRepository.createTransaction(
      accountId: event.accountId,
      transactionType: event.transactionType,
      amount: event.amount,
      date: event.date,
      referenceNumber: event.referenceNumber,
      remarks: event.remarks,
    );

    switch (result) {
      case Success(:final data):
        emit(BankTransactionCreated(data));
      case FailureResult(:final failure):
        emit(BankError(failure.message ?? 'Failed to create transaction'));
    }
  }

  Future<void> _onTransfer(
    CashBankTransferEvent event,
    Emitter<BankState> emit,
  ) async {
    emit(const BankLoading());
    final result = await _bankRepository.transfer(
      accountId: event.accountId,
      transferType: event.transferType,
      amount: event.amount,
      date: event.date,
      remarks: event.remarks,
    );

    switch (result) {
      case Success():
        emit(const CashBankTransferCompleted());
      case FailureResult(:final failure):
        emit(BankError(failure.message ?? 'Failed to transfer'));
    }
  }
}
