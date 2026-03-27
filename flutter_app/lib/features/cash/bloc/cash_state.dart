import 'package:equatable/equatable.dart';
import '../../../shared/models/cash_balance_model.dart';
import '../../../shared/models/cash_transaction_model.dart';

/// Cash States
abstract class CashState extends Equatable {
  const CashState();

  @override
  List<Object?> get props => [];
}

class CashInitial extends CashState {
  const CashInitial();
}

class CashLoading extends CashState {
  const CashLoading();
}

class CashTransactionsLoaded extends CashState {
  const CashTransactionsLoaded({
    required this.transactions,
    this.hasMore = false,
    this.balance,
  });

  final List<CashTransactionModel> transactions;
  final bool hasMore;
  final CashBalanceModel? balance;

  @override
  List<Object?> get props => [transactions, hasMore, balance];
}

class CashBalanceLoaded extends CashState {
  const CashBalanceLoaded(
    this.balance, {
    this.transactions,
  });

  final CashBalanceModel balance;
  final List<CashTransactionModel>? transactions;

  @override
  List<Object?> get props => [balance, transactions];
}

class CashSummaryLoaded extends CashState {
  const CashSummaryLoaded(this.summary);

  final Map<String, dynamic> summary;

  @override
  List<Object?> get props => [summary];
}

class CashTransactionCreated extends CashState {
  const CashTransactionCreated(this.transaction);

  final CashTransactionModel transaction;

  @override
  List<Object?> get props => [transaction];
}

class CashError extends CashState {
  const CashError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
