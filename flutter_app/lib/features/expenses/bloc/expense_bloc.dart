import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/result.dart';
import '../../../data/repositories/expense_repository.dart';
import '../../../shared/models/expense_model.dart';
import 'expense_event.dart';
import 'expense_state.dart';

/// Expense BLoC
class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  ExpenseBloc({
    required ExpenseRepository expenseRepository,
  })  : _expenseRepository = expenseRepository,
        super(const ExpenseInitial()) {
    on<CreateExpenseCategoryEvent>(_onCreateCategory);
    on<LoadExpenseCategoriesEvent>(_onLoadCategories);
    on<CreateExpenseEvent>(_onCreateExpense);
    on<LoadExpensesEvent>(_onLoadExpenses);
    on<LoadExpenseSummaryEvent>(_onLoadSummary);
  }

  final ExpenseRepository _expenseRepository;

  Future<void> _onCreateCategory(
    CreateExpenseCategoryEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(const ExpenseLoading());
    final result = await _expenseRepository.createCategory(
      name: event.name,
      description: event.description,
    );

    switch (result) {
      case Success(:final data):
        emit(ExpenseCategoryCreated(data));
      case FailureResult(:final failure):
        emit(ExpenseError(failure.message ?? 'Failed to create category'));
    }
  }

  Future<void> _onLoadCategories(
    LoadExpenseCategoriesEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    // Preserve existing categories if available
    List<ExpenseCategoryModel> existingCategories = [];
    if (state is ExpenseCategoriesLoaded) {
      existingCategories = (state as ExpenseCategoriesLoaded).categories;
    }

    emit(ExpenseLoading(
        preserveCategories: true, categories: existingCategories));
    final result = await _expenseRepository.getCategories();

    switch (result) {
      case Success(:final data):
        emit(ExpenseCategoriesLoaded(data));
      case FailureResult(:final failure):
        // On error, preserve existing categories if available, otherwise show error
        if (existingCategories.isNotEmpty) {
          emit(ExpenseCategoriesLoaded(existingCategories));
        } else {
          emit(ExpenseError(failure.message ?? 'Failed to load categories'));
        }
    }
  }

  Future<void> _onCreateExpense(
    CreateExpenseEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(const ExpenseLoading());
    final result = await _expenseRepository.createExpense(
      categoryId: event.categoryId,
      amount: event.amount,
      date: event.date,
      paymentMode: event.paymentMode,
      description: event.description,
    );

    switch (result) {
      case Success(:final data):
        emit(ExpenseCreated(data));
      case FailureResult(:final failure):
        emit(ExpenseError(failure.message ?? 'Failed to create expense'));
    }
  }

  Future<void> _onLoadExpenses(
    LoadExpensesEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(const ExpenseLoading());
    final result = await _expenseRepository.getExpenses(
      startDate: event.startDate,
      endDate: event.endDate,
      categoryId: event.categoryId,
    );

    switch (result) {
      case Success(:final data):
        emit(ExpensesLoaded(expenses: data));
      case FailureResult(:final failure):
        emit(ExpenseError(failure.message ?? 'Failed to load expenses'));
    }
  }

  Future<void> _onLoadSummary(
    LoadExpenseSummaryEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(const ExpenseLoading());
    final result = await _expenseRepository.getSummary(
      startDate: event.startDate,
      endDate: event.endDate,
    );

    switch (result) {
      case Success(:final data):
        emit(ExpenseSummaryLoaded(data));
      case FailureResult(:final failure):
        emit(ExpenseError(failure.message ?? 'Failed to load summary'));
    }
  }
}
