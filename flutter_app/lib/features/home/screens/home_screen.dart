import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/constants/storage_constants.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../data/repositories/bank_repository.dart';
import '../../../data/repositories/customer_repository.dart';
import '../../../data/repositories/supplier_repository.dart';
import '../../../shared/models/bank_account_model.dart';
import '../../../shared/models/customer_model.dart';
import '../../../shared/models/supplier_model.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/business_switcher.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/modern_components.dart';
import '../../banks/bloc/bank_bloc.dart';
import '../../banks/bloc/bank_event.dart';
import '../../banks/bloc/bank_state.dart';
import '../../customers/bloc/customer_bloc.dart';
import '../../customers/bloc/customer_event.dart';
import '../../customers/bloc/customer_state.dart';
import '../../customers/screens/customer_ledger_screen.dart';
import '../../customers/screens/add_customer_screen.dart';
import '../../suppliers/bloc/supplier_bloc.dart';
import '../../suppliers/bloc/supplier_event.dart';
import '../../suppliers/bloc/supplier_state.dart';
import '../../suppliers/screens/supplier_ledger_screen.dart';
import '../../suppliers/screens/add_supplier_screen.dart';
import '../../more/screens/more_screen.dart';
import '../../banks/screens/add_bank_account_screen.dart';

double? _parseBalanceOrNull(String? value) {
  if (value == null) return null;
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;
  return double.tryParse(trimmed);
}

double _resolveBalance(String? backendValue, double? computed) {
  final backendBalance = _parseBalanceOrNull(backendValue);
  if (backendBalance != null && backendBalance != 0) {
    return backendBalance;
  }
  return computed ?? 0.0;
}

String _maskCurrency() {
  return '${CurrencyUtils.getCurrentCurrency().symbol} ****';
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTab = 0;
  final Map<String, double> _customerBalances = {};
  final Map<String, double> _supplierBalances = {};
  final Set<String> _loadingCustomerBalances = {};
  final Set<String> _loadingSupplierBalances = {};
  bool _customerBalancePrefetchScheduled = false;
  bool _supplierBalancePrefetchScheduled = false;
  bool _hideBalances = false;
  late final LocalStorageService _localStorage;

  @override
  void initState() {
    super.initState();
    _localStorage = getIt<LocalStorageService>();
    _loadHideBalances();
    // Initialize TabController with 3 tabs (Customers, Suppliers, Banks)
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    _tabController.addListener(() {
      if (!mounted) return;
      if (_tabController.indexIsChanging) return;
      setState(() {
        _currentTab = _tabController.index;
        // Ensure _currentTab is within valid range
        if (_currentTab < 0 || _currentTab >= 3) {
          _currentTab = 0;
        }
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _scheduleCustomerBalancePrefetch(List<CustomerModel> customers) {
    if (_customerBalancePrefetchScheduled) return;
    _customerBalancePrefetchScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _customerBalancePrefetchScheduled = false;
      _prefetchCustomerBalances(customers);
    });
  }

  void _scheduleSupplierBalancePrefetch(List<SupplierModel> suppliers) {
    if (_supplierBalancePrefetchScheduled) return;
    _supplierBalancePrefetchScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _supplierBalancePrefetchScheduled = false;
      _prefetchSupplierBalances(suppliers);
    });
  }

  Future<void> _prefetchCustomerBalances(List<CustomerModel> customers) async {
    final repo = getIt<CustomerRepository>();
    for (final customer in customers) {
      if (_customerBalances.containsKey(customer.id) ||
          _loadingCustomerBalances.contains(customer.id)) {
        continue;
      }
      final backendBalance = _parseBalanceOrNull(customer.balance);
      if (backendBalance != null && backendBalance != 0) {
        continue;
      }
      _loadingCustomerBalances.add(customer.id);
      final result = await repo.getTransactions(customer.id);
      if (!mounted) return;
      _loadingCustomerBalances.remove(customer.id);
      if (result.isSuccess) {
        final balance = _calculateCustomerBalance(result.dataOrNull ?? []);
        if (!mounted) return;
        setState(() {
          _customerBalances[customer.id] = balance;
        });
      }
    }
  }

  Future<void> _prefetchSupplierBalances(List<SupplierModel> suppliers) async {
    final repo = getIt<SupplierRepository>();
    for (final supplier in suppliers) {
      if (_supplierBalances.containsKey(supplier.id) ||
          _loadingSupplierBalances.contains(supplier.id)) {
        continue;
      }
      final backendBalance = _parseBalanceOrNull(supplier.balance);
      if (backendBalance != null && backendBalance != 0) {
        continue;
      }
      _loadingSupplierBalances.add(supplier.id);
      final result = await repo.getTransactions(supplier.id);
      if (!mounted) return;
      _loadingSupplierBalances.remove(supplier.id);
      if (result.isSuccess) {
        final balance = _calculateSupplierBalance(result.dataOrNull ?? []);
        if (!mounted) return;
        setState(() {
          _supplierBalances[supplier.id] = balance;
        });
      }
    }
  }

  double _calculateCustomerBalance(List<Map<String, dynamic>> transactions) {
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

  double _calculateSupplierBalance(List<Map<String, dynamic>> transactions) {
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

  void _loadHideBalances() {
    final stored = _localStorage.getBool(StorageConstants.hideBalances);
    if (stored != null && stored != _hideBalances) {
      setState(() {
        _hideBalances = stored;
      });
    }
  }

  Future<void> _toggleHideBalances() async {
    final next = !_hideBalances;
    setState(() {
      _hideBalances = next;
    });
    await _localStorage.saveBool(StorageConstants.hideBalances, next);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return MultiBlocProvider(
      providers: [
        BlocProvider<CustomerBloc>(
          create: (_) => CustomerBloc(
            customerRepository: getIt<CustomerRepository>(),
          )..add(const LoadCustomersEvent(isActive: true)),
        ),
        BlocProvider<SupplierBloc>(
          create: (_) => SupplierBloc(
            supplierRepository: getIt<SupplierRepository>(),
          )..add(const LoadSuppliersEvent(isActive: true)),
        ),
        BlocProvider<BankBloc>(
          create: (_) => BankBloc(
            bankRepository: getIt<BankRepository>(),
          )..add(const LoadBankAccountsEvent()),
        ),
      ],
      child: Builder(
        builder: (scaffoldContext) {
          return MultiBlocListener(
            listeners: [
              BlocListener<CustomerBloc, CustomerState>(
                listener: (context, state) {
                  if (state is CustomerLoading) {
                    _customerBalances.clear();
                    _loadingCustomerBalances.clear();
                  }
                  if (state is CustomersLoaded) {
                    _scheduleCustomerBalancePrefetch(state.customers);
                  }
                },
              ),
              BlocListener<SupplierBloc, SupplierState>(
                listener: (context, state) {
                  if (state is SupplierLoading) {
                    _supplierBalances.clear();
                    _loadingSupplierBalances.clear();
                  }
                  if (state is SuppliersLoaded) {
                    _scheduleSupplierBalancePrefetch(state.suppliers);
                  }
                },
              ),
            ],
            child: Scaffold(
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(106),
                child: Container(
                  decoration:
                      const BoxDecoration(gradient: AppTheme.primaryGradient),
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: _openSideMenu,
                                icon:
                                    const Icon(Icons.menu, color: Colors.white),
                              ),
                              const SizedBox(width: 4),
                              const Expanded(child: BusinessSwitcher()),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () => Navigator.of(context)
                                    .pushNamed(AppRouter.settings),
                                icon: const Icon(Icons.settings,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        TabBar(
                          controller: _tabController,
                          indicatorColor: Colors.white,
                          indicatorWeight: 3,
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.white70,
                          tabs: [
                            Tab(text: loc.customers),
                            Tab(text: loc.suppliers),
                            Tab(text: loc.banks),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.endFloat,
              floatingActionButton: _buildAddAction(scaffoldContext),
              body: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                    child: _BalanceSummary(
                      customerBalances: _customerBalances,
                      supplierBalances: _supplierBalances,
                      hideBalances: _hideBalances,
                      onToggleHide: _toggleHideBalances,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: _QuickActionsRow(),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _CustomersTab(
                          customerBalances: _customerBalances,
                          hideBalances: _hideBalances,
                        ),
                        _SuppliersTab(
                          supplierBalances: _supplierBalances,
                          hideBalances: _hideBalances,
                        ),
                        _BanksTab(hideBalances: _hideBalances),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddAction(BuildContext sheetContext) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    // Ensure _currentTab is within valid range (0-2)
    final tabIndex = _currentTab.clamp(0, 2);

    switch (tabIndex) {
      case 1:
        return FloatingActionButton.extended(
          heroTag: 'home_add_supplier_fab',
          onPressed: () => _openAddSupplierSheet(sheetContext),
          label: Text(loc.addSupplier),
          icon: const Icon(Icons.person_add_alt_1),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        );
      case 2:
        return FloatingActionButton.extended(
          heroTag: 'home_add_bank_fab',
          onPressed: () => _openAddBankSheet(sheetContext),
          label: Text(loc.addBank),
          icon: const Icon(Icons.account_balance),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        );
      case 0:
      default:
        return FloatingActionButton.extended(
          heroTag: 'home_add_customer_fab',
          onPressed: () => _openAddCustomerSheet(sheetContext),
          label: Text(loc.addCustomer),
          icon: const Icon(Icons.person_add),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        );
    }
  }

  void _openSideMenu() {
    showGeneralDialog(
      context: context,
      barrierLabel: 'menu',
      barrierDismissible: true,
      barrierColor: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.2),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: const MoreScreen(isSheet: true),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final offset = Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(animation);
        return SlideTransition(position: offset, child: child);
      },
    );
  }

  Future<void> _openAddCustomerSheet(BuildContext sheetContext) async {
    final result = await showModalBottomSheet<bool>(
      context: sheetContext,
      isScrollControlled: true,
      builder: (context) => BlocProvider.value(
        value: sheetContext.read<CustomerBloc>(),
        child: const AddCustomerSheet(),
      ),
    );

    if (result == true && mounted) {
      sheetContext
          .read<CustomerBloc>()
          .add(const LoadCustomersEvent(refresh: true, isActive: true));
    }
  }

  Future<void> _openAddSupplierSheet(BuildContext sheetContext) async {
    final result = await showModalBottomSheet<bool>(
      context: sheetContext,
      isScrollControlled: true,
      builder: (context) => BlocProvider.value(
        value: sheetContext.read<SupplierBloc>(),
        child: const AddSupplierSheet(),
      ),
    );

    if (result == true && mounted) {
      sheetContext
          .read<SupplierBloc>()
          .add(const LoadSuppliersEvent(refresh: true, isActive: true));
    }
  }

  Future<void> _openAddBankSheet(BuildContext sheetContext) async {
    BankBloc? bankBloc;
    try {
      bankBloc = BlocProvider.of<BankBloc>(sheetContext, listen: false);
    } catch (_) {
      bankBloc = null;
    }
    final result = await showModalBottomSheet<bool>(
      context: sheetContext,
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

    if (result == true && mounted && bankBloc != null) {
      bankBloc.add(const LoadBankAccountsEvent(refresh: true));
    }
  }
}

class _BalanceSummary extends StatelessWidget {
  const _BalanceSummary({
    required this.customerBalances,
    required this.supplierBalances,
    required this.hideBalances,
    required this.onToggleHide,
  });

  final Map<String, double> customerBalances;
  final Map<String, double> supplierBalances;
  final bool hideBalances;
  final VoidCallback onToggleHide;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return BlocBuilder<CustomerBloc, CustomerState>(
      builder: (context, customerState) {
        return BlocBuilder<SupplierBloc, SupplierState>(
          builder: (context, supplierState) {
            double willGive = 0;
            double willGet = 0;

            if (customerState is CustomersLoaded) {
              for (final customer in customerState.customers) {
                final balance = _resolveBalance(
                  customer.balance,
                  customerBalances[customer.id],
                );
                // Customers: positive means you will get, negative means you will give.
                if (balance > 0) {
                  willGet += balance;
                } else if (balance < 0) {
                  willGive += balance.abs();
                }
              }
            }
            if (supplierState is SuppliersLoaded) {
              for (final supplier in supplierState.suppliers) {
                final balance = _resolveBalance(
                  supplier.balance,
                  supplierBalances[supplier.id],
                );
                // Suppliers: positive means you will give, negative means you will get.
                if (balance > 0) {
                  willGive += balance;
                } else if (balance < 0) {
                  willGet += balance.abs();
                }
              }
            }

            return BalanceSummaryCard(
              willGive: hideBalances
                  ? _maskCurrency()
                  : CurrencyUtils.formatCurrency(willGive),
              willGet: hideBalances
                  ? _maskCurrency()
                  : CurrencyUtils.formatCurrency(willGet),
              hideBalances: hideBalances,
              onToggle: onToggleHide,
              hideLabel: loc.hideBalance,
              showLabel: loc.showBalance,
              willGiveLabel: loc.youWillGive,
              willGetLabel: loc.youWillGet,
              compact: true,
            );
          },
        );
      },
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          QuickActionButton(
            icon: Icons.account_balance_wallet,
            label: loc.cash,
            compact: true,
            onTap: () => Navigator.of(context).pushNamed(AppRouter.cash),
          ),
          const SizedBox(width: 8),
          QuickActionButton(
            icon: Icons.inventory,
            label: loc.stock,
            compact: true,
            onTap: () => Navigator.of(context).pushNamed(AppRouter.stock),
          ),
          const SizedBox(width: 8),
          QuickActionButton(
            icon: Icons.receipt_long,
            label: loc.bill,
            compact: true,
            onTap: () => Navigator.of(context).pushNamed(AppRouter.invoices),
          ),
          const SizedBox(width: 8),
          QuickActionButton(
            icon: Icons.people,
            label: loc.staff,
            compact: true,
            onTap: () => Navigator.of(context).pushNamed(AppRouter.staff),
          ),
          const SizedBox(width: 8),
          QuickActionButton(
            icon: Icons.receipt,
            label: loc.expense,
            compact: true,
            onTap: () => Navigator.of(context).pushNamed(AppRouter.expenses),
          ),
        ],
      ),
    );
  }
}

class _CustomersTab extends StatefulWidget {
  const _CustomersTab({
    required this.customerBalances,
    required this.hideBalances,
  });

  final Map<String, double> customerBalances;
  final bool hideBalances;

  @override
  State<_CustomersTab> createState() => _CustomersTabState();
}

class _CustomersTabState extends State<_CustomersTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query == _searchQuery) return;
    setState(() => _searchQuery = query);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return BlocBuilder<CustomerBloc, CustomerState>(
      builder: (context, state) {
        if (state is CustomersLoaded) {
          final normalizedQuery = _searchQuery.toLowerCase();
          final customers = normalizedQuery.isEmpty
              ? state.customers
              : state.customers
                  .where(
                    (customer) =>
                        customer.name.toLowerCase().contains(normalizedQuery),
                  )
                  .toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                child: AppCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: loc.searchCustomers,
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: customers.isEmpty
                    ? (normalizedQuery.isEmpty
                        ? _EmptyInstruction(
                            title: loc.addCustomers,
                            lines: [
                              loc.addEntriesMaintainKhata,
                              loc.sendPaymentReminders,
                            ],
                          )
                        : EmptyState(
                            icon: Icons.search_off,
                            title: loc.noCustomersFound,
                            message: loc.noResultsFound,
                          ))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 2, 12, 84),
                        itemCount: customers.length,
                        itemBuilder: (context, index) {
                          final customer = customers[index];
                          final balance = _resolveBalance(
                            customer.balance,
                            widget.customerBalances[customer.id],
                          );
                          return _LedgerRow(
                            title: customer.name,
                            subtitle: customer.phone ?? '',
                            amount: balance,
                            // Customers: positive means you will get (red), negative means you will give (green)
                            isCredit: balance < 0,
                            hideBalances: widget.hideBalances,
                            onTap: () {
                              final customerBloc = context.read<CustomerBloc>();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: customerBloc,
                                    child: CustomerLedgerScreen(
                                      customer: customer,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        }
        if (state is CustomerError) {
          return EmptyState(
            icon: Icons.error_outline,
            title: state.message,
            action: ElevatedButton.icon(
              onPressed: () {
                context
                    .read<CustomerBloc>()
                    .add(const LoadCustomersEvent(isActive: true));
              },
              icon: const Icon(Icons.refresh),
              label: Text(loc.retry),
            ),
          );
        }
        // Show empty state for initial state, loading will be handled by the BLoC
        if (state is CustomerInitial) {
          return _EmptyInstruction(
            title: loc.addCustomers,
            lines: [
              loc.addEntriesMaintainKhata,
              loc.sendPaymentReminders,
            ],
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class _SuppliersTab extends StatelessWidget {
  const _SuppliersTab({
    required this.supplierBalances,
    required this.hideBalances,
  });

  final Map<String, double> supplierBalances;
  final bool hideBalances;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return BlocBuilder<SupplierBloc, SupplierState>(
      builder: (context, state) {
        if (state is SuppliersLoaded) {
          if (state.suppliers.isEmpty) {
            return _EmptyInstruction(
              title: loc.addSuppliers,
              lines: [
                loc.addEntriesMaintainKhata,
                loc.managePurchases,
              ],
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 84),
            itemCount: state.suppliers.length,
            itemBuilder: (context, index) {
              final supplier = state.suppliers[index];
              final balance = _resolveBalance(
                  supplier.balance, supplierBalances[supplier.id]);
              return _LedgerRow(
                title: supplier.name,
                subtitle: supplier.phone ?? '',
                amount: balance,
                // Suppliers: positive means you will give (green), negative means you will get (red)
                isCredit: balance > 0,
                hideBalances: hideBalances,
                onTap: () {
                  final supplierBloc = context.read<SupplierBloc>();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: supplierBloc,
                        child: SupplierLedgerScreen(supplier: supplier),
                      ),
                    ),
                  );
                },
              );
            },
          );
        }
        if (state is SupplierError) {
          return EmptyState(
            icon: Icons.error_outline,
            title: state.message,
            action: ElevatedButton.icon(
              onPressed: () {
                context
                    .read<SupplierBloc>()
                    .add(const LoadSuppliersEvent(isActive: true));
              },
              icon: const Icon(Icons.refresh),
              label: Text(loc.retry),
            ),
          );
        }
        // Show empty state for initial state
        if (state is SupplierInitial) {
          return _EmptyInstruction(
            title: loc.addSuppliers,
            lines: [
              loc.addEntriesMaintainKhata,
              loc.managePurchases,
            ],
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class _BanksTab extends StatelessWidget {
  const _BanksTab({required this.hideBalances});

  final bool hideBalances;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return BlocBuilder<BankBloc, BankState>(
      builder: (context, state) {
        if (state is BankAccountsLoaded) {
          if (state.accounts.isEmpty) {
            return _EmptyInstruction(
              title: loc.addBanks,
              lines: [
                loc.addEntriesMaintainKhata,
                loc.manageBankBalance,
              ],
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 84),
            itemCount: state.accounts.length,
            itemBuilder: (context, index) {
              final bank = state.accounts[index];
              return _BankRow(
                bank: bank,
                hideBalances: hideBalances,
                onTap: () => Navigator.of(context).pushNamed(AppRouter.banks),
              );
            },
          );
        }
        if (state is BankError) {
          return EmptyState(
            icon: Icons.error_outline,
            title: state.message,
            action: ElevatedButton.icon(
              onPressed: () {
                context.read<BankBloc>().add(const LoadBankAccountsEvent());
              },
              icon: const Icon(Icons.refresh),
              label: Text(loc.retry),
            ),
          );
        }
        // Show empty state for initial state
        if (state is BankInitial) {
          return _EmptyInstruction(
            title: loc.addBanks,
            lines: [
              loc.addEntriesMaintainKhata,
              loc.manageBankBalance,
            ],
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class _EmptyInstruction extends StatelessWidget {
  const _EmptyInstruction({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline,
                size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ...lines.map((line) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    line,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _LedgerRow extends StatelessWidget {
  const _LedgerRow({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isCredit,
    required this.hideBalances,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final double amount;
  final bool isCredit;
  final bool hideBalances;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: isCredit
                  ? AppTheme.successColor.withValues(alpha: 0.1)
                  : AppTheme.errorColor.withValues(alpha: 0.1),
              child: Icon(
                Icons.person,
                color: isCredit ? AppTheme.successColor : AppTheme.errorColor,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              hideBalances
                  ? _maskCurrency()
                  : CurrencyUtils.formatCurrency(amount.abs()),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isCredit ? AppTheme.successColor : AppTheme.errorColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BankRow extends StatelessWidget {
  const _BankRow({
    required this.bank,
    required this.hideBalances,
    this.onTap,
  });

  final BankAccountModel bank;
  final bool hideBalances;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(
                Icons.account_balance,
                color: theme.colorScheme.primary,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                bank.bankName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              hideBalances
                  ? _maskCurrency()
                  : CurrencyUtils.formatCurrency(
                      double.tryParse(bank.currentBalance) ?? 0,
                    ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
