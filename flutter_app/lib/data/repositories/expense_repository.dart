import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/result.dart';
import '../../core/constants/api_constants.dart';
import '../../core/database/app_database.dart';
import '../../core/sync/sync_queue.dart';
import '../../shared/models/expense_model.dart';

/// Expense Repository
class ExpenseRepository {
  ExpenseRepository({
    required ApiClient apiClient,
    required AppDatabase appDatabase,
    required SyncQueue syncQueue,
  })  : _apiClient = apiClient,
        _appDatabase = appDatabase,
        _syncQueue = syncQueue;

  final ApiClient _apiClient;
  final AppDatabase _appDatabase;
  final SyncQueue _syncQueue;

  /// Create expense category
  Future<Result<ExpenseCategoryModel>> createCategory({
    required String name,
    String? description,
  }) async {
    final payload = <String, dynamic>{
      'name': name,
      if (description != null) 'description': description,
    };
    try {
      final response = await _apiClient.post(
        ApiConstants.expenseCategories,
        data: payload,
      );

      final category = ExpenseCategoryModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      await _appDatabase.upsertExpenseCategories([
        _expenseCategoryCompanionFromModel(category),
      ]);

      return Result.success(category);
    } on AppException catch (e) {
      if (e is NetworkException || e is TimeoutException) {
        final category = await _createCategoryOffline(payload);
        return Result.success(category);
      }
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  /// Get expense categories
  Future<Result<List<ExpenseCategoryModel>>> getCategories() async {
    List<ExpenseCategoryModel> localCategories = [];
    try {
      final localRows = await _appDatabase.fetchExpenseCategories();
      localCategories = localRows.map(_expenseCategoryFromRow).toList();
    } catch (_) {}

    try {
      final response = await _apiClient.get(ApiConstants.expenseCategories);

      final categories = (response.data as List<dynamic>)
          .map((e) => ExpenseCategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();

      await _appDatabase.upsertExpenseCategories(
        categories.map(_expenseCategoryCompanionFromModel).toList(),
      );

      return Result.success(categories);
    } on AppException catch (e) {
      if (localCategories.isNotEmpty ||
          e is NetworkException ||
          e is TimeoutException) {
        return Result.success(localCategories);
      }
      return Result.failure(_mapExceptionToFailure(e));
    } catch (e) {
      return Result.success(localCategories);
    }
  }

  /// Create expense
  Future<Result<ExpenseModel>> createExpense({
    required String categoryId,
    required String amount,
    required DateTime date,
    required String paymentMode,
    String? description,
  }) async {
    final payload = <String, dynamic>{
      'category_id': categoryId,
      'amount': amount,
      'date': date.toIso8601String(),
      'payment_mode': paymentMode,
      if (description != null) 'description': description,
    };
    try {
      final response = await _apiClient.post(
        ApiConstants.expenses,
        data: payload,
      );

      final expense = ExpenseModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      await _appDatabase.upsertExpenses([
        _expenseCompanionFromModel(expense),
      ]);

      return Result.success(expense);
    } on AppException catch (e) {
      if (e is NetworkException || e is TimeoutException) {
        final expense = await _createExpenseOffline(payload);
        return Result.success(expense);
      }
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  /// Get expenses
  Future<Result<List<ExpenseModel>>> getExpenses({
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    int limit = 100,
    int offset = 0,
  }) async {
    List<ExpenseModel> localExpenses = [];
    try {
      final localRows = await _appDatabase.fetchExpenses(
        startDate: startDate,
        endDate: endDate,
        categoryId: categoryId,
        limit: limit,
        offset: offset,
      );
      localExpenses = localRows.map(_expenseFromRow).toList();
    } catch (_) {}

    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };

      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }
      if (categoryId != null) {
        queryParams['category_id'] = categoryId;
      }

      final response = await _apiClient.get(
        ApiConstants.expenses,
        queryParameters: queryParams,
      );

      final expenses = (response.data as List<dynamic>)
          .map((e) => ExpenseModel.fromJson(e as Map<String, dynamic>))
          .toList();

      await _appDatabase.upsertExpenses(
        expenses.map(_expenseCompanionFromModel).toList(),
      );

      return Result.success(expenses);
    } on AppException catch (e) {
      if (localExpenses.isNotEmpty ||
          e is NetworkException ||
          e is TimeoutException) {
        return Result.success(localExpenses);
      }
      return Result.failure(_mapExceptionToFailure(e));
    } catch (e) {
      return Result.success(localExpenses);
    }
  }

  /// Get expense summary
  Future<Result<Map<String, dynamic>>> getSummary({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.expenses}/summary',
        data: {
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
        },
      );

      return Result.success(response.data as Map<String, dynamic>);
    } on AppException catch (e) {
      if (e is NetworkException || e is TimeoutException) {
        final summary = await _computeLocalSummary(
          startDate: startDate,
          endDate: endDate,
        );
        if (summary != null) {
          return Result.success(summary);
        }
      }
      return Result.failure(_mapExceptionToFailure(e));
    } catch (e) {
      final summary = await _computeLocalSummary(
        startDate: startDate,
        endDate: endDate,
      );
      if (summary != null) {
        return Result.success(summary);
      }
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  Failure _mapExceptionToFailure(AppException exception) {
    return switch (exception) {
      NetworkException() => NetworkFailure(exception.message),
      ServerException() => ServerFailure(exception.message),
      TimeoutException() => TimeoutFailure(exception.message),
      ValidationException() => ValidationFailure(
          exception.message,
          exception.errors,
        ),
      _ => UnknownFailure(exception.message),
    };
  }

  ExpenseCategoryModel _expenseCategoryFromRow(ExpenseCategory row) {
    return ExpenseCategoryModel(
      id: row.serverId ?? row.clientId ?? row.id.toString(),
      name: row.name,
      description: row.description,
      isActive: row.isActive,
    );
  }

  ExpenseCategoryModel _expenseCategoryModelFromPayload(
    Map<String, dynamic> payload,
    String clientId,
  ) {
    return ExpenseCategoryModel(
      id: clientId,
      name: payload['name'] as String,
      description: payload['description'] as String?,
      isActive: true,
    );
  }

  ExpenseCategoriesCompanion _expenseCategoryCompanionFromModel(
    ExpenseCategoryModel model,
  ) {
    return ExpenseCategoriesCompanion(
      serverId: Value(model.id),
      name: Value(model.name),
      description: Value(model.description),
      isActive: Value(model.isActive ?? true),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
      isSynced: const Value(true),
      syncStatus: const Value('synced'),
    );
  }

  ExpenseModel _expenseFromRow(Expense row) {
    return ExpenseModel(
      id: row.serverId ?? row.clientId ?? row.id.toString(),
      categoryId: row.categoryId,
      amount: row.amount,
      date: row.date,
      paymentMode: row.paymentMode,
      description: row.description,
      createdAt: row.createdAt,
    );
  }

  ExpensesCompanion _expenseCompanionFromModel(ExpenseModel model) {
    return ExpensesCompanion(
      serverId: Value(model.id),
      categoryId: Value(model.categoryId),
      amount: Value(model.amount),
      date: Value(model.date),
      paymentMode: Value(model.paymentMode),
      description: Value(model.description),
      createdAt: Value(model.createdAt),
      isSynced: const Value(true),
      syncStatus: const Value('synced'),
    );
  }

  Future<ExpenseCategoryModel> _createCategoryOffline(
    Map<String, dynamic> payload,
  ) async {
    final now = DateTime.now();
    final clientId = const Uuid().v4();

    final localId =
        await _appDatabase.into(_appDatabase.expenseCategories).insert(
              ExpenseCategoriesCompanion.insert(
                name: payload['name'] as String,
                clientId: Value(clientId),
                description: Value(payload['description'] as String?),
                isActive: const Value(true),
                createdAt: Value(now),
                updatedAt: Value(now),
                isSynced: const Value(false),
                syncStatus: const Value('pending'),
              ),
            );

    await _syncQueue.enqueue(
      entityType: 'expense_category',
      action: 'create',
      entityId: localId,
      data: {
        ...payload,
        'client_id': clientId,
        'updated_at': now.toIso8601String(),
      },
    );

    return _expenseCategoryModelFromPayload(payload, clientId);
  }

  Future<ExpenseModel> _createExpenseOffline(
    Map<String, dynamic> payload,
  ) async {
    final now = DateTime.now();
    final clientId = const Uuid().v4();
    final date = DateTime.parse(payload['date'] as String);

    final localId = await _appDatabase.into(_appDatabase.expenses).insert(
          ExpensesCompanion.insert(
            clientId: Value(clientId),
            categoryId: payload['category_id']?.toString() ?? '',
            amount: payload['amount']?.toString() ?? '0',
            date: date,
            paymentMode: payload['payment_mode']?.toString() ?? 'cash',
            description: Value(payload['description'] as String?),
            createdAt: Value(now),
            isSynced: const Value(false),
            syncStatus: const Value('pending'),
          ),
        );

    await _syncQueue.enqueue(
      entityType: 'expense',
      action: 'create',
      entityId: localId,
      data: {
        ...payload,
        'client_id': clientId,
        'updated_at': now.toIso8601String(),
      },
    );

    return ExpenseModel(
      id: clientId,
      categoryId: payload['category_id']?.toString() ?? '',
      amount: payload['amount']?.toString() ?? '0',
      date: date,
      paymentMode: payload['payment_mode']?.toString() ?? 'cash',
      description: payload['description'] as String?,
      createdAt: now,
    );
  }

  Future<Map<String, dynamic>?> _computeLocalSummary({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final rangeStart = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
      );
      final rangeEnd = DateTime(
        endDate.year,
        endDate.month,
        endDate.day,
        23,
        59,
        59,
        999,
      );

      final expenses = await _appDatabase.fetchExpenses(
        startDate: rangeStart,
        endDate: rangeEnd,
        limit: 1000000,
      );
      final categories = await _appDatabase.fetchExpenseCategories(
        limit: 1000000,
      );
      final categoryNameById = {
        for (final category in categories)
          (category.serverId ?? category.clientId ?? category.id.toString()):
              category.name,
      };

      double total = 0;
      double cash = 0;
      double bank = 0;
      final byCategory = <String, double>{};
      for (final expense in expenses) {
        final amount = _parseAmount(expense.amount);
        total += amount;
        if (expense.paymentMode == 'bank') {
          bank += amount;
        } else {
          cash += amount;
        }
        byCategory[expense.categoryId] =
            (byCategory[expense.categoryId] ?? 0) + amount;
      }

      final categoryBreakdown = byCategory.entries.map((entry) {
        return {
          'category_id': entry.key,
          'category_name': categoryNameById[entry.key] ?? 'Uncategorized',
          'amount': entry.value.toStringAsFixed(2),
        };
      }).toList()
        ..sort((a, b) {
          final bAmount = _parseAmount(b['amount']?.toString());
          final aAmount = _parseAmount(a['amount']?.toString());
          return bAmount.compareTo(aAmount);
        });

      return {
        'start_date': rangeStart.toIso8601String(),
        'end_date': rangeEnd.toIso8601String(),
        'total_expense': total.toStringAsFixed(2),
        'cash_expense': cash.toStringAsFixed(2),
        'bank_expense': bank.toStringAsFixed(2),
        'total_count': expenses.length,
        'category_breakdown': categoryBreakdown,
        'is_offline': true,
      };
    } catch (_) {
      return null;
    }
  }

  double _parseAmount(String? value) {
    return double.tryParse(value ?? '') ?? 0;
  }
}
