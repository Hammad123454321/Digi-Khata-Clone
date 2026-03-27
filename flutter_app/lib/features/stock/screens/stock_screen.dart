import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/di/injection.dart';
import '../../../core/routes/app_router.dart';
import '../../../data/repositories/reports_repository.dart';
import '../../../shared/models/stock_alert_model.dart';
import '../../../shared/models/stock_item_model.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/modern_components.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../reports/bloc/reports_bloc.dart';
import '../../reports/screens/stock_report_screen.dart';
import '../bloc/stock_bloc.dart';
import '../bloc/stock_event.dart';
import '../bloc/stock_state.dart';
import 'stock_transaction_screen.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  List<StockItemModel> _cachedItems = [];
  List<StockAlertModel> _cachedAlerts = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applyFilters);

    context.read<StockBloc>().add(const LoadStockItemsEvent());
    context.read<StockBloc>().add(const LoadStockAlertsEvent());
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

  List<StockItemModel> _filterItems(List<StockItemModel> items) {
    final query = _searchController.text.trim().toLowerCase();

    return items.where((item) {
      if (query.isEmpty) return true;

      final name = item.name.toLowerCase();
      return name.contains(query);
    }).toList();
  }

  Future<void> _openAddItem() async {
    final result =
        await Navigator.of(context).pushNamed(AppRouter.addStockItem);
    if (result == true && mounted) {
      context.read<StockBloc>().add(const LoadStockItemsEvent(refresh: true));
    }
  }

  Future<void> _openStockReport() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => ReportsBloc(
            reportsRepository: getIt<ReportsRepository>(),
          ),
          child: const StockReportScreen(),
        ),
      ),
    );
  }

  Future<void> _openStockAlertsSheet() async {
    if (_cachedAlerts.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No active stock alerts'),
        ),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stock Alerts',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 380,
                  child: ListView.builder(
                    itemCount: _cachedAlerts.length,
                    itemBuilder: (context, index) {
                      final alert = _cachedAlerts[index];
                      final currentStock =
                          double.tryParse(alert.currentStock) ?? 0;
                      final isOutOfStock = currentStock <= 0;
                      return AppCard(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    alert.itemName,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isOutOfStock
                                        ? theme.colorScheme.error
                                            .withValues(alpha: 0.14)
                                        : theme.colorScheme.tertiary
                                            .withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    isOutOfStock ? 'Out of stock' : 'Low stock',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: isOutOfStock
                                          ? theme.colorScheme.error
                                          : theme.colorScheme.tertiary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Current: ${alert.currentStock}  |  Threshold: ${alert.threshold}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () {
                                  Navigator.of(sheetContext).pop();
                                  context.read<StockBloc>().add(
                                        ResolveStockAlertEvent(alert.id),
                                      );
                                },
                                icon: const Icon(Icons.check_circle_outline),
                                label: const Text('Mark resolved'),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
              loc.stockManagement,
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
      body: BlocConsumer<StockBloc, StockState>(
        listener: (context, state) {
          if (state is StockAlertResolved) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Stock alert resolved'),
                backgroundColor: AppTheme.successColor,
              ),
            );
            context.read<StockBloc>().add(const LoadStockAlertsEvent());
            return;
          }
          if (state is StockError && _cachedItems.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is StockLoading && _cachedItems.isEmpty;
          if (state is StockItemsLoaded) {
            _cachedItems = state.items;
            _cachedAlerts = state.alerts ?? _cachedAlerts;
          }

          if (state is StockError && _cachedItems.isEmpty) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () =>
                  context.read<StockBloc>().add(const LoadStockItemsEvent()),
            );
          }

          return LoadingOverlay(
            isLoading: isLoading,
            child: _buildStockContent(theme),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ElevatedButton(
            onPressed: _openAddItem,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: Text(loc.addStockItem),
          ),
        ),
      ),
    );
  }

  Widget _buildStockContent(ThemeData theme) {
    final loc = AppLocalizations.of(context)!;

    final filteredItems = _filterItems(_cachedItems);
    final totalItems = filteredItems.length;
    final activeAlerts =
        _cachedAlerts.where((alert) => !alert.isResolved).toList();
    final totalValue = filteredItems.fold<double>(
      0,
      (sum, item) =>
          sum +
          ((double.tryParse(item.currentStock) ?? 0) *
              (double.tryParse(item.salePrice) ?? 0)),
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
                  CurrencyUtils.formatCurrency(totalValue),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  loc.totalValue,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StockMiniStat(
                        label: loc.totalItems,
                        value: totalItems.toString(),
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StockMiniStat(
                        label: 'Alerts',
                        value: activeAlerts.length.toString(),
                        color: activeAlerts.isEmpty
                            ? AppTheme.successColor
                            : theme.colorScheme.tertiary,
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
                  onTap: _openStockReport,
                ),
                const SizedBox(width: 12),
                QuickActionButton(
                  icon: Icons.warning_amber_rounded,
                  label: 'Alerts',
                  onTap: _openStockAlertsSheet,
                ),
                const SizedBox(width: 12),
                QuickActionButton(
                  icon: Icons.add_box_outlined,
                  label: loc.addStockItem,
                  onTap: _openAddItem,
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
                flex: 3,
                child: Text(
                  loc.items,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  loc.stockLabel,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  loc.totalValue,
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
          child: _cachedItems.isEmpty
              ? Center(
                  child: EmptyState(
                    icon: Icons.inventory,
                    title: loc.noStockItems,
                    message: loc.startByAddingStockItem,
                  ),
                )
              : filteredItems.isEmpty
                  ? Center(
                      child: Text(
                        loc.noResultsFound,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        final currentStock =
                            double.tryParse(item.currentStock) ?? 0;
                        final isOutOfStock = currentStock <= 0;
                        StockAlertModel? itemAlert;
                        for (final alert in activeAlerts) {
                          if (alert.itemId == item.id) {
                            itemAlert = alert;
                            break;
                          }
                        }
                        final isLowStock = itemAlert != null && !isOutOfStock;
                        final stockValue = currentStock *
                            (double.tryParse(item.salePrice) ?? 0);

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
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.name,
                                              style: theme.textTheme.titleSmall
                                                  ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          if (isOutOfStock)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: theme.colorScheme.error
                                                    .withValues(alpha: 0.12),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                loc.outOfStock,
                                                style: theme
                                                    .textTheme.labelSmall
                                                    ?.copyWith(
                                                  color:
                                                      theme.colorScheme.error,
                                                ),
                                              ),
                                            ),
                                          if (isLowStock)
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  left: 6),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: theme
                                                    .colorScheme.tertiary
                                                    .withValues(alpha: 0.12),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                'Low stock',
                                                style: theme
                                                    .textTheme.labelSmall
                                                    ?.copyWith(
                                                  color: theme
                                                      .colorScheme.tertiary,
                                                ),
                                              ),
                                            ),
                                          PopupMenuButton<String>(
                                            onSelected: (value) async {
                                              if (value == 'stock_in' ||
                                                  value == 'stock_out') {
                                                final stockBloc =
                                                    context.read<StockBloc>();
                                                final result =
                                                    await Navigator.of(context)
                                                        .push(
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        BlocProvider.value(
                                                      value: stockBloc,
                                                      child:
                                                          StockTransactionScreen(
                                                        item: item,
                                                        transactionType:
                                                            value == 'stock_in'
                                                                ? 'in'
                                                                : 'out',
                                                      ),
                                                    ),
                                                  ),
                                                );
                                                if (result == true && mounted) {
                                                  stockBloc.add(
                                                    const LoadStockItemsEvent(
                                                      refresh: true,
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              PopupMenuItem(
                                                value: 'stock_in',
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.add,
                                                        size: 20),
                                                    const SizedBox(width: 8),
                                                    Text(loc.stockIn),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuItem(
                                                value: 'stock_out',
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.remove,
                                                        size: 20),
                                                    const SizedBox(width: 8),
                                                    Text(loc.stockOut),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${loc.salePrice}: ${CurrencyUtils.formatCurrency(double.tryParse(item.salePrice) ?? 0)}',
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              _StockAmountCell(
                                amount: '${item.currentStock} ${item.unit}',
                                highlight: isOutOfStock || isLowStock,
                                color: isOutOfStock
                                    ? theme.colorScheme.error
                                    : isLowStock
                                        ? theme.colorScheme.tertiary
                                        : theme.colorScheme.primary,
                              ),
                              _StockAmountCell(
                                amount:
                                    CurrencyUtils.formatCurrency(stockValue),
                                highlight: false,
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

class _StockMiniStat extends StatelessWidget {
  const _StockMiniStat({
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

class _StockAmountCell extends StatelessWidget {
  const _StockAmountCell({
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
