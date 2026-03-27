import 'package:equatable/equatable.dart';

/// Cash Transaction Model
class CashTransactionModel extends Equatable {
  const CashTransactionModel({
    required this.id,
    required this.transactionType,
    required this.amount,
    required this.date,
    this.source,
    this.remarks,
    this.createdAt,
  });

  final String id;
  final String transactionType; // 'cash_in' or 'cash_out'
  final String amount;
  final DateTime date;
  final String? source;
  final String? remarks;
  final DateTime? createdAt;

  factory CashTransactionModel.fromJson(Map<String, dynamic> json) {
    return CashTransactionModel(
      id: json['id'].toString(),
      transactionType: json['transaction_type'] as String,
      amount: json['amount'] as String,
      date: DateTime.parse(json['date'] as String),
      source: json['source'] as String?,
      remarks: json['remarks'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_type': transactionType,
      'amount': amount,
      'date': date.toIso8601String(),
      if (source != null) 'source': source,
      if (remarks != null) 'remarks': remarks,
    };
  }

  @override
  List<Object?> get props => [
        id,
        transactionType,
        amount,
        date,
        source,
        remarks,
        createdAt,
      ];
}
