import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/di/injection.dart';
import '../../../data/repositories/customer_repository.dart';
import '../../../shared/models/customer_model.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/modern_components.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/gradient_pill_button.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';
import '../bloc/customer_state.dart';
import 'add_customer_screen.dart';
import 'customer_ledger_screen.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final Map<String, double> _computedBalances = {};
  final Set<String> _loadingBalances = {};
  bool _balancePrefetchScheduled = false;

  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>().add(const LoadCustomersEvent(isActive: true));
  }

  @override
  void dispose() {
    _computedBalances.clear();
    _loadingBalances.clear();
    super.dispose();
  }

  void _scheduleBalancePrefetch(List<CustomerModel> customers) {
    if (_balancePrefetchScheduled) return;
    _balancePrefetchScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _balancePrefetchScheduled = false;
      _prefetchBalances(customers);
    });
  }

  Future<void> _prefetchBalances(List<CustomerModel> customers) async {
    final repo = getIt<CustomerRepository>();
    for (final customer in customers) {
      if (_computedBalances.containsKey(customer.id) ||
          _loadingBalances.contains(customer.id)) {
        continue;
      }
      final backendBalance = _parseBalanceOrNull(customer.balance);
      if (backendBalance != null && backendBalance != 0) {
        continue;
      }
      _loadingBalances.add(customer.id);
      final result = await repo.getTransactions(customer.id);
      if (!mounted) return;
      _loadingBalances.remove(customer.id);
      if (result.isSuccess) {
        final balance = _calculateBalance(result.dataOrNull ?? []);
        setState(() {
          _computedBalances[customer.id] = balance;
        });
      }
    }
  }

  double _calculateBalance(List<Map<String, dynamic>> transactions) {
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
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade400, Colors.purple.shade600],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.people,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(loc.customers),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () {
              setState(() {
                _computedBalances.clear();
                _loadingBalances.clear();
              });
              context
                  .read<CustomerBloc>()
                  .add(const LoadCustomersEvent(refresh: true, isActive: true));
            },
          ),
        ],
      ),
      body: BlocBuilder<CustomerBloc, CustomerState>(
        builder: (context, state) {
          if (state is CustomerLoading &&
              (_computedBalances.isNotEmpty || _loadingBalances.isNotEmpty)) {
            _computedBalances.clear();
            _loadingBalances.clear();
          }
          return LoadingOverlay(
            isLoading: state is CustomerLoading,
            child: Column(
              children: [
                Expanded(
                  child: _buildCustomersList(state),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: Builder(
                      builder: (context) {
                        final customerBloc = context.read<CustomerBloc>();
                        return GradientPillButton(
                          label: loc.addCustomer,
                          trailingIcon: Icons.person_add,
                          onPressed: () {
                            Navigator.of(context)
                                .push<bool>(
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: customerBloc,
                                  child: const AddCustomerScreen(),
                                ),
                              ),
                            )
                                .then((created) {
                              if (created == true && mounted) {
                                customerBloc.add(
                                  const LoadCustomersEvent(
                                      refresh: true, isActive: true),
                                );
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCustomersList(CustomerState state) {
    final loc = AppLocalizations.of(context)!;
    if (state is CustomersLoaded) {
      _scheduleBalancePrefetch(state.customers);
      if (state.customers.isEmpty) {
        return EmptyState(
          icon: Icons.people,
          title: loc.noCustomers,
          message: loc.addFirstCustomer,
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: state.customers.length,
        itemBuilder: (context, index) {
          final customer = state.customers[index];
          final balance = _computedBalances[customer.id] ??
              _parseBalanceOrNull(customer.balance);
          return _CustomerCard(
            customer: customer,
            computedBalance: balance,
          );
        },
      );
    }

    if (state is CustomerError) {
      return AppErrorWidget(
        message: state.message,
        onRetry: () {
          context
              .read<CustomerBloc>()
              .add(const LoadCustomersEvent(isActive: true));
        },
      );
    }

    return const Center(child: CircularProgressIndicator());
  }
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({
    required this.customer,
    required this.computedBalance,
  });

  final CustomerModel customer;
  final double? computedBalance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final balance = computedBalance ??
        (customer.balance != null ? double.parse(customer.balance!) : 0.0);
    final loc = AppLocalizations.of(context)!;

    final customerBloc = context.read<CustomerBloc>();
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: customerBloc,
              child: CustomerLedgerScreen(customer: customer),
            ),
          ),
        );
      },
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.person,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (customer.phone != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    customer.phone!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                loc.balance,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                CurrencyUtils.formatCurrency(balance),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: balance > 0 ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
