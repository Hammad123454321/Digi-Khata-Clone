import 'package:equatable/equatable.dart';

/// Cash Events
abstract class CashEvent extends Equatable {
  const CashEvent();

  @override
  List<Object?> get props => [];
}

class CreateCashTransactionEvent extends CashEvent {
  const CreateCashTransactionEvent({
    required this.transactionType,
    required this.amount,
    required this.date,
    this.source,
    this.remarks,
  });

  final String transactionType;
  final String amount;
  final DateTime date;
  final String? source;
  final String? remarks;

  @override
  List<Object?> get props => [transactionType, amount, date, source, remarks];
}

class LoadCashTransactionsEvent extends CashEvent {
  const LoadCashTransactionsEvent({
    this.startDate,
    this.endDate,
    this.refresh = false,
  });

  final DateTime? startDate;
  final DateTime? endDate;
  final bool refresh;

  @override
  List<Object?> get props => [startDate, endDate, refresh];
}

class LoadDailyBalanceEvent extends CashEvent {
  const LoadDailyBalanceEvent(this.date);

  final DateTime date;

  @override
  List<Object?> get props => [date];
}

class LoadCashSummaryEvent extends CashEvent {
  const LoadCashSummaryEvent({
    required this.startDate,
    required this.endDate,
  });

  final DateTime startDate;
  final DateTime endDate;

  @override
  List<Object?> get props => [startDate, endDate];
}
