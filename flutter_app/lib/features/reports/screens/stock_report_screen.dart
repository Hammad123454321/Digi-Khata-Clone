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

class StockReportScreen extends StatefulWidget {
  const StockReportScreen({super.key});

  @override
  State<StockReportScreen> createState() => _StockReportScreenState();
}

class _StockReportScreenState extends State<StockReportScreen> {
  Map<String, dynamic>? _currentReport;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  void _loadReport() {
    context.read<ReportsBloc>().add(const LoadStockReportEvent());
  }

  Future<void> _shareReport() async {
    final report = _currentReport;
    if (report == null) return;
    final loc = AppLocalizations.of(context)!;
    await ReportExporter.shareReportPdf(
      loc: loc,
      title: loc.stockReport,
      report: report,
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
          loc.stockReport,
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

    if (state is StockReportLoaded) {
      final report = state.report;
      _currentReport = report;
      final isOffline = report['is_offline'] == true;
      final totalItems = report['total_items'] ?? 0;
      final totalValue = double.tryParse(
            report['total_value']?.toString() ?? '0',
          ) ??
          0;
      final outOfStockItems = report['out_of_stock_items'] ?? 0;

      final items = report['items'] as List<dynamic>? ?? [];

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
                          loc.totalItems,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          totalItems.toString(),
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
                          loc.totalValue,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          CurrencyUtils.formatCurrency(totalValue),
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
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.error, size: 16, color: Colors.red),
                      const SizedBox(width: 4),
                      Text(
                        loc.outOfStock,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    outOfStockItems.toString(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            if (items.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                loc.allItems,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...items.map((item) {
                final currentStock = item['current_stock'] ?? 0;
                final unit = item['unit'] ?? '';
                final value = double.tryParse(
                      item['value']?.toString() ?? '0',
                    ) ??
                    0;
                final name = item['name'] ?? loc.unknown;

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
                              name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${loc.stockLabel}: $currentStock $unit',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        CurrencyUtils.formatCurrency(value),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
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
