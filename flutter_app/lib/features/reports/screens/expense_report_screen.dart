import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../utils/report_exporter.dart';
import '../bloc/reports_bloc.dart';
import '../bloc/reports_event.dart';
import '../bloc/reports_state.dart';

class ExpenseReportScreen extends StatefulWidget {
  const ExpenseReportScreen({
    super.key,
    required this.startDate,
    required this.endDate,
  });

  final DateTime startDate;
  final DateTime endDate;

  @override
  State<ExpenseReportScreen> createState() => _ExpenseReportScreenState();
}

class _ExpenseReportScreenState extends State<ExpenseReportScreen> {
  Map<String, dynamic>? _currentReport;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  void _loadReport() {
    context.read<ReportsBloc>().add(
          LoadExpenseReportEvent(
            startDate: widget.startDate,
            endDate: widget.endDate,
          ),
        );
  }

  Future<void> _shareReport() async {
    final report = _currentReport;
    if (report == null) return;
    final loc = AppLocalizations.of(context)!;
    await ReportExporter.shareReportPdf(
      loc: loc,
      title: loc.expenseReport,
      report: report,
      startDate: widget.startDate,
      endDate: widget.endDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          loc.expenseReport,
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Share',
            onPressed: _currentReport == null ? null : _shareReport,
            icon: const Icon(Icons.share, color: Colors.white),
          ),
        ],
      ),
      body: BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          return LoadingOverlay(
            isLoading: state is ReportsLoading,
            child: _buildReportContent(state, theme),
          );
        },
      ),
    );
  }

  Widget _buildReportContent(
    ReportsState state,
    ThemeData theme,
  ) {
    final loc = AppLocalizations.of(context)!;
    if (state is ReportsError) {
      return AppErrorWidget(
        message: state.message,
        onRetry: _loadReport,
      );
    }

    if (state is ExpenseReportLoaded) {
      final report = state.report;
      _currentReport = report;
      final isOffline = report['is_offline'] == true;
      final totalExpenses = double.tryParse(
            report['total_expenses']?.toString() ?? '0',
          ) ??
          0;
      final cashExpenses = double.tryParse(
            report['cash_expenses']?.toString() ?? '0',
          ) ??
          0;
      final bankExpenses = double.tryParse(
            report['bank_expenses']?.toString() ?? '0',
          ) ??
          0;
      final totalCount = report['total_count'] ?? 0;

      final categoryBreakdown =
          report['category_breakdown'] as List<dynamic>? ?? [];
      final dailyBreakdown = report['daily_breakdown'] as List<dynamic>? ?? [];

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isOffline) ...[
              const OfflineBanner(),
              const SizedBox(height: 12),
            ],
            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.totalExpenses,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          CurrencyUtils.formatCurrency(totalExpenses),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.transactions,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          totalCount.toString(),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.money,
                                size: 16, color: Colors.green),
                            const SizedBox(width: 4),
                            Text(
                              loc.cash,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyUtils.formatCurrency(cashExpenses),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.account_balance,
                                size: 16, color: Colors.blue),
                            const SizedBox(width: 4),
                            Text(
                              loc.bank,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyUtils.formatCurrency(bankExpenses),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (categoryBreakdown.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                loc.byCategory,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...categoryBreakdown.map((category) {
                final amount = double.tryParse(
                      category['amount']?.toString() ?? '0',
                    ) ??
                    0;
                final percentage = totalExpenses > 0
                    ? (amount / totalExpenses * 100).toStringAsFixed(1)
                    : '0.0';

                return AppCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            category['category_name'] ?? loc.uncategorized,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            CurrencyUtils.formatCurrency(amount),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        loc.percentOfTotal.replaceAll('{percent}', percentage),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
            if (dailyBreakdown.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                loc.dailyBreakdown,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...dailyBreakdown.map((day) {
                final amount = double.tryParse(
                      day['amount']?.toString() ?? '0',
                    ) ??
                    0;
                final date = day['date'] != null
                    ? DateFormat.yMMMd(loc.locale.languageCode)
                        .format(DateTime.parse(day['date'] as String))
                    : '';

                return AppCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        date,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        CurrencyUtils.formatCurrency(amount),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      );
    }

    return const Center(child: CircularProgressIndicator());
  }
}
