import 'package:equatable/equatable.dart';

/// Cash Balance Model
class CashBalanceModel extends Equatable {
  const CashBalanceModel({
    required this.date,
    required this.openingBalance,
    required this.totalCashIn,
    required this.totalCashOut,
    required this.closingBalance,
  });

  final DateTime date;
  final String openingBalance;
  final String totalCashIn;
  final String totalCashOut;
  final String closingBalance;

  // Computed properties for UI
  String get cashInHand => closingBalance;
  String get todayBalance => closingBalance;

  factory CashBalanceModel.fromJson(Map<String, dynamic> json) {
    return CashBalanceModel(
      date: DateTime.parse(json['date'] as String),
      openingBalance: json['opening_balance'] as String,
      totalCashIn: json['total_cash_in'] as String,
      totalCashOut: json['total_cash_out'] as String,
      closingBalance: json['closing_balance'] as String,
    );
  }

  @override
  List<Object?> get props => [
        date,
        openingBalance,
        totalCashIn,
        totalCashOut,
        closingBalance,
      ];
}
