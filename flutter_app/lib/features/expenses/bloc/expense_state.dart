import 'package:equatable/equatable.dart';
import '../../../shared/models/expense_model.dart';

/// Expense States
abstract class ExpenseState extends Equatable {
  const ExpenseState();

  @override
  List<Object?> get props => [];
}

class ExpenseInitial extends ExpenseState {
  const ExpenseInitial();
}

class ExpenseLoading extends ExpenseState {
  const ExpenseLoading(
      {this.preserveCategories = false, this.categories = const []});

  final bool preserveCategories;
  final List<ExpenseCategoryModel> categories;

  @override
  List<Object?> get props => [preserveCategories, categories];
}

class ExpenseCategoriesLoaded extends ExpenseState {
  const ExpenseCategoriesLoaded(this.categories);

  final List<ExpenseCategoryModel> categories;

  @override
  List<Object?> get props => [categories];
}

class ExpenseCategoryCreated extends ExpenseState {
  const ExpenseCategoryCreated(this.category);

  final ExpenseCategoryModel category;

  @override
  List<Object?> get props => [category];
}

class ExpensesLoaded extends ExpenseState {
  const ExpensesLoaded({
    required this.expenses,
    this.hasMore = false,
  });

  final List<ExpenseModel> expenses;
  final bool hasMore;

  @override
  List<Object?> get props => [expenses, hasMore];
}

class ExpenseCreated extends ExpenseState {
  const ExpenseCreated(this.expense);

  final ExpenseModel expense;

  @override
  List<Object?> get props => [expense];
}

class ExpenseSummaryLoaded extends ExpenseState {
  const ExpenseSummaryLoaded(this.summary);

  final Map<String, dynamic> summary;

  @override
  List<Object?> get props => [summary];
}

class ExpenseError extends ExpenseState {
  const ExpenseError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
