import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../../../core/di/injection.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/result.dart';
import '../../../data/repositories/customer_repository.dart';
import '../../../data/repositories/invoice_repository.dart';
import '../../../data/repositories/reminder_repository.dart';
import '../../../shared/models/customer_model.dart';
import '../../../shared/models/invoice_model.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/invoice_pdf_builder.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/confirmation_dialog.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/modern_components.dart';
import '../../invoices/bloc/invoice_bloc.dart';
import '../../invoices/screens/create_invoice_screen.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';

class CustomerLedgerScreen extends StatefulWidget {
  const CustomerLedgerScreen({
    super.key,
    required this.customer,
  });

  final CustomerModel customer;

  @override
  State<CustomerLedgerScreen> createState() => _CustomerLedgerScreenState();
}

class _CustomerLedgerScreenState extends State<CustomerLedgerScreen> {
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

    final repo = getIt<CustomerRepository>();
    final result = await repo.getTransactions(widget.customer.id);

    if (mounted) {
      final loc = AppLocalizations.of(context)!;
      setState(() {
        _isLoading = false;
        if (result.isSuccess) {
          _transactions = result.dataOrNull ?? [];
          final computedBalance = _calculateCurrentBalance(_transactions);
          final backendBalance = _parseBalanceOrNull(widget.customer.balance);
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
      final isCredit = transaction['transaction_type'] == 'credit';
      final amount = double.tryParse(
            transaction['amount']?.toString() ?? '0',
          ) ??
          0;
      final date = DateTime.tryParse(transaction['date']?.toString() ?? '');

      entries.add(
        _LedgerEntry(
          transaction: transaction,
          isCredit: isCredit,
          amount: amount,
          date: date,
          runningBalance: runningBalance,
        ),
      );

      // Move backward in time from current balance.
      if (isCredit) {
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
      if (type == 'credit') {
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
    final invoiceId = _invoiceIdForEntry(entry);
    if (invoiceId != null) {
      final invoiceNumber = entry.transaction['invoice_number']?.toString();
      if (invoiceNumber != null && invoiceNumber.trim().isNotEmpty) {
        return invoiceNumber.trim();
      }
      return '${loc.invoice} ${invoiceId.substring(0, invoiceId.length < 6 ? invoiceId.length : 6).toUpperCase()}';
    }
    final type = entry.transaction['transaction_type']?.toString();
    if (type == 'credit') {
      return loc.creditInvoice;
    }
    if (type == 'payment') {
      return loc.paymentReceived;
    }
    return loc.transaction;
  }

  String? _invoiceIdForEntry(_LedgerEntry entry) {
    final type = entry.transaction['transaction_type']?.toString();
    if (type != 'credit') return null;
    final refType = entry.transaction['reference_type']?.toString();
    if (refType != 'invoice') return null;
    final refId = entry.transaction['reference_id']?.toString();
    if (refId == null || refId.trim().isEmpty) return null;
    return refId.trim();
  }

  bool _isPaymentEntry(_LedgerEntry entry) {
    return entry.transaction['transaction_type']?.toString() == 'payment';
  }

  Future<void> _openEntry(_LedgerEntry entry) async {
    final invoiceId = _invoiceIdForEntry(entry);
    if (invoiceId != null) {
      final updated = await _openEntryDetailScreen(entry, invoiceId);
      if (updated == true && mounted) {
        await _loadTransactions();
        if (mounted) {
          context
              .read<CustomerBloc>()
              .add(const LoadCustomersEvent(refresh: true, isActive: true));
        }
      }
      return;
    }
    if (_isPaymentEntry(entry)) {
      final updated = await _openPaymentEntryDetailScreen(entry);
      if (updated == true && mounted) {
        await _loadTransactions();
        if (mounted) {
          context
              .read<CustomerBloc>()
              .add(const LoadCustomersEvent(refresh: true, isActive: true));
        }
      }
    }
  }

  Future<bool?> _openEntryDetailScreen(
      _LedgerEntry entry, String invoiceId) async {
    final loc = AppLocalizations.of(context)!;
    final repository = getIt<InvoiceRepository>();
    final result = await repository.getInvoiceById(invoiceId);
    if (!mounted) return null;
    if (!result.isSuccess || result.dataOrNull == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.failureOrNull?.message ?? loc.failedToLoadData),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => _CustomerEntryDetailScreen(
          customer: widget.customer,
          entry: entry,
          invoice: result.dataOrNull!,
          currentBalance: _currentBalance,
        ),
      ),
    );
  }

  Future<bool?> _openPaymentEntryDetailScreen(_LedgerEntry entry) async {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => _CustomerPaymentEntryDetailScreen(
          customer: widget.customer,
          entry: entry,
          currentBalance: _currentBalance,
        ),
      ),
    );
  }

  Future<void> _recordPayment() async {
    final amountController = TextEditingController();
    final remarksController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String? selectedInvoiceId;

    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (context) => _PaymentDialog(
        customerId: widget.customer.id,
        amountController: amountController,
        remarksController: remarksController,
        selectedDate: selectedDate,
        selectedInvoiceId: selectedInvoiceId,
        onDateChanged: (date) => selectedDate = date,
        onInvoiceChanged: (invoiceId) => selectedInvoiceId = invoiceId,
      ),
    );

    if (result != null && mounted) {
      final repo = getIt<CustomerRepository>();
      final paymentResult = await repo.recordPayment(
        customerId: widget.customer.id,
        amount: amountController.text,
        date: selectedDate,
        invoiceId: result['invoice_id']?.toString(),
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
        context.read<CustomerBloc>().add(
              const LoadCustomersEvent(refresh: true, isActive: true),
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

  Future<void> _recordCredit() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => InvoiceBloc(
            invoiceRepository: getIt<InvoiceRepository>(),
          ),
          child: CreateInvoiceScreen(
            initialCustomer: widget.customer,
            defaultInvoiceType: 'credit',
          ),
        ),
      ),
    );

    if (created == true && mounted) {
      _loadTransactions();
      context.read<CustomerBloc>().add(
            const LoadCustomersEvent(refresh: true, isActive: true),
          );
    }
  }

  void _openCustomerReport() {
    if (_entries.isEmpty) {
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.noTransactionsYet),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _CustomerReportScreen(
          customer: widget.customer,
          entries: _filteredEntries,
          dateRange: _dateRange,
          currentBalance: _currentBalance,
        ),
      ),
    );
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
      entityType: 'customer',
      entityId: widget.customer.id,
      entityName: widget.customer.name,
      entityPhone: widget.customer.phone,
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

  Future<void> _confirmDeleteCustomer() async {
    final loc = AppLocalizations.of(context)!;
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: loc.deleteCustomer,
      message:
          loc.deleteCustomerConfirm.replaceAll('{name}', widget.customer.name),
      confirmText: loc.delete,
      cancelText: loc.cancel,
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      await _deleteCustomer();
    }
  }

  Future<void> _deleteCustomer() async {
    final loc = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
      _loadingMessage = loc.deletingCustomer;
    });

    final repo = getIt<CustomerRepository>();
    final result = await repo.deleteCustomer(widget.customer.id);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _loadingMessage = null;
    });

    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.customerDeletedSuccessfully),
          backgroundColor: Colors.green,
        ),
      );
      context.read<CustomerBloc>().add(
            const LoadCustomersEvent(refresh: true, isActive: true),
          );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.failureOrNull?.message ?? loc.failedToDeleteCustomer,
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
    final balanceValue = _currentBalance;
    final willGet = balanceValue >= 0;
    final balanceLabel = willGet ? loc.youWillGet : loc.youWillGive;
    final balanceColor = willGet ? AppTheme.errorColor : AppTheme.successColor;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.customer.name,
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
        actions: [
          PopupMenuButton<_CustomerMenuAction>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (action) {
              if (action == _CustomerMenuAction.delete) {
                _confirmDeleteCustomer();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _CustomerMenuAction.delete,
                child: Row(
                  children: [
                    Icon(Icons.delete, color: theme.colorScheme.error),
                    const SizedBox(width: 8),
                    Text(loc.deleteCustomer),
                  ],
                ),
              ),
            ],
          ),
        ],
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
                            willGet ? Icons.arrow_downward : Icons.arrow_upward,
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
                            onTap: _openCustomerReport,
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
                          child: Text(
                            loc.entries,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 92,
                          child: Text(
                            loc.youGave,
                            textAlign: TextAlign.right,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.errorColor,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 92,
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
                                      ? _formatEntryDate(
                                          entry.date!,
                                          loc.locale,
                                        )
                                      : loc.unknown;
                                  final remarks =
                                      entry.transaction['remarks']?.toString();
                                  final invoiceNumber = entry
                                      .transaction['invoice_number']
                                      ?.toString()
                                      .trim();
                                  final hasDetails = _isPaymentEntry(entry) ||
                                      _invoiceIdForEntry(entry) != null;
                                  final runningBalanceAbs =
                                      CurrencyUtils.formatCurrency(
                                    entry.runningBalance.abs(),
                                  );
                                  final runningBalanceColor =
                                      entry.runningBalance >= 0
                                          ? AppTheme.errorColor
                                          : AppTheme.successColor;

                                  return AppCard(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: EdgeInsets.zero,
                                    onTap: hasDetails
                                        ? () => _openEntry(entry)
                                        : null,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 9,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  dateText,
                                                  style: theme
                                                      .textTheme.bodySmall
                                                      ?.copyWith(
                                                    color: theme.colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  title,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: theme
                                                      .textTheme.titleSmall
                                                      ?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                if (invoiceNumber != null &&
                                                    invoiceNumber
                                                        .isNotEmpty) ...[
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    '${loc.invoiceNumber}: $invoiceNumber',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: theme
                                                        .textTheme.bodySmall
                                                        ?.copyWith(
                                                      color: theme.colorScheme
                                                          .onSurfaceVariant,
                                                    ),
                                                  ),
                                                ],
                                                if (remarks != null &&
                                                    remarks.isNotEmpty &&
                                                    !_isPaymentEntry(
                                                        entry)) ...[
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    remarks,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: theme
                                                        .textTheme.bodySmall
                                                        ?.copyWith(
                                                      color: theme.colorScheme
                                                          .onSurfaceVariant,
                                                    ),
                                                  ),
                                                ],
                                                const SizedBox(height: 2),
                                                Text(
                                                  '${loc.balance}: $runningBalanceAbs',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: theme
                                                      .textTheme.bodySmall
                                                      ?.copyWith(
                                                    color: runningBalanceColor,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        _AmountCell(
                                          amount: entry.isCredit
                                              ? CurrencyUtils.formatCurrency(
                                                  entry.amount,
                                                )
                                              : '',
                                          highlight: entry.isCredit,
                                          color: AppTheme.errorColor,
                                        ),
                                        _AmountCell(
                                          amount: entry.isCredit
                                              ? ''
                                              : CurrencyUtils.formatCurrency(
                                                  entry.amount,
                                                ),
                                          highlight: !entry.isCredit,
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
                  onPressed: _recordCredit,
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
                  onPressed: _recordPayment,
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
    return SizedBox(
      width: 92,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
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

String _formatEntryDate(DateTime date, Locale locale) {
  return DateFormat(
    'EEE, d MMM yy • h:mm a',
    locale.languageCode,
  ).format(date);
}

String _entryActionLabel(AppLocalizations loc, String action) {
  return '${action.toUpperCase()} ${loc.transaction.toUpperCase()}';
}

class _CustomerEntryDetailScreen extends StatefulWidget {
  const _CustomerEntryDetailScreen({
    required this.customer,
    required this.entry,
    required this.invoice,
    required this.currentBalance,
  });

  final CustomerModel customer;
  final _LedgerEntry entry;
  final InvoiceModel invoice;
  final double currentBalance;

  @override
  State<_CustomerEntryDetailScreen> createState() =>
      _CustomerEntryDetailScreenState();
}

class _CustomerEntryDetailScreenState
    extends State<_CustomerEntryDetailScreen> {
  bool _isProcessing = false;

  String _initials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'NA';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first
          .substring(0, parts.first.length >= 2 ? 2 : 1)
          .toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  bool get _isBackedUp {
    final id = widget.invoice.id.toUpperCase();
    return !id.startsWith('LOCAL-') && !id.startsWith('OFFLINE_');
  }

  Future<void> _editEntry() async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => InvoiceBloc(
            invoiceRepository: getIt<InvoiceRepository>(),
          ),
          child: CreateInvoiceScreen(
            initialCustomer: widget.customer,
            initialCustomerId: widget.customer.id,
            existingInvoice: widget.invoice,
          ),
        ),
      ),
    );

    if (updated == true && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _deleteEntry() async {
    final loc = AppLocalizations.of(context)!;
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: loc.delete,
      message: loc.deleteCustomerConfirm.replaceAll(
          '{name}', '${loc.invoice} ${widget.invoice.invoiceNumber}'),
      confirmText: loc.delete,
      cancelText: loc.cancel,
      isDestructive: true,
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isProcessing = true);
    final result =
        await getIt<InvoiceRepository>().deleteInvoice(widget.invoice.id);
    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.success),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.failureOrNull?.message ?? loc.failedToLoadData),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _shareEntryPdf({required bool asWhatsApp}) async {
    final loc = AppLocalizations.of(context)!;
    setState(() => _isProcessing = true);
    try {
      final detailsResult =
          await getIt<InvoiceRepository>().getInvoiceById(widget.invoice.id);
      final displayInvoice = detailsResult.dataOrNull ?? widget.invoice;
      final localStorage = getIt<LocalStorageService>();
      final bytes = await InvoicePdfBuilder.build(
        loc: loc,
        invoice: displayInvoice,
        businessName: localStorage.getBusinessName(),
        businessPhone: localStorage.getUserPhone(),
        generatedBy: localStorage.getUserName(),
      );
      final amount = double.tryParse(displayInvoice.totalAmount) ?? 0;
      final fileName =
          'entry_${displayInvoice.invoiceNumber}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      await Share.shareXFiles(
        [
          XFile.fromData(
            bytes,
            mimeType: 'application/pdf',
            name: fileName,
          ),
        ],
        text:
            '${loc.invoice} ${displayInvoice.invoiceNumber}\n${loc.totalAmount}: ${CurrencyUtils.formatCurrency(amount)}',
        subject: '${loc.invoice} ${displayInvoice.invoiceNumber}',
      );

      if (asWhatsApp && mounted && !kIsWeb) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.whatsappOpenedAttachPdf)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${loc.errorSharingInvoice}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final invoice = widget.invoice;
    final items = invoice.items ?? const <InvoiceItemModel>[];
    final entryDate = widget.entry.date ?? invoice.date;
    final dateText = _formatEntryDate(entryDate, loc.locale);
    final amount = double.tryParse(invoice.totalAmount) ?? widget.entry.amount;
    final isGive = widget.entry.isCredit;
    final amountColor = isGive ? AppTheme.errorColor : AppTheme.successColor;
    final createBillLabel = '${loc.create} ${loc.bill}';

    return LoadingOverlay(
      isLoading: _isProcessing,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          centerTitle: false,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            loc.entryDetail,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 20),
          children: [
            AppCard(
              borderRadius: BorderRadius.circular(14),
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: theme.colorScheme.surfaceVariant,
                          child: Text(
                            _initials(widget.customer.name),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.customer.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                dateText,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              CurrencyUtils.formatCurrency(amount),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: amountColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isGive ? loc.youGave : loc.youGot,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: amountColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: theme.colorScheme.outline.withValues(alpha: 0.25),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceVariant
                                .withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            '${items.length} ${loc.items}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          createBillLabel,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color:
                        theme.colorScheme.surfaceVariant.withValues(alpha: 0.7),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text(
                            loc.item.toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            loc.quantity,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            loc.unitPrice,
                            textAlign: TextAlign.right,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            loc.amount,
                            textAlign: TextAlign.right,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Text(
                              loc.invoice,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Text('1', textAlign: TextAlign.center),
                          ),
                          Expanded(
                            child: Text(
                              CurrencyUtils.formatCurrency(amount),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              CurrencyUtils.formatCurrency(amount),
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: amountColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...items.map((item) {
                      final qty = double.tryParse(item.quantity) ?? 0;
                      final unitPrice = double.tryParse(item.unitPrice) ?? 0;
                      final lineAmount =
                          double.tryParse(item.totalPrice) ?? (qty * unitPrice);
                      final qtyText = qty % 1 == 0
                          ? qty.toInt().toString()
                          : NumberFormat('0.##').format(qty);
                      return Column(
                        children: [
                          Divider(
                            height: 1,
                            color: theme.colorScheme.outline
                                .withValues(alpha: 0.18),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 11,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Text(
                                    item.itemName,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    qtyText,
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    CurrencyUtils.formatCurrency(unitPrice),
                                    textAlign: TextAlign.right,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    CurrencyUtils.formatCurrency(lineAmount),
                                    textAlign: TextAlign.right,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                  Divider(
                    height: 1,
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 13,
                    ),
                    child: Row(
                      children: [
                        Text(
                          loc.currentBalance,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          CurrencyUtils.formatCurrency(
                              widget.currentBalance.abs()),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: amountColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _EntryActionTile(
              icon: Icons.edit_rounded,
              label: _entryActionLabel(loc, loc.edit),
              onTap: _editEntry,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 8),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              child: Row(
                children: [
                  Icon(
                    _isBackedUp
                        ? Icons.cloud_done_outlined
                        : Icons.sync_problem_outlined,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _isBackedUp
                        ? 'Entry is backed up'
                        : 'Entry is not backed up',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _EntryActionTile(
              icon: Icons.delete_outline_rounded,
              label: _entryActionLabel(loc, loc.delete),
              onTap: _deleteEntry,
              color: AppTheme.errorColor,
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            color: theme.scaffoldBackgroundColor,
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _shareEntryPdf(asWhatsApp: true),
                    style: OutlinedButton.styleFrom(
                      shape: const StadiumBorder(),
                      side: BorderSide(
                        color:
                            theme.colorScheme.primary.withValues(alpha: 0.55),
                        width: 1.3,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      loc.whatsapp.toUpperCase(),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _shareEntryPdf(asWhatsApp: false),
                    style: OutlinedButton.styleFrom(
                      shape: const StadiumBorder(),
                      side: BorderSide(
                        color:
                            theme.colorScheme.primary.withValues(alpha: 0.55),
                        width: 1.3,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      loc.share.toUpperCase(),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomerPaymentEntryDetailScreen extends StatefulWidget {
  const _CustomerPaymentEntryDetailScreen({
    required this.customer,
    required this.entry,
    required this.currentBalance,
  });

  final CustomerModel customer;
  final _LedgerEntry entry;
  final double currentBalance;

  @override
  State<_CustomerPaymentEntryDetailScreen> createState() =>
      _CustomerPaymentEntryDetailScreenState();
}

class _CustomerPaymentEntryDetailScreenState
    extends State<_CustomerPaymentEntryDetailScreen> {
  bool _isProcessing = false;

  String _initials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'NA';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first
          .substring(0, parts.first.length >= 2 ? 2 : 1)
          .toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String? get _transactionId => widget.entry.transaction['id']?.toString();

  bool get _isBackedUp {
    final id = (_transactionId ?? '').toUpperCase();
    if (id.isEmpty) return false;
    return !id.startsWith('LOCAL-') && !id.startsWith('OFFLINE_');
  }

  Future<void> _editEntry() async {
    final loc = AppLocalizations.of(context)!;
    final transactionId = _transactionId;
    if (transactionId == null || transactionId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.failedToRecordPayment),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final amountController = TextEditingController(
      text: widget.entry.amount % 1 == 0
          ? widget.entry.amount.toInt().toString()
          : widget.entry.amount.toString(),
    );
    final remarksController = TextEditingController(
      text: widget.entry.transaction['remarks']?.toString() ?? '',
    );
    DateTime selectedDate = widget.entry.date ?? DateTime.now();
    String? selectedInvoiceId =
        widget.entry.transaction['reference_type']?.toString() == 'invoice'
            ? widget.entry.transaction['reference_id']?.toString()
            : null;

    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (context) => _PaymentDialog(
        customerId: widget.customer.id,
        amountController: amountController,
        remarksController: remarksController,
        selectedDate: selectedDate,
        selectedInvoiceId: selectedInvoiceId,
        enableInvoiceSelection: false,
        onDateChanged: (date) => selectedDate = date,
        onInvoiceChanged: (invoiceId) => selectedInvoiceId = invoiceId,
      ),
    );

    if (result == null || !mounted) return;
    setState(() => _isProcessing = true);
    final updateResult =
        await getIt<CustomerRepository>().updatePaymentTransaction(
      customerId: widget.customer.id,
      transactionId: transactionId,
      amount: amountController.text.trim(),
      date: selectedDate,
      remarks: remarksController.text.trim().isEmpty
          ? null
          : remarksController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (updateResult.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.success),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            updateResult.failureOrNull?.message ?? loc.failedToRecordPayment),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _deleteEntry() async {
    final loc = AppLocalizations.of(context)!;
    final transactionId = _transactionId;
    if (transactionId == null || transactionId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.failedToRecordPayment),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: loc.delete,
      message:
          loc.deleteCustomerConfirm.replaceAll('{name}', loc.paymentReceived),
      confirmText: loc.delete,
      cancelText: loc.cancel,
      isDestructive: true,
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isProcessing = true);
    final deleteResult =
        await getIt<CustomerRepository>().deletePaymentTransaction(
      customerId: widget.customer.id,
      transactionId: transactionId,
    );
    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (deleteResult.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.success),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            deleteResult.failureOrNull?.message ?? loc.failedToRecordPayment),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _shareEntry({required bool asWhatsApp}) async {
    final loc = AppLocalizations.of(context)!;
    setState(() => _isProcessing = true);
    try {
      final bytes = await _buildPaymentEntryPdfBytes(loc);
      final fileName =
          'entry_${DateTime.now().millisecondsSinceEpoch}_payment.pdf';
      final amountText =
          CurrencyUtils.formatCurrency(widget.entry.amount.abs());

      await Share.shareXFiles(
        [
          XFile.fromData(
            bytes,
            mimeType: 'application/pdf',
            name: fileName,
          ),
        ],
        text:
            '${loc.entryDetail}\n${loc.paymentReceived}: $amountText\n${widget.customer.name}',
        subject: '${loc.entryDetail} - ${widget.customer.name}',
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }

    if (asWhatsApp && mounted && !kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.whatsappOpenedAttachPdf)),
      );
    }
  }

  Future<Uint8List> _buildPaymentEntryPdfBytes(AppLocalizations loc) async {
    final pdf = pw.Document();
    final entryDate = widget.entry.date ?? DateTime.now();
    final amount = widget.entry.amount.abs();
    final remarks = widget.entry.transaction['remarks']?.toString().trim();
    final balanceAbs = widget.currentBalance.abs();
    final balanceLabel =
        widget.currentBalance >= 0 ? loc.youWillGet : loc.youWillGive;
    final dateText = DateFormat('yyyy-MM-dd HH:mm').format(entryDate);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              loc.entryDetail,
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 14),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey500, width: 0.8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    widget.customer.name,
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    '${loc.paymentReceived}: ${CurrencyUtils.formatCurrency(amount)}',
                  ),
                  pw.Text('${loc.date}: $dateText'),
                  if (remarks != null && remarks.isNotEmpty)
                    pw.Text('${loc.remarks}: $remarks'),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    '${loc.currentBalance}: ${CurrencyUtils.formatCurrency(balanceAbs)} ($balanceLabel)',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final entryDate = widget.entry.date ?? DateTime.now();
    final dateText = _formatEntryDate(entryDate, loc.locale);
    final amount = widget.entry.amount.abs();
    final amountColor =
        widget.entry.isCredit ? AppTheme.errorColor : AppTheme.successColor;
    final balanceColor = widget.currentBalance >= 0
        ? AppTheme.errorColor
        : AppTheme.successColor;

    return LoadingOverlay(
      isLoading: _isProcessing,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          centerTitle: false,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            loc.entryDetail,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 20),
          children: [
            AppCard(
              borderRadius: BorderRadius.circular(14),
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: theme.colorScheme.surfaceVariant,
                          child: Text(
                            _initials(widget.customer.name),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.customer.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                dateText,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              CurrencyUtils.formatCurrency(amount),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: amountColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.entry.isCredit ? loc.youGave : loc.youGot,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: amountColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: theme.colorScheme.outline.withValues(alpha: 0.25),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceVariant
                                .withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            '1 ${loc.items}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          loc.paymentReceived,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: amountColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color:
                        theme.colorScheme.surfaceVariant.withValues(alpha: 0.7),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text(
                            loc.item.toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            loc.quantity,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            loc.unitPrice,
                            textAlign: TextAlign.right,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            loc.amount,
                            textAlign: TextAlign.right,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text(
                            loc.paymentReceived,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Text('1', textAlign: TextAlign.center),
                        ),
                        Expanded(
                          child: Text(
                            CurrencyUtils.formatCurrency(amount),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            CurrencyUtils.formatCurrency(amount),
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: amountColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 13,
                    ),
                    child: Row(
                      children: [
                        Text(
                          loc.currentBalance,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          CurrencyUtils.formatCurrency(
                              widget.currentBalance.abs()),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: balanceColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _EntryActionTile(
              icon: Icons.edit_rounded,
              label: _entryActionLabel(loc, loc.edit),
              onTap: _editEntry,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 8),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              child: Row(
                children: [
                  Icon(
                    _isBackedUp
                        ? Icons.cloud_done_outlined
                        : Icons.sync_problem_outlined,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _isBackedUp
                        ? 'Entry is backed up'
                        : 'Entry is not backed up',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _EntryActionTile(
              icon: Icons.delete_outline_rounded,
              label: _entryActionLabel(loc, loc.delete),
              onTap: _deleteEntry,
              color: AppTheme.errorColor,
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            color: theme.scaffoldBackgroundColor,
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _shareEntry(asWhatsApp: true),
                    style: OutlinedButton.styleFrom(
                      shape: const StadiumBorder(),
                      side: BorderSide(
                        color:
                            theme.colorScheme.primary.withValues(alpha: 0.55),
                        width: 1.3,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      loc.whatsapp.toUpperCase(),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _shareEntry(asWhatsApp: false),
                    style: OutlinedButton.styleFrom(
                      shape: const StadiumBorder(),
                      side: BorderSide(
                        color:
                            theme.colorScheme.primary.withValues(alpha: 0.55),
                        width: 1.3,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      loc.share.toUpperCase(),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EntryActionTile extends StatelessWidget {
  const _EntryActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerReportScreen extends StatefulWidget {
  const _CustomerReportScreen({
    required this.customer,
    required this.entries,
    required this.dateRange,
    required this.currentBalance,
  });

  final CustomerModel customer;
  final List<_LedgerEntry> entries;
  final DateTimeRange? dateRange;
  final double currentBalance;

  @override
  State<_CustomerReportScreen> createState() => _CustomerReportScreenState();
}

class _CustomerReportScreenState extends State<_CustomerReportScreen> {
  bool _isSharing = false;
  bool _isLoadingInvoices = false;
  final InvoiceRepository _invoiceRepository = getIt<InvoiceRepository>();
  final Map<String, InvoiceModel> _invoiceCache = {};

  @override
  void initState() {
    super.initState();
    _prefetchInvoices();
  }

  String? _invoiceIdForEntry(_LedgerEntry entry) {
    if (!entry.isCredit) return null;
    final refType = entry.transaction['reference_type']?.toString();
    if (refType != 'invoice') return null;
    final refId = entry.transaction['reference_id']?.toString();
    if (refId == null || refId.isEmpty) return null;
    return refId;
  }

  Future<void> _prefetchInvoices() async {
    final invoiceIds = widget.entries
        .map(_invoiceIdForEntry)
        .where((id) => id != null)
        .cast<String>()
        .where((id) => !_invoiceCache.containsKey(id))
        .toSet();

    if (invoiceIds.isEmpty) return;

    if (mounted) {
      setState(() => _isLoadingInvoices = true);
    }

    await Future.wait(
      invoiceIds.map((id) async {
        final result = await _invoiceRepository.getInvoiceById(id);
        if (result.isSuccess && result.dataOrNull != null) {
          _invoiceCache[id] = result.dataOrNull!;
        }
      }),
    );

    if (mounted) {
      setState(() => _isLoadingInvoices = false);
    }
  }

  String _formatQuantity(String value) {
    final parsed = double.tryParse(value);
    if (parsed == null) return value;
    if (parsed % 1 == 0) return parsed.toInt().toString();
    return parsed.toString();
  }

  String _formatCurrencyFromString(String value) {
    final parsed = double.tryParse(value) ?? 0;
    return CurrencyUtils.formatCurrency(parsed);
  }

  List<_EntryLine> _buildEntryLines(
    AppLocalizations loc,
    DateFormat dateFormatter,
    DateFormat timeFormatter,
  ) {
    final lines = <_EntryLine>[];

    for (final entry in widget.entries) {
      final dateText = entry.date != null
          ? '${dateFormatter.format(entry.date!)} - ${timeFormatter.format(entry.date!)}'
          : loc.unknown;
      final remarks = entry.transaction['remarks']?.toString();
      final hasRemarks = remarks != null && remarks.trim().isNotEmpty;
      final invoiceId = _invoiceIdForEntry(entry);
      final invoice = invoiceId != null ? _invoiceCache[invoiceId] : null;
      final items = invoice?.items ?? const <InvoiceItemModel>[];
      final namedItems =
          items.where((item) => item.itemName.trim().isNotEmpty).toList();

      if (invoiceId != null && namedItems.isNotEmpty) {
        for (var index = 0; index < namedItems.length; index++) {
          final item = namedItems[index];
          final itemName = item.itemName;
          final unitPriceValue = double.tryParse(item.unitPrice) ?? 0;
          final quantityValue = double.tryParse(item.quantity) ?? 0;
          final totalPrice = item.totalPrice.isNotEmpty
              ? _formatCurrencyFromString(item.totalPrice)
              : CurrencyUtils.formatCurrency(
                  unitPriceValue * quantityValue,
                );
          lines.add(
            _EntryLine(
              title: itemName,
              subtitle: dateText,
              remarks: index == 0 && hasRemarks ? remarks : null,
              quantity: _formatQuantity(item.quantity),
              unitPrice: _formatCurrencyFromString(item.unitPrice),
              amount: totalPrice,
              amountColor: AppTheme.errorColor,
            ),
          );
        }
        continue;
      }

      final amountText = CurrencyUtils.formatCurrency(entry.amount.abs());
      final title = invoiceId != null
          ? _isLoadingInvoices
              ? loc.loading
              : loc.creditInvoice
          : _localizedEntryTitle(entry, loc);
      final amountColor =
          entry.isCredit ? AppTheme.errorColor : AppTheme.successColor;

      lines.add(
        _EntryLine(
          title: title,
          subtitle: dateText,
          remarks: hasRemarks ? remarks : null,
          quantity: '1',
          unitPrice: amountText,
          amount: amountText,
          amountColor: amountColor,
        ),
      );
    }

    return lines;
  }

  String _localizedEntryTitle(_LedgerEntry entry, AppLocalizations loc) {
    final type = entry.transaction['transaction_type']?.toString();
    if (type == 'credit') {
      return loc.creditInvoice;
    }
    if (type == 'payment') {
      return loc.paymentReceived;
    }
    return loc.transaction;
  }

  String _englishEntryTitle(_LedgerEntry entry) {
    final type = entry.transaction['transaction_type']?.toString();
    if (type == 'credit') {
      return 'Credit';
    }
    if (type == 'payment') {
      return 'Payment';
    }
    return 'Transaction';
  }

  String _buildShareMessage(
    AppLocalizations loc,
    DateFormat dateFormatter,
    double totalCredit,
    double totalPayment,
    String balanceLabel,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('${loc.report}: ${widget.customer.name}');
    if (widget.dateRange != null) {
      buffer.writeln(
        '${loc.dateRange}: ${dateFormatter.format(widget.dateRange!.start)} - ${dateFormatter.format(widget.dateRange!.end)}',
      );
    }
    buffer.writeln('${loc.entries}: ${widget.entries.length}');
    buffer.writeln(
        '${loc.youGave}: ${CurrencyUtils.formatCurrency(totalCredit)}');
    buffer.writeln(
        '${loc.youGot}: ${CurrencyUtils.formatCurrency(totalPayment)}');
    buffer.writeln(
      '${loc.balance}: ${CurrencyUtils.formatCurrency(widget.currentBalance.abs())} ($balanceLabel)',
    );
    return buffer.toString().trim();
  }

  String _buildInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final first = parts[0];
    final second = parts.length > 1 ? parts[1] : '';
    final initials =
        '${first.isNotEmpty ? first[0] : ''}${second.isNotEmpty ? second[0] : ''}';
    return initials.toUpperCase();
  }

  String _safeFileName(String name) {
    final normalized = name.trim().replaceAll(RegExp(r'\s+'), '_');
    final sanitized = normalized.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '');
    return sanitized.isEmpty ? 'customer' : sanitized;
  }

  Future<Uint8List> _buildPdfBytes({
    required double totalCredit,
    required double totalPayment,
    required String balanceLabelEnglish,
  }) async {
    const outerBorder = 1.2;
    const innerBorder = 0.75;
    final loc = AppLocalizations.of(context)!;
    final storage = getIt<LocalStorageService>();
    final businessName = storage.getBusinessName() ?? 'Business';
    final businessPhone = storage.getUserPhone() ?? '';
    final generatedBy = storage.getUserName() ?? loc.system;

    final pdf = pw.Document();
    final formatter = NumberFormat.currency(
      locale: 'en',
      symbol: 'Rs ',
      decimalDigits: 2,
    );
    final dateFormatter = DateFormat('dd/MM/yyyy');
    final timeFormatter = DateFormat('hh:mm a');
    final latestEntry = widget.entries.isNotEmpty ? widget.entries.first : null;
    final latestDateText = latestEntry?.date != null
        ? '${dateFormatter.format(latestEntry!.date!)} ${timeFormatter.format(latestEntry.date!)}'
        : '-';

    pw.MemoryImage? logo;
    try {
      final bytes = await rootBundle.load('app-logo.jpeg');
      logo = pw.MemoryImage(bytes.buffer.asUint8List());
    } catch (_) {}

    final rows = <List<String>>[];
    var rowNo = 1;
    for (final entry in widget.entries) {
      final dateText =
          entry.date != null ? dateFormatter.format(entry.date!) : '';
      final invoiceId = _invoiceIdForEntry(entry);
      final invoice = invoiceId != null ? _invoiceCache[invoiceId] : null;
      final items = invoice?.items ?? const <InvoiceItemModel>[];
      final namedItems =
          items.where((item) => item.itemName.trim().isNotEmpty).toList();

      if (invoiceId != null && namedItems.isNotEmpty) {
        for (final item in namedItems) {
          final unitPriceValue = double.tryParse(item.unitPrice) ?? 0;
          final quantityValue = double.tryParse(item.quantity) ?? 0;
          final totalValue = item.totalPrice.isNotEmpty
              ? double.tryParse(item.totalPrice) ?? 0
              : unitPriceValue * quantityValue;
          rows.add([
            '$rowNo',
            dateText.isEmpty ? item.itemName : '${item.itemName} - $dateText',
            _formatQuantity(item.quantity),
            formatter.format(unitPriceValue),
            formatter.format(totalValue),
          ]);
          rowNo += 1;
        }
      } else {
        final remarks = entry.transaction['remarks']?.toString();
        final fallbackTitle = invoiceId != null
            ? 'Credit Invoice'
            : ((remarks != null && remarks.trim().isNotEmpty)
                ? remarks.trim()
                : _englishEntryTitle(entry));
        final amount = formatter.format(entry.amount.abs());
        rows.add([
          '$rowNo',
          dateText.isEmpty ? fallbackTitle : '$fallbackTitle - $dateText',
          '1',
          amount,
          amount,
        ]);
        rowNo += 1;
      }
    }

    const minRows = 10;
    if (rows.length < minRows) {
      for (var i = rows.length; i < minRows; i++) {
        rows.add(['', '', '', '', '']);
      }
    }

    pw.Widget buildMetaTable(List<(String, String)> lines) {
      return pw.Table(
        columnWidths: {
          0: const pw.FixedColumnWidth(80),
        },
        children: lines
            .map(
              (line) => pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.fromLTRB(0, 1, 4, 5),
                    child: pw.Text(
                      line.$1,
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontSize: 7.8,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Container(
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(
                        bottom: pw.BorderSide(
                          color: PdfColors.black,
                          width: innerBorder,
                        ),
                      ),
                    ),
                    padding: const pw.EdgeInsets.fromLTRB(3, 1, 2, 5),
                    child: pw.Text(
                      line.$2,
                      style: const pw.TextStyle(fontSize: 7.8),
                    ),
                  ),
                ],
              ),
            )
            .toList(growable: false),
      );
    }

    final generatedAt = DateTime.now();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(18, 18, 18, 18),
        build: (_) => [
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: outerBorder),
              borderRadius: const pw.BorderRadius.all(
                pw.Radius.circular(4),
              ),
            ),
            padding: const pw.EdgeInsets.all(7),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Container(
                  width: 70,
                  height: 70,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      color: PdfColors.black,
                      width: innerBorder,
                    ),
                  ),
                  alignment: pw.Alignment.center,
                  child: pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data:
                        '${widget.customer.name}|$latestDateText|${widget.currentBalance.abs()}',
                    width: 58,
                    height: 58,
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      if (logo != null)
                        pw.SizedBox(
                          width: 78,
                          height: 48,
                          child: pw.Image(logo),
                        )
                      else
                        pw.Text(
                          'DIGI KHATA',
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        loc.entryDetail,
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.SizedBox(
                  width: 150,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        businessName,
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                        ),
                        textAlign: pw.TextAlign.right,
                      ),
                      if (businessPhone.trim().isNotEmpty) ...[
                        pw.SizedBox(height: 3),
                        pw.Text(
                          businessPhone.trim(),
                          style: const pw.TextStyle(fontSize: 8),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: buildMetaTable([
                  (loc.customer, widget.customer.name),
                  ('Latest Entry', latestDateText),
                  (loc.entries, '${widget.entries.length}'),
                  if (widget.dateRange != null)
                    (
                      loc.dateRange,
                      '${dateFormatter.format(widget.dateRange!.start)} - ${dateFormatter.format(widget.dateRange!.end)}',
                    ),
                ]),
              ),
              pw.SizedBox(width: 10),
              pw.Expanded(
                child: buildMetaTable([
                  (loc.youGave, formatter.format(totalCredit)),
                  (loc.youGot, formatter.format(totalPayment)),
                  (
                    loc.runningBalance,
                    '${formatter.format(widget.currentBalance.abs())} ($balanceLabelEnglish)',
                  ),
                  (loc.date, dateFormatter.format(generatedAt)),
                ]),
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.TableHelper.fromTextArray(
            headers: ['#', loc.item, loc.quantity, loc.unitPrice, loc.amount],
            data: rows,
            headerStyle: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
            ),
            cellStyle: const pw.TextStyle(fontSize: 7.7),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            border:
                pw.TableBorder.all(color: PdfColors.black, width: innerBorder),
            cellHeight: 18,
            headerHeight: 18,
            columnWidths: {
              0: const pw.FixedColumnWidth(22),
              1: const pw.FlexColumnWidth(3.8),
              2: const pw.FixedColumnWidth(24),
              3: const pw.FixedColumnWidth(56),
              4: const pw.FixedColumnWidth(56),
            },
            cellAlignments: {
              0: pw.Alignment.center,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.centerRight,
              3: pw.Alignment.centerRight,
              4: pw.Alignment.centerRight,
            },
          ),
          pw.SizedBox(height: rows.length <= 10 ? 120 : 12),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Expanded(
                child: pw.Text(
                  loc.additionalNotes,
                  style: const pw.TextStyle(fontSize: 7.8),
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Container(
                width: 205,
                decoration: pw.BoxDecoration(
                  border:
                      pw.Border.all(color: PdfColors.black, width: outerBorder),
                ),
                child: pw.Table(
                  children: [
                    (loc.youGave, formatter.format(totalCredit)),
                    (loc.youGot, formatter.format(totalPayment)),
                    (
                      loc.runningBalance,
                      formatter.format(widget.currentBalance.abs()),
                    ),
                  ]
                      .map(
                        (line) => pw.TableRow(
                          children: [
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 3,
                              ),
                              decoration: const pw.BoxDecoration(
                                border: pw.Border(
                                  right: pw.BorderSide(
                                    color: PdfColors.black,
                                    width: innerBorder,
                                  ),
                                  bottom: pw.BorderSide(
                                    color: PdfColors.black,
                                    width: innerBorder,
                                  ),
                                ),
                              ),
                              child: pw.Text(
                                line.$1,
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(
                                  fontSize: 7.8,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 3,
                              ),
                              decoration: const pw.BoxDecoration(
                                border: pw.Border(
                                  bottom: pw.BorderSide(
                                    color: PdfColors.black,
                                    width: innerBorder,
                                  ),
                                ),
                              ),
                              child: pw.Text(
                                line.$2,
                                textAlign: pw.TextAlign.right,
                                style: const pw.TextStyle(fontSize: 7.8),
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Container(
            padding: const pw.EdgeInsets.only(top: 5),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(color: PdfColors.black, width: outerBorder),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  generatedBy,
                  style: const pw.TextStyle(fontSize: 7.8),
                ),
                pw.Row(
                  children: [
                    pw.Text(
                      '1/1',
                      style: const pw.TextStyle(fontSize: 7.8),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Text(
                      DateFormat('dd/MM/yyyy hh:mm a').format(generatedAt),
                      style: const pw.TextStyle(fontSize: 7.8),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Uint8List.fromList(await pdf.save());
  }

  Future<void> _sharePdf({
    required String message,
    required double totalCredit,
    required double totalPayment,
    required String balanceLabelEnglish,
  }) async {
    if (_isSharing) return;
    setState(() => _isSharing = true);
    final loc = AppLocalizations.of(context)!;

    try {
      await _prefetchInvoices();
      final pdfBytes = await _buildPdfBytes(
        totalCredit: totalCredit,
        totalPayment: totalPayment,
        balanceLabelEnglish: balanceLabelEnglish,
      );
      final safeName = _safeFileName(widget.customer.name);
      final fileName =
          'ledger_${safeName}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      if (kIsWeb) {
        await Share.shareXFiles(
          [
            XFile.fromData(
              pdfBytes,
              mimeType: 'application/pdf',
              name: fileName,
            )
          ],
          text: message,
          subject: '${loc.report} - ${widget.customer.name}',
        );
      } else {
        final tempDir = await getTemporaryDirectory();
        final filePath = path.join(tempDir.path, fileName);
        final file = File(filePath);
        await file.writeAsBytes(pdfBytes, flush: true);
        await Share.shareXFiles(
          [
            XFile(
              filePath,
              mimeType: 'application/pdf',
              name: fileName,
            ),
          ],
          text: message,
          subject: '${loc.report} - ${widget.customer.name}',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${loc.error}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final dateFormatter = DateFormat.yMMMd(loc.locale.languageCode);
    final timeFormatter = DateFormat.jm(loc.locale.languageCode);

    double totalCredit = 0;
    double totalPayment = 0;
    for (final entry in widget.entries) {
      if (entry.isCredit) {
        totalCredit += entry.amount;
      } else {
        totalPayment += entry.amount;
      }
    }

    final balanceIsPositive = widget.currentBalance >= 0;
    final balanceLabel = balanceIsPositive ? loc.youWillGet : loc.youWillGive;
    final balanceLabelEnglish =
        balanceIsPositive ? 'You will get' : 'You will give';
    final balanceColor =
        balanceIsPositive ? AppTheme.errorColor : AppTheme.successColor;

    final latestEntry = widget.entries.isNotEmpty ? widget.entries.first : null;
    final latestDateText = latestEntry?.date != null
        ? '${dateFormatter.format(latestEntry!.date!)} - ${timeFormatter.format(latestEntry.date!)}'
        : loc.unknown;
    final headerIsCredit = latestEntry?.isCredit ?? !balanceIsPositive;
    final headerAmount = latestEntry?.amount ?? widget.currentBalance.abs();
    final headerLabel = latestEntry == null
        ? balanceLabel
        : headerIsCredit
            ? loc.youGave
            : loc.youGot;
    final headerColor =
        headerIsCredit ? AppTheme.errorColor : AppTheme.successColor;

    final shareMessage = _buildShareMessage(
      loc,
      dateFormatter,
      totalCredit,
      totalPayment,
      balanceLabel,
    );
    final entryLines = _buildEntryLines(
      loc,
      dateFormatter,
      timeFormatter,
    );

    return LoadingOverlay(
      isLoading: _isSharing,
      message: loc.loading,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          iconTheme: const IconThemeData(color: Colors.white),
          titleSpacing: 0,
          title: Text(
            loc.entryDetail,
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
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor:
                        theme.colorScheme.primary.withValues(alpha: 0.1),
                    child: Text(
                      _buildInitials(widget.customer.name),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.customer.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          latestDateText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyUtils.formatCurrency(headerAmount),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: headerColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        headerLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: headerColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceVariant
                                .withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${widget.entries.length} ${loc.entries}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              loc.youGave,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.errorColor,
                              ),
                            ),
                            Text(
                              CurrencyUtils.formatCurrency(totalCredit),
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.errorColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              loc.youGot,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.successColor,
                              ),
                            ),
                            Text(
                              CurrencyUtils.formatCurrency(totalPayment),
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.successColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color:
                        theme.colorScheme.surfaceVariant.withValues(alpha: 0.4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text(
                            loc.item,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            loc.quantity,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            loc.unitPrice,
                            textAlign: TextAlign.right,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            loc.amount,
                            textAlign: TextAlign.right,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.entries.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        loc.noTransactionsYet,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: entryLines.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color:
                            theme.colorScheme.outline.withValues(alpha: 0.15),
                      ),
                      itemBuilder: (context, index) {
                        final line = entryLines[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      line.title,
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (line.subtitle.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        line.subtitle,
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                    if (line.remarks != null &&
                                        line.remarks!.trim().isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        line.remarks!,
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  line.quantity,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  line.unitPrice,
                                  textAlign: TextAlign.right,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  line.amount,
                                  textAlign: TextAlign.right,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: line.amountColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant
                          .withValues(alpha: 0.3),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          loc.runningBalance,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          CurrencyUtils.formatCurrency(
                            widget.currentBalance.abs(),
                          ),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: balanceColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _sharePdf(
                      message: shareMessage,
                      totalCredit: totalCredit,
                      totalPayment: totalPayment,
                      balanceLabelEnglish: balanceLabelEnglish,
                    ),
                    icon: Icon(Icons.chat, color: AppTheme.successColor),
                    label: Text(loc.whatsapp.toUpperCase()),
                    style: OutlinedButton.styleFrom(
                      shape: const StadiumBorder(),
                      side: BorderSide(
                          color: theme.colorScheme.primary, width: 1.5),
                      foregroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _sharePdf(
                      message: shareMessage,
                      totalCredit: totalCredit,
                      totalPayment: totalPayment,
                      balanceLabelEnglish: balanceLabelEnglish,
                    ),
                    icon: const Icon(Icons.share),
                    label: Text(loc.share.toUpperCase()),
                    style: OutlinedButton.styleFrom(
                      shape: const StadiumBorder(),
                      side: BorderSide(
                          color: theme.colorScheme.primary, width: 1.5),
                      foregroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EntryLine {
  const _EntryLine({
    required this.title,
    required this.subtitle,
    this.remarks,
    required this.quantity,
    required this.unitPrice,
    required this.amount,
    required this.amountColor,
  });

  final String title;
  final String subtitle;
  final String? remarks;
  final String quantity;
  final String unitPrice;
  final String amount;
  final Color amountColor;
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

enum _CustomerMenuAction { delete }

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
    required this.isCredit,
    required this.amount,
    required this.date,
    required this.runningBalance,
  });

  final Map<String, dynamic> transaction;
  final bool isCredit;
  final double amount;
  final DateTime? date;
  final double runningBalance;
}

class _PaymentDialog extends StatefulWidget {
  const _PaymentDialog({
    required this.customerId,
    required this.amountController,
    required this.remarksController,
    required this.selectedDate,
    required this.selectedInvoiceId,
    required this.onDateChanged,
    required this.onInvoiceChanged,
    this.enableInvoiceSelection = true,
  });

  final String customerId;
  final TextEditingController amountController;
  final TextEditingController remarksController;
  final DateTime selectedDate;
  final String? selectedInvoiceId;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<String?> onInvoiceChanged;
  final bool enableInvoiceSelection;

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  late DateTime _selectedDate;
  String? _selectedInvoiceId;
  List<InvoiceModel> _unpaidInvoices = [];
  bool _isLoadingInvoices = false;
  final InvoiceRepository _invoiceRepository = getIt<InvoiceRepository>();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _selectedInvoiceId = widget.selectedInvoiceId;
    if (widget.enableInvoiceSelection) {
      _loadUnpaidInvoices();
    }
  }

  Future<void> _loadUnpaidInvoices() async {
    setState(() => _isLoadingInvoices = true);
    final result = await _invoiceRepository.getInvoices(
      customerId: widget.customerId,
      invoiceType: 'credit', // Only credit invoices can have unpaid amounts
    );

    if (mounted) {
      setState(() {
        _isLoadingInvoices = false;
        if (result.isSuccess) {
          // Filter invoices that have unpaid amounts
          _unpaidInvoices = result.dataOrNull?.where((invoice) {
                final total = double.tryParse(invoice.totalAmount) ?? 0;
                final paid = double.tryParse(invoice.paidAmount) ?? 0;
                return total > paid;
              }).toList() ??
              [];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: theme.colorScheme.surfaceVariant.withValues(alpha: 0.35),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.4)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.2),
      ),
    );

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      title: Text(
        loc.recordPayment,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.enableInvoiceSelection) ...[
                // Invoice Selection
                if (_isLoadingInvoices)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  )
                else if (_unpaidInvoices.isNotEmpty) ...[
                  DropdownButtonFormField<String?>(
                    value: _selectedInvoiceId,
                    isExpanded: true,
                    menuMaxHeight: 320,
                    decoration: inputDecoration.copyWith(
                      labelText: loc.linkToInvoiceOptional,
                      hintText: loc.selectInvoiceOrGeneral,
                      prefixIcon: const Icon(Icons.receipt),
                      helperText: loc.selectInvoiceHelper,
                    ),
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: SizedBox(
                          width: double.infinity,
                          child: Text(
                            loc.generalPayment,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      ..._unpaidInvoices.map((invoice) {
                        final total = double.tryParse(invoice.totalAmount) ?? 0;
                        final paid = double.tryParse(invoice.paidAmount) ?? 0;
                        final unpaid = total - paid;
                        return DropdownMenuItem<String?>(
                          value: invoice.id,
                          child: SizedBox(
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  invoice.invoiceNumber,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${loc.unpaid}: ${CurrencyUtils.formatCurrency(unpaid)} | ${loc.total}: ${CurrencyUtils.formatCurrency(total)}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedInvoiceId = value);
                      widget.onInvoiceChanged(value);
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ],
              // Amount
              Builder(
                builder: (context) {
                  final theme = Theme.of(context);
                  return TextField(
                    controller: widget.amountController,
                    decoration: inputDecoration.copyWith(
                      labelText: loc.amount,
                      prefixIcon: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
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
              // Date
              InkWell(
                onTap: () async {
                  final now = DateTime.now();
                  final today = DateTime(now.year, now.month, now.day);
                  final date = await showDatePicker(
                    context: context,
                    initialDate:
                        _selectedDate.isAfter(today) ? today : _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: today,
                  );
                  if (date != null) {
                    setState(() => _selectedDate = date);
                    widget.onDateChanged(date);
                  }
                },
                child: InputDecorator(
                  decoration: inputDecoration.copyWith(
                    labelText: loc.date,
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    DateFormat.yMMMd(loc.locale.languageCode)
                        .format(_selectedDate),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Remarks
              TextField(
                controller: widget.remarksController,
                decoration: inputDecoration.copyWith(
                  labelText: loc.remarksOptional,
                  prefixIcon: const Icon(Icons.note),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(loc.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            final amountText = widget.amountController.text.trim();
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
            Navigator.of(context).pop({
              'invoice_id': _selectedInvoiceId,
            });
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(loc.record),
        ),
      ],
    );
  }
}
