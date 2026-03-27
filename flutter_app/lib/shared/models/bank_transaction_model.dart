import 'package:equatable/equatable.dart';

/// Bank Transaction Model
class BankTransactionModel extends Equatable {
  const BankTransactionModel({
    required this.id,
    required this.accountId,
    required this.transactionType,
    required this.amount,
    required this.date,
    this.referenceNumber,
    this.remarks,
    this.createdAt,
  });

  final String id;
  final String accountId;
  final String transactionType; // 'deposit', 'withdrawal', 'transfer'
  final String amount;
  final DateTime date;
  final String? referenceNumber;
  final String? remarks;
  final DateTime? createdAt;

  factory BankTransactionModel.fromJson(Map<String, dynamic> json) {
    return BankTransactionModel(
      id: json['id'].toString(),
      accountId: json['bank_account_id'].toString(),
      transactionType: json['transaction_type'] as String,
      amount: json['amount'] as String,
      date: DateTime.parse(json['date'] as String),
      referenceNumber: json['reference_number'] as String?,
      remarks: json['remarks'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bank_account_id': accountId,
      'transaction_type': transactionType,
      'amount': amount,
      'date': date.toIso8601String(),
      if (referenceNumber != null) 'reference_number': referenceNumber,
      if (remarks != null) 'remarks': remarks,
    };
  }

  @override
  List<Object?> get props => [
        id,
        accountId,
        transactionType,
        amount,
        date,
        referenceNumber,
        remarks,
        createdAt,
      ];
}
