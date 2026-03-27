import 'package:equatable/equatable.dart';

/// Bank Events
abstract class BankEvent extends Equatable {
  const BankEvent();

  @override
  List<Object?> get props => [];
}

class CreateBankAccountEvent extends BankEvent {
  const CreateBankAccountEvent({
    required this.bankName,
    required this.accountNumber,
    this.accountHolderName,
    this.branch,
    this.ifscCode,
    this.accountType,
    required this.openingBalance,
  });

  final String bankName;
  final String accountNumber;
  final String? accountHolderName;
  final String? branch;
  final String? ifscCode;
  final String? accountType;
  final String openingBalance;

  @override
  List<Object?> get props => [
        bankName,
        accountNumber,
        accountHolderName,
        branch,
        ifscCode,
        accountType,
        openingBalance,
      ];
}

class LoadBankAccountsEvent extends BankEvent {
  const LoadBankAccountsEvent({
    this.isActive,
    this.refresh = false,
  });

  final bool? isActive;
  final bool refresh;

  @override
  List<Object?> get props => [isActive, refresh];
}

class CreateBankTransactionEvent extends BankEvent {
  const CreateBankTransactionEvent({
    required this.accountId,
    required this.transactionType,
    required this.amount,
    required this.date,
    this.referenceNumber,
    this.remarks,
  });

  final String accountId;
  final String transactionType;
  final String amount;
  final DateTime date;
  final String? referenceNumber;
  final String? remarks;

  @override
  List<Object?> get props => [
        accountId,
        transactionType,
        amount,
        date,
        referenceNumber,
        remarks,
      ];
}

class CashBankTransferEvent extends BankEvent {
  const CashBankTransferEvent({
    required this.accountId,
    required this.transferType,
    required this.amount,
    required this.date,
    this.remarks,
  });

  final String accountId;
  final String transferType;
  final String amount;
  final DateTime date;
  final String? remarks;

  @override
  List<Object?> get props => [accountId, transferType, amount, date, remarks];
}
