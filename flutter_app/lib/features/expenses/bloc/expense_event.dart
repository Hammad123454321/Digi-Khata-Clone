import 'package:equatable/equatable.dart';

/// Expense Events
abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object?> get props => [];
}

class CreateExpenseCategoryEvent extends ExpenseEvent {
  const CreateExpenseCategoryEvent({
    required this.name,
    this.description,
  });

  final String name;
  final String? description;

  @override
  List<Object?> get props => [name, description];
}

class LoadExpenseCategoriesEvent extends ExpenseEvent {
  const LoadExpenseCategoriesEvent();
}

class CreateExpenseEvent extends ExpenseEvent {
  const CreateExpenseEvent({
    required this.categoryId,
    required this.amount,
    required this.date,
    required this.paymentMode,
    this.description,
  });

  final String categoryId;
  final String amount;
  final DateTime date;
  final String paymentMode;
  final String? description;

  @override
  List<Object?> get props =>
      [categoryId, amount, date, paymentMode, description];
}

class LoadExpensesEvent extends ExpenseEvent {
  const LoadExpensesEvent({
    this.startDate,
    this.endDate,
    this.categoryId,
    this.refresh = false,
  });

  final DateTime? startDate;
  final DateTime? endDate;
  final String? categoryId;
  final bool refresh;

  @override
  List<Object?> get props => [startDate, endDate, categoryId, refresh];
}

class LoadExpenseSummaryEvent extends ExpenseEvent {
  const LoadExpenseSummaryEvent({
    required this.startDate,
    required this.endDate,
  });

  final DateTime startDate;
  final DateTime endDate;

  @override
  List<Object?> get props => [startDate, endDate];
}
