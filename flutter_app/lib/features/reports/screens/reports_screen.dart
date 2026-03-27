import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/modern_components.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../bloc/reports_bloc.dart';
import 'sales_report_screen.dart';
import 'cash_flow_report_screen.dart';
import 'expense_report_screen.dart';
import 'stock_report_screen.dart';
import 'profit_loss_report_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilters);
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _applyFilters() {
    setState(() {});
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  List<_ReportItem> _buildReportItems(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final reportsBloc = context.read<ReportsBloc>();
    return [
      _ReportItem(
        icon: Icons.shopping_cart,
        title: loc.salesReport,
        color: Colors.blue,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: reportsBloc,
                child: SalesReportScreen(
                  startDate: _startDate,
                  endDate: _endDate,
                ),
              ),
            ),
          );
        },
      ),
      _ReportItem(
        icon: Icons.account_balance_wallet,
        title: loc.cashFlowReport,
        color: Colors.green,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: reportsBloc,
                child: CashFlowReportScreen(
                  startDate: _startDate,
                  endDate: _endDate,
                ),
              ),
            ),
          );
        },
      ),
      _ReportItem(
        icon: Icons.receipt_long,
        title: loc.expenseReport,
        color: Colors.orange,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: reportsBloc,
                child: ExpenseReportScreen(
                  startDate: _startDate,
                  endDate: _endDate,
                ),
              ),
            ),
          );
        },
      ),
      _ReportItem(
        icon: Icons.inventory,
        title: loc.stockReport,
        color: Colors.purple,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: reportsBloc,
                child: const StockReportScreen(),
              ),
            ),
          );
        },
      ),
      _ReportItem(
        icon: Icons.trending_up,
        title: loc.profitLossReport,
        color: Colors.indigo,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: reportsBloc,
                child: ProfitLossReportScreen(
                  startDate: _startDate,
                  endDate: _endDate,
                ),
              ),
            ),
          );
        },
      ),
    ];
  }

  List<_ReportItem> _filterReports(List<_ReportItem> items) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return items;

    return items
        .where((item) => item.title.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final dateFormatter = DateFormat.yMMMd(loc.locale.languageCode);
    final reportItems = _filterReports(_buildReportItems(context));

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.reports,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${dateFormatter.format(_startDate)} - ${dateFormatter.format(_endDate)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white70,
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.dateRange,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${dateFormatter.format(_startDate)} - ${dateFormatter.format(_endDate)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _ReportMiniStat(
                          label: loc.reports,
                          value: reportItems.length.toString(),
                          color: theme.colorScheme.primary,
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
                    icon: Icons.calendar_today,
                    label: loc.setDate,
                    onTap: _selectDateRange,
                  ),
                  const SizedBox(width: 12),
                  QuickActionButton(
                    icon: Icons.refresh,
                    label: loc.refresh,
                    onTap: () => setState(() {}),
                  ),
                ],
              ),
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
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    loc.entries,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: reportItems.length,
              itemBuilder: (context, index) {
                final report = reportItems[index];
                return AppCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  onTap: report.onTap,
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: report.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(report.icon, color: report.color),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          report.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportItem {
  _ReportItem({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
}

class _ReportMiniStat extends StatelessWidget {
  const _ReportMiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
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
            value,
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
