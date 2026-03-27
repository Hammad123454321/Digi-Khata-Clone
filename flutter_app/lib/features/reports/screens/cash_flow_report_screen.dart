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

class CashFlowReportScreen extends StatefulWidget {
  const CashFlowReportScreen({
    super.key,
    required this.startDate,
    required this.endDate,
  });

  final DateTime startDate;
  final DateTime endDate;

  @override
  State<CashFlowReportScreen> createState() => _CashFlowReportScreenState();
}

class _CashFlowReportScreenState extends State<CashFlowReportScreen> {
  Map<String, dynamic>? _currentReport;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  void _loadReport() {
    context.read<ReportsBloc>().add(
          LoadCashFlowReportEvent(
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
      title: loc.cashFlowReport,
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
          loc.cashFlowReport,
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

    if (state is CashFlowReportLoaded) {
      final report = state.report;
      _currentReport = report;
      final isOffline = report['is_offline'] == true;
      final openingBalance = double.tryParse(
            report['opening_balance']?.toString() ?? '0',
          ) ??
          0;
      final closingBalance = double.tryParse(
            report['closing_balance']?.toString() ?? '0',
          ) ??
          0;
      final totalInflow = double.tryParse(
            report['total_inflow']?.toString() ?? '0',
          ) ??
          0;
      final totalOutflow = double.tryParse(
            report['total_outflow']?.toString() ?? '0',
          ) ??
          0;
      final netCashFlow = totalInflow - totalOutflow;

      final transactions = report['transactions'] as List<dynamic>? ?? [];

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
                          loc.openingBalance,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          CurrencyUtils.formatCurrency(openingBalance),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
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
                          loc.closingBalance,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          CurrencyUtils.formatCurrency(closingBalance),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
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
                            const Icon(Icons.arrow_downward,
                                size: 16, color: Colors.green),
                            const SizedBox(width: 4),
                            Text(
                              loc.totalInflow,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyUtils.formatCurrency(totalInflow),
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
                            const Icon(Icons.arrow_upward,
                                size: 16, color: Colors.red),
                            const SizedBox(width: 4),
                            Text(
                              loc.totalOutflow,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyUtils.formatCurrency(totalOutflow),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AppCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loc.netCashFlow,
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    CurrencyUtils.formatCurrency(netCashFlow),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: netCashFlow >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              loc.transactions,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (transactions.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(loc.noTransactionsFound),
                ),
              )
            else
              ...transactions.map((txn) {
                final amount = double.tryParse(
                      txn['amount']?.toString() ?? '0',
                    ) ??
                    0;
                final isInflow = txn['type'] == 'inflow' || amount > 0;
                final date = txn['date'] != null
                    ? DateFormat.yMMMd(loc.locale.languageCode)
                        .format(DateTime.parse(txn['date'] as String))
                    : '';

                return AppCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              txn['description'] ?? loc.transaction,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (date.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                date,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Text(
                        CurrencyUtils.formatCurrency(amount.abs()),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isInflow ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      );
    }

    return const Center(child: CircularProgressIndicator());
  }
}
