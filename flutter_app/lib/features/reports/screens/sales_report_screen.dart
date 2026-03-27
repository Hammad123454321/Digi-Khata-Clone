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

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({
    super.key,
    required this.startDate,
    required this.endDate,
  });

  final DateTime startDate;
  final DateTime endDate;

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'daily'; // daily, weekly, monthly
  Map<String, dynamic>? _currentReport;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadReport();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadReport() {
    context.read<ReportsBloc>().add(
          LoadSalesReportEvent(
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
      title: loc.salesReport,
      report: report,
      startDate: widget.startDate,
      endDate: widget.endDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final dateFormatter = DateFormat.yMMMd(loc.locale.languageCode);

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          loc.salesReport,
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          onTap: (index) {
            setState(() {
              _selectedPeriod = ['daily', 'weekly', 'monthly'][index];
            });
          },
          tabs: [
            Tab(text: loc.daily),
            Tab(text: loc.weekly),
            Tab(text: loc.monthly),
          ],
        ),
      ),
      body: BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          return LoadingOverlay(
            isLoading: state is ReportsLoading,
            child: _buildReportContent(state, dateFormatter, theme, loc),
          );
        },
      ),
    );
  }

  Widget _buildReportContent(
    ReportsState state,
    DateFormat dateFormatter,
    ThemeData theme,
    AppLocalizations loc,
  ) {
    if (state is ReportsError) {
      return AppErrorWidget(
        message: state.message,
        onRetry: _loadReport,
      );
    }

    if (state is SalesReportLoaded) {
      final report = state.report;
      _currentReport = report;
      final isOffline = report['is_offline'] == true;
      final totalSales = double.tryParse(
            report['total_sales']?.toString() ?? '0',
          ) ??
          0;
      final cashSales = double.tryParse(
            report['cash_sales']?.toString() ?? '0',
          ) ??
          0;
      final creditSales = double.tryParse(
            report['credit_sales']?.toString() ?? '0',
          ) ??
          0;
      final totalInvoices = report['total_invoices'] ?? 0;
      final averageOrderValue =
          totalInvoices > 0 ? totalSales / totalInvoices : 0;

      // Get period data
      final periodData = _getPeriodData(report, _selectedPeriod, loc);

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
                          loc.totalSales,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          CurrencyUtils.formatCurrency(totalSales),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
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
                          loc.invoices,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          totalInvoices.toString(),
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
                            Icon(Icons.money, size: 16, color: Colors.green),
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
                          CurrencyUtils.formatCurrency(cashSales),
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
                            Icon(Icons.credit_card,
                                size: 16, color: Colors.blue),
                            const SizedBox(width: 4),
                            Text(
                              loc.credit,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyUtils.formatCurrency(creditSales),
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
            const SizedBox(height: 12),
            AppCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loc.averageOrderValue,
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    CurrencyUtils.formatCurrency(averageOrderValue),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Period Breakdown
            Text(
              loc.periodBreakdown.replaceAll(
                '{period}',
                _selectedPeriod == 'daily'
                    ? loc.daily
                    : _selectedPeriod == 'weekly'
                        ? loc.weekly
                        : loc.monthly,
              ),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...periodData.map((data) => AppCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            data['period'],
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            CurrencyUtils.formatCurrency(data['amount']),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${loc.cashLabel}: ${CurrencyUtils.formatCurrency(data['cash'] ?? 0)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.green,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${loc.creditLabel}: ${CurrencyUtils.formatCurrency(data['credit'] ?? 0)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (data['count'] != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          loc.invoiceCount
                              .replaceAll('{count}', '${data['count']}'),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                )),
          ],
        ),
      );
    }

    return const Center(child: CircularProgressIndicator());
  }

  List<Map<String, dynamic>> _getPeriodData(
    Map<String, dynamic> report,
    String period,
    AppLocalizations loc,
  ) {
    // This would parse the report data based on period
    // For now, return sample structure
    final List<Map<String, dynamic>> data = [];

    if (period == 'daily') {
      // Parse daily breakdown
      final dailyData = report['daily_breakdown'] as List<dynamic>? ?? [];
      for (var day in dailyData) {
        data.add({
          'period': DateFormat.yMMMd(loc.locale.languageCode).format(
            DateTime.parse(day['date'] as String),
          ),
          'amount': double.tryParse(day['total']?.toString() ?? '0') ?? 0,
          'cash': double.tryParse(day['cash']?.toString() ?? '0') ?? 0,
          'credit': double.tryParse(day['credit']?.toString() ?? '0') ?? 0,
          'count': day['count'] ?? 0,
        });
      }
    } else if (period == 'weekly') {
      // Parse weekly breakdown
      final weeklyData = report['weekly_breakdown'] as List<dynamic>? ?? [];
      for (var week in weeklyData) {
        data.add({
          'period':
              '${loc.weekOf} ${DateFormat.MMMd(loc.locale.languageCode).format(DateTime.parse(week['week_start'] as String))}',
          'amount': double.tryParse(week['total']?.toString() ?? '0') ?? 0,
          'cash': double.tryParse(week['cash']?.toString() ?? '0') ?? 0,
          'credit': double.tryParse(week['credit']?.toString() ?? '0') ?? 0,
          'count': week['count'] ?? 0,
        });
      }
    } else {
      // Parse monthly breakdown
      final monthlyData = report['monthly_breakdown'] as List<dynamic>? ?? [];
      for (var month in monthlyData) {
        data.add({
          'period': DateFormat.yMMM(loc.locale.languageCode).format(
            DateTime.parse(month['month'] as String),
          ),
          'amount': double.tryParse(month['total']?.toString() ?? '0') ?? 0,
          'cash': double.tryParse(month['cash']?.toString() ?? '0') ?? 0,
          'credit': double.tryParse(month['credit']?.toString() ?? '0') ?? 0,
          'count': month['count'] ?? 0,
        });
      }
    }

    return data;
  }
}
