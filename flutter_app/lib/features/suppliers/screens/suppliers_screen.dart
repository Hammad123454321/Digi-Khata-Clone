import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../shared/models/supplier_model.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/gradient_pill_button.dart';
import '../../../core/localization/app_localizations.dart';
import '../bloc/supplier_bloc.dart';
import '../bloc/supplier_event.dart';
import '../bloc/supplier_state.dart';
import 'add_supplier_screen.dart';
import 'supplier_ledger_screen.dart';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SupplierBloc>().add(const LoadSuppliersEvent(isActive: true));
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.suppliers),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context
                  .read<SupplierBloc>()
                  .add(const LoadSuppliersEvent(refresh: true, isActive: true));
            },
          ),
        ],
      ),
      body: BlocBuilder<SupplierBloc, SupplierState>(
        builder: (context, state) {
          return LoadingOverlay(
            isLoading: state is SupplierLoading,
            child: Column(
              children: [
                Expanded(
                  child: _buildSuppliersList(state),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: Builder(
                      builder: (context) {
                        final supplierBloc = context.read<SupplierBloc>();
                        return GradientPillButton(
                          label: loc.addSupplier,
                          trailingIcon: Icons.person_add_alt_1,
                          onPressed: () {
                            Navigator.of(context)
                                .push<bool>(
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: supplierBloc,
                                  child: const AddSupplierScreen(),
                                ),
                              ),
                            )
                                .then((created) {
                              if (created == true && mounted) {
                                supplierBloc.add(
                                  const LoadSuppliersEvent(
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

  Widget _buildSuppliersList(SupplierState state) {
    final loc = AppLocalizations.of(context)!;
    if (state is SuppliersLoaded) {
      if (state.suppliers.isEmpty) {
        return EmptyState(
          icon: Icons.local_shipping,
          title: loc.noSuppliers,
          message: loc.addFirstSupplier,
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.suppliers.length,
        itemBuilder: (context, index) {
          final supplier = state.suppliers[index];
          return _SupplierCard(supplier: supplier);
        },
      );
    }

    if (state is SupplierError) {
      return AppErrorWidget(
        message: state.message,
        onRetry: () {
          context
              .read<SupplierBloc>()
              .add(const LoadSuppliersEvent(isActive: true));
        },
      );
    }

    return const Center(child: CircularProgressIndicator());
  }
}

class _SupplierCard extends StatelessWidget {
  const _SupplierCard({required this.supplier});

  final SupplierModel supplier;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final balance =
        supplier.balance != null ? double.parse(supplier.balance!) : 0.0;
    final loc = AppLocalizations.of(context)!;

    final supplierBloc = context.read<SupplierBloc>();
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: supplierBloc,
              child: SupplierLedgerScreen(supplier: supplier),
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
              color:
                  theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.local_shipping,
              color: theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  supplier.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (supplier.phone != null && supplier.phone!.length <= 20) ...[
                  const SizedBox(height: 4),
                  Text(
                    supplier.phone!,
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
                  color: balance > 0 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
