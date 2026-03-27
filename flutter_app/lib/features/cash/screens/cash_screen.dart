import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/di/injection.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/repositories/reports_repository.dart';
import '../../../shared/models/cash_balance_model.dart';
import '../../../shared/models/cash_transaction_model.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/modern_components.dart';
import '../../reports/bloc/reports_bloc.dart';
import '../../reports/screens/cash_flow_report_screen.dart';
import '../bloc/cash_bloc.dart';
import '../bloc/cash_event.dart';
import '../bloc/cash_state.dart';
import 'add_cash_transaction_screen.dart';

class CashScreen extends StatefulWidget {
  const CashScreen({super.key});

  @override
  State<CashScreen> createState() => _CashScreenState();
}

class _CashScreenState extends State<CashScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applyFilters);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadData();
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilters);
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _loadData({bool refresh = false}) {
    final bloc = context.read<CashBloc>();
    final range = _currentRange();
    bloc.add(LoadDailyBalanceEvent(range.end));
    bloc.add(
      LoadCashTransactionsEvent(
        startDate: range.start,
        endDate: range.end,
        refresh: refresh,
      ),
    );
  }

  DateTimeRange _currentRange() {
    final now = AppDateUtils.today();
    return _dateRange ??
        DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: now,
        );
  }

  void _applyFilters() {
    setState(() {});
  }

  Future<void> _selectDateRange() async {
    final now = AppDateUtils.today();
    final initialRange = _dateRange ??
        DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: now,
        );

    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: initialRange,
      firstDate: DateTime(2020),
      lastDate: now,
    );

    if (picked != null && mounted) {
      setState(() {
        _dateRange = picked;
      });
      _loadData(refresh: true);
    }
  }

  Future<void> _openCashTransactionSheet(String initialType) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => BlocProvider.value(
        value: context.read<CashBloc>(),
        child: AddCashTransactionSheet(initialType: initialType),
      ),
    );

    if (result == true && mounted) {
      _loadData(refresh: true);
    }
  }

  Future<void> _openCashReport() async {
    final range = _currentRange();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => ReportsBloc(
            reportsRepository: getIt<ReportsRepository>(),
          ),
          child: CashFlowReportScreen(
            startDate: range.start,
            endDate: range.end,
          ),
        ),
      ),
    );
  }

  List<CashTransactionModel> _filterTransactions(
    List<CashTransactionModel> transactions,
  ) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return transactions;

    return transactions.where((transaction) {
      final source = transaction.source?.toLowerCase() ?? '';
      final remarks = transaction.remarks?.toLowerCase() ?? '';
      final amount = transaction.amount.toLowerCase();
      final type = transaction.transactionType.toLowerCase();

      return source.contains(query) ||
          remarks.contains(query) ||
          amount.contains(query) ||
          type.contains(query);
    }).toList();
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
              loc.cash,
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
      body: BlocBuilder<CashBloc, CashState>(
        builder: (context, state) {
          CashBalanceModel? balance;
          List<CashTransactionModel>? transactions;

          if (state is CashBalanceLoaded) {
            balance = state.balance;
            transactions = state.transactions;
          } else if (state is CashTransactionsLoaded) {
            transactions = state.transactions;
            balance = state.balance;
          }

          final isLoading = (state is CashLoading || state is CashInitial) &&
              balance == null &&
              transactions == null;

          if (state is CashError && balance == null && transactions == null) {
            return Center(
              child: AppErrorWidget(
                message: state.message,
                onRetry: () => _loadData(refresh: true),
              ),
            );
          }

          return LoadingOverlay(
            isLoading: isLoading,
            child: _buildCashContent(
              balance,
              transactions ?? const [],
              theme,
              loc,
            ),
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
                  onPressed: () => _openCashTransactionSheet('cash_out'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    '${loc.cashOut} ${CurrencyUtils.getCurrentCurrency().symbol}',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _openCashTransactionSheet('cash_in'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    '${loc.cashIn} ${CurrencyUtils.getCurrentCurrency().symbol}',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCashContent(
    CashBalanceModel? balance,
    List<CashTransactionModel> transactions,
    ThemeData theme,
    AppLocalizations loc,
  ) {
    final dateFormatter = DateFormat.yMMMd(loc.locale.languageCode);
    final timeFormatter = DateFormat.jm(loc.locale.languageCode);
    final range = _currentRange();

    final balanceValue = double.tryParse(balance?.cashInHand ?? '0') ?? 0.0;
    final totalCashIn = double.tryParse(balance?.totalCashIn ?? '0') ?? 0.0;
    final totalCashOut = double.tryParse(balance?.totalCashOut ?? '0') ?? 0.0;

    final filteredTransactions = _filterTransactions(transactions);

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
                  CurrencyUtils.formatCurrency(balanceValue),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  loc.cashBalance,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _CashMiniStat(
                        label: loc.cashIn,
                        amount: totalCashIn,
                        color: AppTheme.successColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CashMiniStat(
                        label: loc.cashOut,
                        amount: totalCashOut,
                        color: AppTheme.errorColor,
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
                  onTap: _openCashReport,
                ),
                const SizedBox(width: 12),
                QuickActionButton(
                  icon: Icons.calendar_today,
                  label: loc.setDate,
                  onTap: _selectDateRange,
                ),
                const SizedBox(width: 12),
                QuickActionButton(
                  icon: Icons.remove_circle_outline,
                  label: loc.cashOut,
                  onTap: () => _openCashTransactionSheet('cash_out'),
                ),
                const SizedBox(width: 12),
                QuickActionButton(
                  icon: Icons.add_circle_outline,
                  label: loc.cashIn,
                  onTap: () => _openCashTransactionSheet('cash_in'),
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
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
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
                  loc.cashOut,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.errorColor,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  loc.cashIn,
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
          child: transactions.isEmpty
              ? Center(
                  child: EmptyState(
                    icon: Icons.account_balance_wallet,
                    title: loc.noTransactionsYet,
                    message: loc.startByAddingCashTransaction,
                  ),
                )
              : filteredTransactions.isEmpty
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
                      itemCount: filteredTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction = filteredTransactions[index];
                        final isCashIn =
                            transaction.transactionType == 'cash_in';
                        final amount = CurrencyUtils.formatCurrency(
                          double.tryParse(transaction.amount) ?? 0,
                        );
                        final title =
                            transaction.source?.trim().isNotEmpty == true
                                ? transaction.source!.trim()
                                : isCashIn
                                    ? loc.cashIn
                                    : loc.cashOut;
                        final dateText =
                            '${dateFormatter.format(transaction.date)} • ${timeFormatter.format(transaction.date)}';
                        final remarks =
                            transaction.remarks?.trim().isNotEmpty == true
                                ? transaction.remarks!.trim()
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
                                      if (remarks != null) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          remarks,
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
                              _CashAmountCell(
                                amount: isCashIn ? '' : amount,
                                highlight: !isCashIn,
                                color: AppTheme.errorColor,
                              ),
                              _CashAmountCell(
                                amount: isCashIn ? amount : '',
                                highlight: isCashIn,
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

class _CashMiniStat extends StatelessWidget {
  const _CashMiniStat({
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

class _CashAmountCell extends StatelessWidget {
  const _CashAmountCell({
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
