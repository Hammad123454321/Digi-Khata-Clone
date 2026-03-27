import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/di/injection.dart';
import '../../../data/repositories/reminder_repository.dart';
import '../../../core/utils/result.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../core/localization/app_localizations.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  List<Map<String, dynamic>> _reminders = [];
  bool _isLoading = true;
  String? _error;
  String? _filterType; // 'customer', 'supplier', or null for all

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final repository = getIt<ReminderRepository>();
    final result = await repository.getReminders(entityType: _filterType);

    if (!mounted) return;

    switch (result) {
      case Success(:final data):
        setState(() {
          _reminders = data;
          _isLoading = false;
        });
      case FailureResult(:final failure):
        setState(() {
          _error = failure.message ?? 'Failed to load reminders';
          _isLoading = false;
        });
    }
  }

  Future<void> _resolveReminder(String reminderId) async {
    final repository = getIt<ReminderRepository>();
    final result = await repository.resolveReminder(reminderId);

    if (!mounted) return;

    switch (result) {
      case Success():
        final loc = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.reminderResolved),
            backgroundColor: Colors.green,
          ),
        );
        _loadReminders();
      case FailureResult(:final failure):
        final loc = AppLocalizations.of(context)!;
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

  Future<void> _sendReminderSms(String reminderId) async {
    final repository = getIt<ReminderRepository>();
    final result = await repository.sendReminderSms(reminderId);
    if (!mounted) return;
    final loc = AppLocalizations.of(context)!;
    switch (result) {
      case Success():
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reminder SMS sent'),
            backgroundColor: Colors.green,
          ),
        );
        _loadReminders();
      case FailureResult(:final failure):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message ?? loc.failedToLoadData),
            backgroundColor: Colors.red,
          ),
        );
    }
  }

  Future<void> _shareReminderOnWhatsApp(Map<String, dynamic> reminder) async {
    final phone = (reminder['entity_phone']?.toString() ?? '')
        .replaceAll(RegExp(r'[^0-9]'), '');
    if (phone.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number is missing'),
        ),
      );
      return;
    }

    final message = _buildReminderMessage(reminder);
    final uri = Uri.parse(
      'https://wa.me/$phone?text=${Uri.encodeComponent(message)}',
    );

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open WhatsApp'),
        ),
      );
    }
  }

  String _buildReminderMessage(Map<String, dynamic> reminder) {
    final entityName = reminder['entity_name']?.toString() ?? 'Customer';
    final amount = double.tryParse(reminder['amount']?.toString() ?? '0') ?? 0;
    final dueDateRaw = reminder['due_date']?.toString();
    final dueDate = dueDateRaw != null ? DateTime.tryParse(dueDateRaw) : null;
    final dueDateText =
        dueDate != null ? DateFormat('dd MMM yyyy').format(dueDate) : 'today';
    return 'Payment reminder for $entityName. Amount due: ${CurrencyUtils.formatCurrency(amount)}. Due date: $dueDateText.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final dateFormatter = DateFormat.yMMMd(loc.locale.languageCode);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.reminders),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _filterType = value == 'all' ? null : value;
              });
              _loadReminders();
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'all', child: Text(loc.all)),
              PopupMenuItem(value: 'customer', child: Text(loc.customers)),
              PopupMenuItem(value: 'supplier', child: Text(loc.suppliers)),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReminders,
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: _error != null
            ? AppErrorWidget(
                message: _error!,
                onRetry: _loadReminders,
              )
            : _reminders.isEmpty
                ? EmptyState(
                    icon: Icons.notifications_none,
                    title: loc.noReminders,
                    message: loc.allRemindersResolved,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _reminders.length,
                    itemBuilder: (context, index) {
                      final reminder = _reminders[index];
                      final isResolved = reminder['is_resolved'] == true;
                      final entityType = reminder['entity_type'] as String?;
                      final amount = double.tryParse(
                            reminder['amount']?.toString() ?? '0',
                          ) ??
                          0;
                      final dueDate = reminder['due_date'] != null
                          ? DateTime.parse(reminder['due_date'] as String)
                          : null;
                      final isOverdue = dueDate != null &&
                          dueDate.isBefore(DateTime.now()) &&
                          !isResolved;

                      return AppCard(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  entityType == 'customer'
                                      ? Icons.person
                                      : Icons.local_shipping,
                                  color: isOverdue
                                      ? Colors.red
                                      : theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        reminder['entity_name'] as String? ??
                                            loc.unknown,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        entityType == 'customer'
                                            ? loc.customerCredit
                                            : loc.supplierPayment,
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isResolved)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.green.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      loc.resolved,
                                      style:
                                          theme.textTheme.labelSmall?.copyWith(
                                        color: Colors.green,
                                      ),
                                    ),
                                  )
                                else if (isOverdue)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      loc.overdue,
                                      style:
                                          theme.textTheme.labelSmall?.copyWith(
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      loc.amount,
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    Text(
                                      CurrencyUtils.formatCurrency(amount),
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isOverdue ? Colors.red : null,
                                      ),
                                    ),
                                  ],
                                ),
                                if (dueDate != null)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        loc.dueDate,
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      Text(
                                        dateFormatter.format(dueDate),
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                          color: isOverdue ? Colors.red : null,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            if (reminder['message'] != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                reminder['message'] as String,
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                            if (!isResolved) ...[
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    tooltip: 'Send SMS',
                                    onPressed: () => _sendReminderSms(
                                      reminder['id'].toString(),
                                    ),
                                    icon: const Icon(Icons.sms_outlined),
                                  ),
                                  IconButton(
                                    tooltip: 'WhatsApp',
                                    onPressed: () =>
                                        _shareReminderOnWhatsApp(reminder),
                                    icon: const Icon(Icons.chat_outlined),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => _resolveReminder(
                                      reminder['id'].toString(),
                                    ),
                                    icon: const Icon(Icons.check, size: 18),
                                    label: Text(loc.markResolved),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
