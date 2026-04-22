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

enum _StockPeriod {
  today,
  thisWeek,
  thisMonth,
  last3Months,
  custom,
}

class StockReportScreen extends StatefulWidget {
  const StockReportScreen({
    super.key,
    required this.startDate,
    required this.endDate,
  });

  final DateTime startDate;
  final DateTime endDate;

  @override
  State<StockReportScreen> createState() => _StockReportScreenState();
}

class _StockReportScreenState extends State<StockReportScreen> {
  Map<String, dynamic>? _currentReport;
  late DateTime _startDate;
  late DateTime _endDate;
  _StockPeriod _selectedPeriod = _StockPeriod.custom;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _startDate = DateTime(
      widget.startDate.year,
      widget.startDate.month,
      widget.startDate.day,
    );
    _endDate = DateTime(
      widget.endDate.year,
      widget.endDate.month,
      widget.endDate.day,
      23,
      59,
      59,
      999,
    );
    _loadReport();
  }

  void _loadReport() {
    context.read<ReportsBloc>().add(
          LoadStockReportEvent(
            startDate: _startDate,
            endDate: _endDate,
          ),
        );
  }

  DateTime _monthStartMinus(DateTime date, int monthsBack) {
    final absoluteMonth = date.year * 12 + date.month - 1 - monthsBack;
    final year = absoluteMonth ~/ 12;
    final month = absoluteMonth % 12 + 1;
    return DateTime(year, month, 1);
  }

  Future<void> _applyPeriod(_StockPeriod period) async {
    if (period == _StockPeriod.custom) {
      await _pickCustomRange();
      return;
    }

    final now = DateTime.now();
    DateTime start;
    DateTime end;

    switch (period) {
      case _StockPeriod.today:
        start = DateTime(now.year, now.month, now.day);
        end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        break;
      case _StockPeriod.thisWeek:
        final monday = now.subtract(Duration(days: now.weekday - 1));
        start = DateTime(monday.year, monday.month, monday.day);
        end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        break;
      case _StockPeriod.thisMonth:
        start = DateTime(now.year, now.month, 1);
        end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        break;
      case _StockPeriod.last3Months:
        start = _monthStartMinus(now, 2);
        end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        break;
      case _StockPeriod.custom:
        return;
    }

    setState(() {
      _selectedPeriod = period;
      _startDate = start;
      _endDate = end;
    });
    _loadReport();
  }

  Future<void> _pickCustomRange() async {
    final loc = AppLocalizations.of(context)!;
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _startDate,
        end: DateTime(_endDate.year, _endDate.month, _endDate.day),
      ),
      helpText: loc.dateRange,
    );

    if (picked == null) return;

    setState(() {
      _selectedPeriod = _StockPeriod.custom;
      _startDate = DateTime(
        picked.start.year,
        picked.start.month,
        picked.start.day,
      );
      _endDate = DateTime(
        picked.end.year,
        picked.end.month,
        picked.end.day,
        23,
        59,
        59,
        999,
      );
    });
    _loadReport();
  }

  String _periodLabel(_StockPeriod period, AppLocalizations loc) {
    switch (period) {
      case _StockPeriod.today:
        return loc.filterToday;
      case _StockPeriod.thisWeek:
        return 'This Week';
      case _StockPeriod.thisMonth:
        return loc.filterThisMonth;
      case _StockPeriod.last3Months:
        return 'Last 3 months';
      case _StockPeriod.custom:
        return loc.dateRange;
    }
  }

  Future<void> _shareReport() async {
    final report = _currentReport;
    if (report == null || _isSharing) return;
    final loc = AppLocalizations.of(context)!;
    setState(() => _isSharing = true);
    final result = await ReportExporter.shareReportPdf(
      loc: loc,
      title: loc.stockReport,
      report: report,
      startDate: _startDate,
      endDate: _endDate,
    );
    if (!mounted) return;
    setState(() => _isSharing = false);

    final messenger = ScaffoldMessenger.of(context);
    if (result.success) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            result.usedFallback
                ? 'Report shared successfully.'
                : 'Report ready to share.',
          ),
          backgroundColor: AppTheme.successColor,
        ),
      );
      return;
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(result.message ?? 'Failed to share report.'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.stockReport,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '${dateFormatter.format(_startDate)} - ${dateFormatter.format(_endDate)}',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
          ],
        ),
        titleSpacing: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Share',
            onPressed:
                (_currentReport == null || _isSharing) ? null : _shareReport,
            icon: _isSharing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.share, color: Colors.white),
          ),
        ],
      ),
      body: BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          return LoadingOverlay(
            isLoading: state is ReportsLoading,
            child: Column(
              children: [
                _buildPeriodSelector(theme),
                Expanded(
                  child: _buildReportContent(state, theme),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    return double.tryParse(value.toString()) ?? 0;
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  Map<String, dynamic> _summaryMap(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return const {};
  }

  List<Map<String, dynamic>> _asMapList(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((entry) => Map<String, dynamic>.from(entry))
        .toList();
  }

  Widget _buildPeriodSelector(ThemeData theme) {
    final loc = AppLocalizations.of(context)!;
    final dateFormatter = DateFormat('dd MMM yyyy', loc.locale.languageCode);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _StockPeriod.values.map((period) {
                final isSelected = _selectedPeriod == period;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(_periodLabel(period, loc)),
                    selected: isSelected,
                    onSelected: (_) => _applyPeriod(period),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${dateFormatter.format(_startDate)} - ${dateFormatter.format(_endDate)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required ThemeData theme,
    required String label,
    required String value,
    Color? valueColor,
    IconData? icon,
  }) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor ?? theme.colorScheme.onSurface,
            ),
          ),
        ],
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

    if (state is! StockReportLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    final report = state.report;
    _currentReport = report;

    final isOffline = report['is_offline'] == true;
    final periodSummary = _summaryMap(report['period_summary']);
    final profitLossSummary = _summaryMap(report['profit_loss_summary']);

    final invoiceRows = _asMapList(report['invoice_reference_rows']);

    final stockGoneQty =
        _toDouble(periodSummary['sold_qty'] ?? report['total_sold_qty']);
    final stockLeftQty = _toDouble(periodSummary['left_qty']);
    final stockLeftValue = _toDouble(
      periodSummary['left_value'] ??
          report['total_stock_value'] ??
          report['total_value'],
    );
    final salesValue = _toDouble(
      periodSummary['sold_value'] ??
          profitLossSummary['sales_revenue'] ??
          report['total_sold_value'],
    );
    final grossProfit = _toDouble(
      profitLossSummary['gross_profit'] ?? report['total_estimated_margin'],
    );
    final daysInRange =
        _toInt(periodSummary['days_in_range'] ?? report['days_in_range']);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isOffline) ...[
            const OfflineBanner(),
            const SizedBox(height: 12),
          ],
          Text(
            'Summary',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  theme: theme,
                  label: 'Stock Gone',
                  value: stockGoneQty.toStringAsFixed(2),
                  icon: Icons.trending_down,
                  valueColor: Colors.deepOrange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  theme: theme,
                  label: 'Stock Left',
                  value: stockLeftQty.toStringAsFixed(2),
                  icon: Icons.inventory,
                  valueColor: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  theme: theme,
                  label: 'Sales',
                  value: CurrencyUtils.formatCurrency(salesValue),
                  icon: Icons.payments_outlined,
                  valueColor: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  theme: theme,
                  label: 'Gross Profit',
                  value: CurrencyUtils.formatCurrency(grossProfit),
                  icon: Icons.savings_outlined,
                  valueColor: grossProfit >= 0 ? Colors.teal : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Period: ${_periodLabel(_selectedPeriod, loc)} ($daysInRange days)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Stock Left Value: ${CurrencyUtils.formatCurrency(stockLeftValue)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Stock Gone (Invoices)',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (invoiceRows.isEmpty)
            AppCard(
              child: Text(
                'No invoice sales in selected range.',
                style: theme.textTheme.bodyMedium,
              ),
            )
          else
            ...invoiceRows.map((invoiceRow) {
              final invoiceNumber =
                  invoiceRow['invoice_number']?.toString() ?? 'Invoice';
              final customerName =
                  invoiceRow['customer_name']?.toString() ?? 'Unknown Customer';
              final soldQty = _toDouble(invoiceRow['sold_qty']);
              final soldAmount = _toDouble(invoiceRow['sold_amount']);
              final status =
                  invoiceRow['status']?.toString().replaceAll('_', ' ') ?? '-';
              final invoiceDate = invoiceRow['invoice_date']?.toString() ?? '';
              return AppCard(
                margin: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            invoiceNumber,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          CurrencyUtils.formatCurrency(soldAmount),
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      customerName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Qty: ${soldQty.toStringAsFixed(2)}  •  ${status.toUpperCase()}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (invoiceDate.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        invoiceDate,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
          const SizedBox(height: 16),
          Text(
            'Remaining Stock Snapshot',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          AppCard(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Left Qty: ${stockLeftQty.toStringAsFixed(2)}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                Text(
                  CurrencyUtils.formatCurrency(stockLeftValue),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
