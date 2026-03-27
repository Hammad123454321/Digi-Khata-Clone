import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/di/injection.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/result.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../data/repositories/reminder_repository.dart';
import '../../../data/repositories/supplier_repository.dart';
import '../../../shared/models/supplier_model.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/modern_components.dart';
import '../bloc/supplier_bloc.dart';
import '../bloc/supplier_event.dart';
import 'create_supplier_purchase_screen.dart';

class SupplierLedgerScreen extends StatefulWidget {
  const SupplierLedgerScreen({
    super.key,
    required this.supplier,
  });

  final SupplierModel supplier;

  @override
  State<SupplierLedgerScreen> createState() => _SupplierLedgerScreenState();
}

class _SupplierLedgerScreenState extends State<SupplierLedgerScreen> {
  List<Map<String, dynamic>> _transactions = [];
  List<_LedgerEntry> _entries = [];
  List<_LedgerEntry> _filteredEntries = [];
  bool _isLoading = true;
  String? _loadingMessage;
  String? _error;
  DateTimeRange? _dateRange;
  _DateFilterType _selectedDateFilter = _DateFilterType.all;
  double _currentBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _loadingMessage = null;
      _error = null;
    });

    final repo = getIt<SupplierRepository>();
    final result = await repo.getTransactions(widget.supplier.id);

    if (mounted) {
      final loc = AppLocalizations.of(context)!;
      setState(() {
        _isLoading = false;
        if (result.isSuccess) {
          _transactions = result.dataOrNull ?? [];
          final computedBalance = _calculateCurrentBalance(_transactions);
          final backendBalance = _parseBalanceOrNull(widget.supplier.balance);
          _currentBalance = _resolveBalance(
            backendBalance: backendBalance,
            computedBalance: computedBalance,
            hasTransactions: _transactions.isNotEmpty,
          );
          _entries = _buildEntries(_transactions, _currentBalance);
          _filteredEntries = _filterEntries(_entries);
        } else {
          _error =
              result.failureOrNull?.message ?? loc.failedToLoadTransactions;
        }
      });
    }
  }

  List<_LedgerEntry> _buildEntries(
    List<Map<String, dynamic>> transactions,
    double currentBalance,
  ) {
    final sorted = List<Map<String, dynamic>>.from(transactions);
    sorted.sort((a, b) {
      final aDate = DateTime.tryParse(a['date']?.toString() ?? '');
      final bDate = DateTime.tryParse(b['date']?.toString() ?? '');
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });

    double runningBalance = currentBalance;
    final entries = <_LedgerEntry>[];
    for (final transaction in sorted) {
      final isPurchase = transaction['transaction_type'] == 'purchase';
      final amount = double.tryParse(
            transaction['amount']?.toString() ?? '0',
          ) ??
          0;
      final date = DateTime.tryParse(transaction['date']?.toString() ?? '');

      entries.add(
        _LedgerEntry(
          transaction: transaction,
          isPurchase: isPurchase,
          amount: amount,
          date: date,
          runningBalance: runningBalance,
        ),
      );

      if (isPurchase) {
        runningBalance -= amount;
      } else {
        runningBalance += amount;
      }
    }

    return entries;
  }

  double _calculateCurrentBalance(List<Map<String, dynamic>> transactions) {
    double balance = 0.0;
    for (final transaction in transactions) {
      final amount =
          double.tryParse(transaction['amount']?.toString() ?? '') ?? 0.0;
      final type = transaction['transaction_type']?.toString();
      if (type == 'purchase') {
        balance += amount;
      } else if (type == 'payment') {
        balance -= amount;
      }
    }
    return balance;
  }

  double _resolveBalance({
    required double? backendBalance,
    required double computedBalance,
    required bool hasTransactions,
  }) {
    if (backendBalance == null) {
      return computedBalance;
    }
    if (backendBalance == 0 && hasTransactions && computedBalance != 0) {
      return computedBalance;
    }
    return backendBalance;
  }

  List<_LedgerEntry> _filterEntries(List<_LedgerEntry> entries) {
    final dateRange = _dateRange;
    if (dateRange == null) return entries;
    return entries.where((entry) {
      if (entry.date == null) return false;
      final date = entry.date!;
      return !(date.isBefore(dateRange.start) || date.isAfter(dateRange.end));
    }).toList();
  }

  void _applyFilters() {
    setState(() {
      _filteredEntries = _filterEntries(_entries);
    });
  }

  String _buildEntryTitle(_LedgerEntry entry, AppLocalizations loc) {
    final type = entry.transaction['transaction_type']?.toString();
    if (type == 'purchase') {
      return loc.purchase;
    }
    if (type == 'payment') {
      return loc.paymentMade;
    }
    return loc.transaction;
  }

  Future<void> _recordPayment() async {
    final amountController = TextEditingController();
    final remarksController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    final result = await _showPaymentDialog(
      amountController: amountController,
      remarksController: remarksController,
      selectedDate: selectedDate,
      onDateChanged: (date) => selectedDate = date,
    );

    if (result == true && mounted) {
      final repo = getIt<SupplierRepository>();
      final paymentResult = await repo.recordPayment(
        supplierId: widget.supplier.id,
        amount: amountController.text,
        date: selectedDate,
        remarks: remarksController.text.isEmpty ? null : remarksController.text,
      );

      if (paymentResult.isSuccess) {
        final loc = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.paymentRecordedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
        _loadTransactions();
        context.read<SupplierBloc>().add(
              const LoadSuppliersEvent(refresh: true, isActive: true),
            );
      } else {
        final loc = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              paymentResult.failureOrNull?.message ?? loc.failedToRecordPayment,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _recordPurchase() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateSupplierPurchaseScreen(
          supplier: widget.supplier,
        ),
      ),
    );

    if (result == true && mounted) {
      _loadTransactions();
      context.read<SupplierBloc>().add(
            const LoadSuppliersEvent(refresh: true, isActive: true),
          );
    }
  }

  Future<void> _selectDateRange() async {
    final now = DateTime.now();
    DateTimeRange initialRange = _dateRange ??
        DateTimeRange(
          start: now.subtract(const Duration(days: 30)),
          end: now,
        );
    if (initialRange.end.isAfter(now)) {
      initialRange = DateTimeRange(
        start: initialRange.start,
        end: now,
      );
    }
    if (initialRange.start.isAfter(initialRange.end)) {
      initialRange = DateTimeRange(
        start: now.subtract(const Duration(days: 30)),
        end: now,
      );
    }
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: initialRange,
      firstDate: DateTime(2020),
      lastDate: now,
    );

    if (picked != null && mounted) {
      setState(() {
        _dateRange = picked;
        _selectedDateFilter = _DateFilterType.custom;
      });
      _applyFilters();
    }
  }

  void _setDateFilter(_DateFilterType type) {
    if (!mounted) return;
    if (type == _DateFilterType.custom) {
      _selectDateRange();
      return;
    }

    final now = DateTime.now();
    DateTimeRange? range;
    switch (type) {
      case _DateFilterType.all:
        range = null;
        break;
      case _DateFilterType.today:
        final start = DateTime(now.year, now.month, now.day);
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        range = DateTimeRange(start: start, end: end);
        break;
      case _DateFilterType.thisMonth:
        final start = DateTime(now.year, now.month, 1);
        range = DateTimeRange(start: start, end: now);
        break;
      case _DateFilterType.lastTwoMonths:
        final start = DateTime(now.year, now.month - 1, 1);
        range = DateTimeRange(start: start, end: now);
        break;
      case _DateFilterType.thisYear:
        final start = DateTime(now.year, 1, 1);
        range = DateTimeRange(start: start, end: now);
        break;
      case _DateFilterType.custom:
        break;
    }

    setState(() {
      _selectedDateFilter = type;
      _dateRange = range;
    });
    _applyFilters();
  }

  Future<void> _showReminderSheet({required bool sendSmsDefault}) async {
    final loc = AppLocalizations.of(context)!;
    final amountController = TextEditingController(
      text: _currentBalance.abs().toStringAsFixed(0),
    );
    final messageController = TextEditingController();
    DateTime? dueDate;
    bool sendSms = sendSmsDefault;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.reminders,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: loc.amount,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      child: Text(
                        CurrencyUtils.getCurrentCurrency().symbol,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: dueDate ?? now,
                      firstDate: DateTime(2020),
                      lastDate: now.add(const Duration(days: 365 * 5)),
                    );
                    if (picked != null) {
                      setState(() => dueDate = picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: loc.dueDate,
                      prefixIcon: const Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      dueDate == null
                          ? loc.selectDate
                          : DateFormat.yMMMd(loc.locale.languageCode)
                              .format(dueDate!),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: messageController,
                  decoration: InputDecoration(
                    labelText: loc.remarksOptional,
                    prefixIcon: const Icon(Icons.message),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(loc.sendPaymentReminders),
                  value: sendSms,
                  onChanged: (value) => setState(() => sendSms = value),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(loc.cancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(loc.save),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result == true && mounted) {
      await _createReminder(
        amountText: amountController.text,
        dueDate: dueDate,
        message: messageController.text.trim(),
        sendSms: sendSms,
      );
    }
  }

  Future<void> _createReminder({
    required String amountText,
    required DateTime? dueDate,
    required String message,
    required bool sendSms,
  }) async {
    final loc = AppLocalizations.of(context)!;
    final amount = double.tryParse(amountText.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.pleaseEnterValidAmount),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final repository = getIt<ReminderRepository>();
    final result = await repository.createReminder(
      entityType: 'supplier',
      entityId: widget.supplier.id,
      entityName: widget.supplier.name,
      entityPhone: widget.supplier.phone,
      amount: amount,
      dueDate: dueDate,
      message: message.isNotEmpty ? message : null,
      sendSms: sendSms,
    );

    if (!mounted) return;

    switch (result) {
      case Success():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.success),
            backgroundColor: Colors.green,
          ),
        );
      case FailureResult(:final failure):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              loc.failedToResolveReminder.replaceAll(
                '{error}',
                failure.message ?? 'Unknown error',
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
    }
  }

  double _parseBalance(String? value) {
    return _parseBalanceOrNull(value) ?? 0.0;
  }

  double? _parseBalanceOrNull(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return double.tryParse(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final dateFormatter = DateFormat.yMMMd(loc.locale.languageCode);
    final timeFormatter = DateFormat.jm(loc.locale.languageCode);
    final balanceValue = _currentBalance;
    final willGive = balanceValue >= 0;
    final balanceLabel = willGive ? loc.youWillGive : loc.youWillGet;
    final balanceColor = willGive ? AppTheme.successColor : AppTheme.errorColor;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.supplier.name,
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
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: _loadingMessage,
        child: _error != null
            ? AppErrorWidget(
                message: _error!,
                onRetry: _loadTransactions,
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  CurrencyUtils.formatCurrency(
                                    balanceValue.abs(),
                                  ),
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: balanceColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  balanceLabel,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            willGive
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: balanceColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          QuickActionButton(
                            icon: Icons.receipt_long,
                            label: loc.report,
                            onTap: () => Navigator.of(context)
                                .pushNamed(AppRouter.reports),
                          ),
                          const SizedBox(width: 12),
                          QuickActionButton(
                            icon: Icons.calendar_today,
                            label: loc.setDate,
                            onTap: _selectDateRange,
                          ),
                          const SizedBox(width: 12),
                          QuickActionButton(
                            icon: Icons.notifications,
                            label: loc.reminders,
                            onTap: () =>
                                _showReminderSheet(sendSmsDefault: false),
                          ),
                          const SizedBox(width: 12),
                          QuickActionButton(
                            icon: Icons.sms,
                            label: loc.sms,
                            onTap: () =>
                                _showReminderSheet(sendSmsDefault: true),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _DateFilterChip(
                            label: loc.filterAll,
                            selected:
                                _selectedDateFilter == _DateFilterType.all,
                            onTap: () => _setDateFilter(_DateFilterType.all),
                          ),
                          const SizedBox(width: 8),
                          _DateFilterChip(
                            label: loc.filterToday,
                            selected:
                                _selectedDateFilter == _DateFilterType.today,
                            onTap: () => _setDateFilter(_DateFilterType.today),
                          ),
                          const SizedBox(width: 8),
                          _DateFilterChip(
                            label: loc.filterThisMonth,
                            selected: _selectedDateFilter ==
                                _DateFilterType.thisMonth,
                            onTap: () =>
                                _setDateFilter(_DateFilterType.thisMonth),
                          ),
                          const SizedBox(width: 8),
                          _DateFilterChip(
                            label: loc.filterLastTwoMonths,
                            selected: _selectedDateFilter ==
                                _DateFilterType.lastTwoMonths,
                            onTap: () =>
                                _setDateFilter(_DateFilterType.lastTwoMonths),
                          ),
                          const SizedBox(width: 8),
                          _DateFilterChip(
                            label: loc.filterThisYear,
                            selected:
                                _selectedDateFilter == _DateFilterType.thisYear,
                            onTap: () =>
                                _setDateFilter(_DateFilterType.thisYear),
                          ),
                          const SizedBox(width: 8),
                          _DateFilterChip(
                            label: loc.filterCustomRange,
                            selected:
                                _selectedDateFilter == _DateFilterType.custom,
                            icon: Icons.date_range,
                            onTap: () => _setDateFilter(_DateFilterType.custom),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_dateRange != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Chip(
                          label: Text(
                            '${loc.dateRange}: ${dateFormatter.format(_dateRange!.start)} - ${dateFormatter.format(_dateRange!.end)}',
                          ),
                          onDeleted: () {
                            setState(() {
                              _dateRange = null;
                              _selectedDateFilter = _DateFilterType.all;
                            });
                            _applyFilters();
                          },
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
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
                            loc.youGave,
                            textAlign: TextAlign.right,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.errorColor,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            loc.youGot,
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
                    child: _entries.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt_long,
                                  size: 64,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  loc.noTransactionsYet,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _filteredEntries.isEmpty
                            ? Center(
                                child: Text(
                                  loc.noTransactionsFound,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 8, 16, 16),
                                itemCount: _filteredEntries.length,
                                itemBuilder: (context, index) {
                                  final entry = _filteredEntries[index];
                                  final title = _buildEntryTitle(entry, loc);
                                  final dateText = entry.date != null
                                      ? '${dateFormatter.format(entry.date!)} • ${timeFormatter.format(entry.date!)}'
                                      : loc.unknown;
                                  final remarks =
                                      entry.transaction['remarks']?.toString();

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
                                                  style: theme
                                                      .textTheme.titleSmall
                                                      ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  dateText,
                                                  style: theme
                                                      .textTheme.bodySmall
                                                      ?.copyWith(
                                                    color: theme.colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                                ),
                                                if (remarks != null &&
                                                    remarks.isNotEmpty) ...[
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    remarks,
                                                    style: theme
                                                        .textTheme.bodySmall
                                                        ?.copyWith(
                                                      color: theme.colorScheme
                                                          .onSurfaceVariant,
                                                    ),
                                                  ),
                                                ],
                                                const SizedBox(height: 6),
                                                Text(
                                                  '${loc.balance}: ${CurrencyUtils.formatCurrency(entry.runningBalance.abs())}',
                                                  style: theme
                                                      .textTheme.labelSmall
                                                      ?.copyWith(
                                                    color: theme
                                                        .colorScheme.primary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        _AmountCell(
                                          amount: entry.isPurchase
                                              ? ''
                                              : CurrencyUtils.formatCurrency(
                                                  entry.amount,
                                                ),
                                          highlight: !entry.isPurchase,
                                          color: AppTheme.errorColor,
                                        ),
                                        _AmountCell(
                                          amount: entry.isPurchase
                                              ? CurrencyUtils.formatCurrency(
                                                  entry.amount,
                                                )
                                              : '',
                                          highlight: entry.isPurchase,
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
              ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _recordPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    '${loc.youGave} ${CurrencyUtils.getCurrentCurrency().symbol}',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _recordPurchase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    '${loc.youGot} ${CurrencyUtils.getCurrentCurrency().symbol}',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _showPaymentDialog({
    required TextEditingController amountController,
    required TextEditingController remarksController,
    required DateTime selectedDate,
    required ValueChanged<DateTime> onDateChanged,
  }) async {
    DateTime date = selectedDate;
    return showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.recordPayment),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Builder(
                  builder: (context) {
                    final theme = Theme.of(context);
                    final loc = AppLocalizations.of(context)!;
                    return TextField(
                      controller: amountController,
                      decoration: InputDecoration(
                        labelText: loc.amount,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          child: Text(
                            CurrencyUtils.getCurrentCurrency().symbol,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        hintText: loc.enterPaymentAmount,
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    );
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final now = DateTime.now();
                    final today = DateTime(now.year, now.month, now.day);
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: date.isAfter(today) ? today : date,
                      firstDate: DateTime(2020),
                      lastDate: today,
                    );
                    if (picked != null) {
                      setState(() => date = picked);
                      onDateChanged(picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.date,
                      prefixIcon: const Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      DateFormat.yMMMd(
                              AppLocalizations.of(context)!.locale.languageCode)
                          .format(date),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: remarksController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.remarksOptional,
                    prefixIcon: const Icon(Icons.note),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final loc = AppLocalizations.of(context)!;
                final amountText = amountController.text.trim();
                if (amountText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(loc.pleaseEnterPaymentAmount),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
                final amount = double.tryParse(amountText);
                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(loc.pleaseEnterValidAmount),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
                Navigator.of(context).pop(true);
              },
              child: Text(AppLocalizations.of(context)!.record),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountCell extends StatelessWidget {
  const _AmountCell({
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

class _DateFilterChip extends StatelessWidget {
  const _DateFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary.withValues(alpha: 0.12)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _DateFilterType {
  all,
  today,
  thisMonth,
  lastTwoMonths,
  thisYear,
  custom,
}

class _LedgerEntry {
  const _LedgerEntry({
    required this.transaction,
    required this.isPurchase,
    required this.amount,
    required this.date,
    required this.runningBalance,
  });

  final Map<String, dynamic> transaction;
  final bool isPurchase;
  final double amount;
  final DateTime? date;
  final double runningBalance;
}
