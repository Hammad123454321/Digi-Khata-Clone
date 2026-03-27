import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/di/injection.dart';
import '../../../core/routes/app_router.dart';
import '../../../data/repositories/reports_repository.dart';
import '../../../shared/models/expense_model.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/modern_components.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../reports/bloc/reports_bloc.dart';
import '../../reports/screens/expense_report_screen.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';
import '../bloc/expense_state.dart';
import '../widgets/create_category_dialog.dart';
import 'add_expense_screen.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  DateTimeRange? _dateRange;
  String? _paymentFilter; // cash, bank, or null
  List<ExpenseModel> _cachedExpenses = [];
  List<ExpenseCategoryModel> _categories = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applyFilters);

    final now = DateTime.now();
    _dateRange = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: now,
    );

    final bloc = context.read<ExpenseBloc>();
    bloc.add(const LoadExpenseCategoriesEvent());
    _loadExpenses();
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilters);
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  DateTimeRange _currentRange() {
    final now = DateTime.now();
    return _dateRange ??
        DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: now,
        );
  }

  void _loadExpenses({bool refresh = false}) {
    final range = _currentRange();
    context.read<ExpenseBloc>().add(
          LoadExpensesEvent(
            startDate: range.start,
            endDate: range.end,
            refresh: refresh,
          ),
        );
  }

  void _applyFilters() {
    setState(() {});
  }

  Future<void> _selectDateRange() async {
    final range = _currentRange();
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: range,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && mounted) {
      setState(() {
        _dateRange = picked;
      });
      _loadExpenses(refresh: true);
    }
  }

  Future<void> _openExpenseReport() async {
    final range = _currentRange();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => ReportsBloc(
            reportsRepository: getIt<ReportsRepository>(),
          ),
          child: ExpenseReportScreen(
            startDate: range.start,
            endDate: range.end,
          ),
        ),
      ),
    );
  }

  Future<void> _openAddExpense(String paymentMode) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => BlocProvider.value(
        value: context.read<ExpenseBloc>(),
        child: AddExpenseSheet(initialPaymentMode: paymentMode),
      ),
    );

    if (result == true && mounted) {
      _loadExpenses(refresh: true);
    }
  }

  Future<void> _openCreateCategory() async {
    final created = await CreateCategoryDialog.show(context);
    if (created == true && mounted) {
      context.read<ExpenseBloc>().add(const LoadExpenseCategoriesEvent());
    }
  }

  void _setPaymentFilter(String? filter) {
    setState(() {
      _paymentFilter = filter;
    });
  }

  List<ExpenseModel> _filterExpenses(List<ExpenseModel> expenses) {
    final query = _searchController.text.trim().toLowerCase();

    return expenses.where((expense) {
      if (_paymentFilter != null && expense.paymentMode != _paymentFilter) {
        return false;
      }

      if (query.isEmpty) return true;

      final categoryName = _categoryName(expense.categoryId).toLowerCase();
      final amount = expense.amount.toLowerCase();
      final description = expense.description?.toLowerCase() ?? '';
      return categoryName.contains(query) ||
          amount.contains(query) ||
          description.contains(query);
    }).toList();
  }

  String _categoryName(String categoryId) {
    final category = _categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => ExpenseCategoryModel(id: '', name: ''),
    );
    return category.name.isEmpty
        ? AppLocalizations.of(context)!.expense
        : category.name;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.expenses,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            GestureDetector(
              onTap: () => Navigator.of(context).pushNamed(AppRouter.settings),
              child: Text(
                loc.viewSettingsHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
        ),
      ),
      body: BlocConsumer<ExpenseBloc, ExpenseState>(
        listener: (context, state) {
          if (state is ExpenseCreated) {
            _loadExpenses(refresh: true);
          } else if (state is ExpenseCategoryCreated) {
            context.read<ExpenseBloc>().add(const LoadExpenseCategoriesEvent());
          } else if (state is ExpenseError && _cachedExpenses.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ExpenseCategoriesLoaded) {
            _categories = state.categories;
          }
          if (state is ExpensesLoaded) {
            _cachedExpenses = state.expenses;
          }

          final isLoading = state is ExpenseLoading && _cachedExpenses.isEmpty;

          if (state is ExpenseError && _cachedExpenses.isEmpty) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () => _loadExpenses(refresh: true),
            );
          }

          return LoadingOverlay(
            isLoading: isLoading,
            child: _buildExpenseContent(theme),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _openAddExpense('cash'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text('${loc.cash} ${loc.expense}'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _openAddExpense('bank'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text('${loc.bank} ${loc.expense}'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseContent(ThemeData theme) {
    final loc = AppLocalizations.of(context)!;
    final dateFormatter = DateFormat.yMMMd(loc.locale.languageCode);
    final timeFormatter = DateFormat.jm(loc.locale.languageCode);
    final range = _currentRange();

    final filteredExpenses = _filterExpenses(_cachedExpenses);
    final totalExpenses = filteredExpenses.fold<double>(
      0,
      (sum, expense) => sum + (double.tryParse(expense.amount) ?? 0),
    );
    final cashExpenses = filteredExpenses.fold<double>(
      0,
      (sum, expense) => expense.paymentMode == 'cash'
          ? sum + (double.tryParse(expense.amount) ?? 0)
          : sum,
    );
    final bankExpenses = filteredExpenses.fold<double>(
      0,
      (sum, expense) => expense.paymentMode == 'bank'
          ? sum + (double.tryParse(expense.amount) ?? 0)
          : sum,
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  CurrencyUtils.formatCurrency(totalExpenses),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  loc.totalExpenses,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ExpenseMiniStat(
                        label: loc.cash,
                        amount: cashExpenses,
                        color: AppTheme.errorColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ExpenseMiniStat(
                        label: loc.bank,
                        amount: bankExpenses,
                        color: AppTheme.successColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                QuickActionButton(
                  icon: Icons.assessment_outlined,
                  label: loc.report,
                  onTap: _openExpenseReport,
                ),
                const SizedBox(width: 12),
                QuickActionButton(
                  icon: Icons.calendar_today,
                  label: loc.setDate,
                  onTap: _selectDateRange,
                ),
                const SizedBox(width: 12),
                QuickActionButton(
                  icon: Icons.receipt_long,
                  label: loc.addExpense,
                  onTap: () => _openAddExpense('cash'),
                ),
                const SizedBox(width: 12),
                QuickActionButton(
                  icon: Icons.category_outlined,
                  label: loc.createCategory,
                  onTap: _openCreateCategory,
                ),
              ],
            ),
          ),
        ),
        if (_dateRange != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Icon(
                  Icons.filter_alt,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  '${dateFormatter.format(range.start)} - ${dateFormatter.format(range.end)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocus,
            decoration: InputDecoration(
              hintText: loc.search,
              prefixIcon: const Icon(Icons.search),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              _TypeChip(
                label: loc.all,
                isSelected: _paymentFilter == null,
                onTap: () => _setPaymentFilter(null),
              ),
              const SizedBox(width: 8),
              _TypeChip(
                label: loc.cash,
                isSelected: _paymentFilter == 'cash',
                onTap: () => _setPaymentFilter('cash'),
              ),
              const SizedBox(width: 8),
              _TypeChip(
                label: loc.bank,
                isSelected: _paymentFilter == 'bank',
                onTap: () => _setPaymentFilter('bank'),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  loc.entries,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  loc.cash,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.errorColor,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  loc.bank,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.successColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _cachedExpenses.isEmpty
              ? Center(
                  child: EmptyState(
                    icon: Icons.receipt_long,
                    title: loc.noExpenses,
                    message: loc.startTrackingExpenses,
                  ),
                )
              : filteredExpenses.isEmpty
                  ? Center(
                      child: Text(
                        loc.noTransactionsFound,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: filteredExpenses.length,
                      itemBuilder: (context, index) {
                        final expense = filteredExpenses[index];
                        final isCash = expense.paymentMode == 'cash';
                        final amount = CurrencyUtils.formatCurrency(
                          double.tryParse(expense.amount) ?? 0,
                        );
                        final title = _categoryName(expense.categoryId);
                        final dateText =
                            '${dateFormatter.format(expense.date)} • ${timeFormatter.format(expense.date)}';
                        final description =
                            expense.description?.trim().isNotEmpty == true
                                ? expense.description!.trim()
                                : null;

                        return AppCard(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: EdgeInsets.zero,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        dateText,
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      if (description != null) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          description,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: theme
                                                .colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                              _ExpenseAmountCell(
                                amount: isCash ? amount : '',
                                highlight: isCash,
                                color: AppTheme.errorColor,
                              ),
                              _ExpenseAmountCell(
                                amount: isCash ? '' : amount,
                                highlight: !isCash,
                                color: AppTheme.successColor,
                                isLast: true,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

class _ExpenseMiniStat extends StatelessWidget {
  const _ExpenseMiniStat({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            CurrencyUtils.formatCurrency(amount),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.12)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ExpenseAmountCell extends StatelessWidget {
  const _ExpenseAmountCell({
    required this.amount,
    required this.highlight,
    required this.color,
    this.isLast = false,
  });

  final String amount;
  final bool highlight;
  final Color color;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: highlight ? color.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: isLast
              ? const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                )
              : null,
        ),
        child: Text(
          amount,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: highlight ? color : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
