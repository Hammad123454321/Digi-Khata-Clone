import 'package:equatable/equatable.dart';

/// Reports States
abstract class ReportsState extends Equatable {
  const ReportsState();

  @override
  List<Object?> get props => [];
}

class ReportsInitial extends ReportsState {
  const ReportsInitial();
}

class ReportsLoading extends ReportsState {
  const ReportsLoading();
}

class SalesReportLoaded extends ReportsState {
  const SalesReportLoaded(this.report);

  final Map<String, dynamic> report;

  @override
  List<Object?> get props => [report];
}

class CashFlowReportLoaded extends ReportsState {
  const CashFlowReportLoaded(this.report);

  final Map<String, dynamic> report;

  @override
  List<Object?> get props => [report];
}

class ExpenseReportLoaded extends ReportsState {
  const ExpenseReportLoaded(this.report);

  final Map<String, dynamic> report;

  @override
  List<Object?> get props => [report];
}

class StockReportLoaded extends ReportsState {
  const StockReportLoaded(this.report);

  final Map<String, dynamic> report;

  @override
  List<Object?> get props => [report];
}

class ProfitLossReportLoaded extends ReportsState {
  const ProfitLossReportLoaded(this.report);

  final Map<String, dynamic> report;

  @override
  List<Object?> get props => [report];
}

class ReportsError extends ReportsState {
  const ReportsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
