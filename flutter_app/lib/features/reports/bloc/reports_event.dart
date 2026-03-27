import 'package:equatable/equatable.dart';

/// Reports Events
abstract class ReportsEvent extends Equatable {
  const ReportsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSalesReportEvent extends ReportsEvent {
  const LoadSalesReportEvent({
    required this.startDate,
    required this.endDate,
  });

  final DateTime startDate;
  final DateTime endDate;

  @override
  List<Object?> get props => [startDate, endDate];
}

class LoadCashFlowReportEvent extends ReportsEvent {
  const LoadCashFlowReportEvent({
    required this.startDate,
    required this.endDate,
  });

  final DateTime startDate;
  final DateTime endDate;

  @override
  List<Object?> get props => [startDate, endDate];
}

class LoadExpenseReportEvent extends ReportsEvent {
  const LoadExpenseReportEvent({
    required this.startDate,
    required this.endDate,
  });

  final DateTime startDate;
  final DateTime endDate;

  @override
  List<Object?> get props => [startDate, endDate];
}

class LoadStockReportEvent extends ReportsEvent {
  const LoadStockReportEvent();
}

class LoadProfitLossReportEvent extends ReportsEvent {
  const LoadProfitLossReportEvent({
    required this.startDate,
    required this.endDate,
  });

  final DateTime startDate;
  final DateTime endDate;

  @override
  List<Object?> get props => [startDate, endDate];
}
