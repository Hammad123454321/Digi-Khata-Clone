import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../shared/models/bank_account_model.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/modern_components.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../data/repositories/bank_repository.dart';
import '../bloc/bank_bloc.dart';
import '../bloc/bank_event.dart';
import '../bloc/bank_state.dart';
import 'add_bank_account_screen.dart';

class BanksScreen extends StatefulWidget {
  const BanksScreen({super.key});

  @override
  State<BanksScreen> createState() => _BanksScreenState();
}

class _BanksScreenState extends State<BanksScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  List<BankAccountModel> _cachedAccounts = [];

  BankBloc? _maybeBankBloc(BuildContext context) {
    try {
      return BlocProvider.of<BankBloc>(context, listen: false);
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applyFilters);
    context.read<BankBloc>().add(const LoadBankAccountsEvent());
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

  List<BankAccountModel> _filterAccounts(List<BankAccountModel> accounts) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return accounts;

    return accounts.where((account) {
      final bankName = account.bankName.toLowerCase();
      final number = account.accountNumber.toLowerCase();
      final holder = account.accountHolderName?.toLowerCase() ?? '';
      return bankName.contains(query) ||
          number.contains(query) ||
          holder.contains(query);
    }).toList();
  }

  Future<void> _openAddAccount() async {
    final bankBloc = _maybeBankBloc(context);
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => bankBloc != null
          ? BlocProvider.value(
              value: bankBloc,
              child: const AddBankAccountSheet(),
            )
          : BlocProvider(
              create: (_) => BankBloc(
                bankRepository: getIt<BankRepository>(),
              ),
              child: const AddBankAccountSheet(),
            ),
    );

    if (result == true && mounted) {
      context.read<BankBloc>().add(const LoadBankAccountsEvent(refresh: true));
    }
  }

  Future<void> _openTransferSheet({BankAccountModel? account}) async {
    if (_cachedAccounts.isEmpty) {
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.noBankAccounts),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final bankBloc = _maybeBankBloc(context);
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => bankBloc != null
          ? BlocProvider.value(
              value: bankBloc,
              child: _TransferSheet(
                accounts: _cachedAccounts,
                initialAccount: account,
              ),
            )
          : BlocProvider(
              create: (_) => BankBloc(
                bankRepository: getIt<BankRepository>(),
              ),
              child: _TransferSheet(
                accounts: _cachedAccounts,
                initialAccount: account,
              ),
            ),
    );

    if (result == true && mounted) {
      context.read<BankBloc>().add(const LoadBankAccountsEvent(refresh: true));
    }
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
              loc.banks,
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
      body: BlocConsumer<BankBloc, BankState>(
        listener: (context, state) {
          if (state is BankAccountCreated) {
            context
                .read<BankBloc>()
                .add(const LoadBankAccountsEvent(refresh: true));
          } else if (state is CashBankTransferCompleted) {
            final loc = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(loc.transferCompleted),
                backgroundColor: Colors.green,
              ),
            );
            context
                .read<BankBloc>()
                .add(const LoadBankAccountsEvent(refresh: true));
          } else if (state is BankError && _cachedAccounts.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is BankAccountsLoaded) {
            _cachedAccounts = state.accounts;
          }

          final isLoading = state is BankLoading && _cachedAccounts.isEmpty;

          if (state is BankError && _cachedAccounts.isEmpty) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () =>
                  context.read<BankBloc>().add(const LoadBankAccountsEvent()),
            );
          }

          return LoadingOverlay(
            isLoading: isLoading,
            child: _buildBankContent(theme),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ElevatedButton(
            onPressed: _openAddAccount,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: Text(loc.addBankAccount),
          ),
        ),
      ),
    );
  }

  Widget _buildBankContent(ThemeData theme) {
    final loc = AppLocalizations.of(context)!;
    final filteredAccounts = _filterAccounts(_cachedAccounts);
    final totalBalance = filteredAccounts.fold<double>(
      0,
      (sum, account) => sum + (double.tryParse(account.currentBalance) ?? 0),
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
                  CurrencyUtils.formatCurrency(totalBalance),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  loc.totalBankBalance,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _BankMiniStat(
                        label: loc.bankAccounts,
                        value: filteredAccounts.length.toString(),
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _BankMiniStat(
                        label: loc.balance,
                        value: CurrencyUtils.formatCurrency(totalBalance),
                        color: AppTheme.successColor,
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
                  icon: Icons.account_balance,
                  label: loc.addBankAccount,
                  onTap: _openAddAccount,
                ),
                const SizedBox(width: 12),
                QuickActionButton(
                  icon: Icons.swap_horiz,
                  label: loc.transfer,
                  onTap: () => _openTransferSheet(),
                ),
                const SizedBox(width: 12),
                QuickActionButton(
                  icon: Icons.refresh,
                  label: loc.refresh,
                  onTap: () => context
                      .read<BankBloc>()
                      .add(const LoadBankAccountsEvent(refresh: true)),
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
                  loc.bankAccounts,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  loc.balance,
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
          child: _cachedAccounts.isEmpty
              ? Center(
                  child: EmptyState(
                    icon: Icons.account_balance,
                    title: loc.noBankAccounts,
                    message: loc.addFirstBankAccount,
                  ),
                )
              : filteredAccounts.isEmpty
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
                      itemCount: filteredAccounts.length,
                      itemBuilder: (context, index) {
                        final account = filteredAccounts[index];
                        final balance = CurrencyUtils.formatCurrency(
                          double.tryParse(account.currentBalance) ?? 0,
                        );
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
                                              account.bankName,
                                              style: theme.textTheme.titleSmall
                                                  ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          PopupMenuButton<String>(
                                            onSelected: (value) {
                                              if (value == 'transfer') {
                                                _openTransferSheet(
                                                    account: account);
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              PopupMenuItem(
                                                value: 'transfer',
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.swap_horiz,
                                                        size: 20),
                                                    const SizedBox(width: 8),
                                                    Text(loc.transfer),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      if (account.accountHolderName != null &&
                                          account.accountHolderName!
                                              .isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          account.accountHolderName!,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: theme
                                                .colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                              _BankAmountCell(
                                amount: balance,
                                highlight: true,
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

class _BankMiniStat extends StatelessWidget {
  const _BankMiniStat({
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

class _BankAmountCell extends StatelessWidget {
  const _BankAmountCell({
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

class _TransferSheet extends StatefulWidget {
  const _TransferSheet({
    required this.accounts,
    this.initialAccount,
  });

  final List<BankAccountModel> accounts;
  final BankAccountModel? initialAccount;

  @override
  State<_TransferSheet> createState() => _TransferSheetState();
}

class _TransferSheetState extends State<_TransferSheet> {
  late BankAccountModel _selectedAccount;
  String _transferType = 'cash_to_bank';
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedAccount = widget.initialAccount ?? widget.accounts.first;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final loc = AppLocalizations.of(context)!;
    final amountText = _amountController.text.trim();
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

    setState(() => _isSubmitting = true);

    context.read<BankBloc>().add(
          CashBankTransferEvent(
            accountId: _selectedAccount.id,
            transferType: _transferType,
            amount: amountText,
            date: _selectedDate,
            remarks: _remarksController.text.trim().isEmpty
                ? null
                : _remarksController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return BlocListener<BankBloc, BankState>(
      listener: (context, state) {
        if (state is CashBankTransferCompleted) {
          setState(() => _isSubmitting = false);
          Navigator.of(context).pop(true);
        } else if (state is BankError) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      },
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      loc.transfer,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<BankAccountModel>(
                value: _selectedAccount,
                decoration: InputDecoration(
                  labelText: loc.selectBankAccount,
                  prefixIcon: const Icon(Icons.account_balance),
                ),
                items: widget.accounts
                    .map(
                      (account) => DropdownMenuItem(
                        value: account,
                        child: Text(account.bankName),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedAccount = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                    value: 'cash_to_bank',
                    label: Text(loc.cashToBank),
                    icon: const Icon(Icons.arrow_downward),
                  ),
                  ButtonSegment(
                    value: 'bank_to_cash',
                    label: Text(loc.bankToCash),
                    icon: const Icon(Icons.arrow_upward),
                  ),
                ],
                selected: {_transferType},
                onSelectionChanged: (Set<String> value) {
                  setState(() => _transferType = value.first);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountController,
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
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _selectedDate = date);
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: loc.date,
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    DateFormat.yMMMd(loc.locale.languageCode)
                        .format(_selectedDate),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _remarksController,
                decoration: InputDecoration(
                  labelText: loc.remarksOptional,
                  prefixIcon: const Icon(Icons.note),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              AppButton(
                onPressed: _isSubmitting ? null : _submit,
                label: loc.save,
                icon: Icons.check,
                isFullWidth: true,
                isLoading: _isSubmitting,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
