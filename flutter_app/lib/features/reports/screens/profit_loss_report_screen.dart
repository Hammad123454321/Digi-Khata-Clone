import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

class ProfitLossReportScreen extends StatefulWidget {
  const ProfitLossReportScreen({
    super.key,
    required this.startDate,
    required this.endDate,
  });

  final DateTime startDate;
  final DateTime endDate;

  @override
  State<ProfitLossReportScreen> createState() => _ProfitLossReportScreenState();
}

class _ProfitLossReportScreenState extends State<ProfitLossReportScreen> {
  Map<String, dynamic>? _currentReport;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  void _loadReport() {
    context.read<ReportsBloc>().add(
          LoadProfitLossReportEvent(
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
      title: loc.profitLossReport,
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
          loc.profitLossReport,
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

    if (state is ProfitLossReportLoaded) {
      final report = state.report;
      _currentReport = report;
      final isOffline = report['is_offline'] == true;
      final totalRevenue = double.tryParse(
            report['total_revenue']?.toString() ?? '0',
          ) ??
          0;
      final totalExpenses = double.tryParse(
            report['total_expenses']?.toString() ?? '0',
          ) ??
          0;
      final grossProfit = totalRevenue - totalExpenses;
      final profitMargin = totalRevenue > 0
          ? (grossProfit / totalRevenue * 100).toStringAsFixed(1)
          : '0.0';

      final revenueBreakdown =
          report['revenue_breakdown'] as Map<String, dynamic>? ?? {};
      final expenseBreakdown =
          report['expense_breakdown'] as Map<String, dynamic>? ?? {};

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
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.totalRevenue,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    CurrencyUtils.formatCurrency(totalRevenue),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
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
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.netProfitLoss,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    CurrencyUtils.formatCurrency(grossProfit),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: grossProfit >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    loc.profitMarginLabel.replaceAll('{percent}', profitMargin),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (revenueBreakdown.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                loc.revenueBreakdown,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...revenueBreakdown.entries.map((entry) {
                final amount =
                    double.tryParse(entry.value?.toString() ?? '0') ?? 0;
                return AppCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key.replaceAll('_', ' ').toUpperCase(),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        CurrencyUtils.formatCurrency(amount),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
            if (expenseBreakdown.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                loc.expenseBreakdown,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...expenseBreakdown.entries.map((entry) {
                final amount =
                    double.tryParse(entry.value?.toString() ?? '0') ?? 0;
                return AppCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key.replaceAll('_', ' ').toUpperCase(),
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
