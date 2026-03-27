import 'package:equatable/equatable.dart';
import '../../../shared/models/bank_account_model.dart';
import '../../../shared/models/bank_transaction_model.dart';

/// Bank States
abstract class BankState extends Equatable {
  const BankState();

  @override
  List<Object?> get props => [];
}

class BankInitial extends BankState {
  const BankInitial();
}

class BankLoading extends BankState {
  const BankLoading();
}

class BankAccountsLoaded extends BankState {
  const BankAccountsLoaded({
    required this.accounts,
    this.hasMore = false,
  });

  final List<BankAccountModel> accounts;
  final bool hasMore;

  @override
  List<Object?> get props => [accounts, hasMore];
}

class BankAccountCreated extends BankState {
  const BankAccountCreated(this.account);

  final BankAccountModel account;

  @override
  List<Object?> get props => [account];
}

class BankTransactionCreated extends BankState {
  const BankTransactionCreated(this.transaction);

  final BankTransactionModel transaction;

  @override
  List<Object?> get props => [transaction];
}

class CashBankTransferCompleted extends BankState {
  const CashBankTransferCompleted();
}

class BankError extends BankState {
  const BankError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
