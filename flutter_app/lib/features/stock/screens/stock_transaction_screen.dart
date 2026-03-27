import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:intl/intl.dart';
import '../../../shared/models/stock_item_model.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/confirmation_dialog.dart';
import '../../../shared/utils/validators.dart' show ReactiveValidators;
import '../../../core/utils/currency_utils.dart';
import '../../../core/localization/app_localizations.dart';
import '../bloc/stock_bloc.dart';
import '../bloc/stock_event.dart';
import '../bloc/stock_state.dart';

class StockTransactionScreen extends StatefulWidget {
  const StockTransactionScreen({
    super.key,
    required this.item,
    required this.transactionType, // 'in' or 'out'
  });

  final StockItemModel item;
  final String transactionType;

  @override
  State<StockTransactionScreen> createState() => _StockTransactionScreenState();
}

class _StockTransactionScreenState extends State<StockTransactionScreen> {
  String? _lastLocaleCode;
  final FormGroup _form = FormGroup({
    'quantity': FormControl<String>(
      validators: [Validators.required, ReactiveValidators.quantity()],
    ),
    'unitPrice': FormControl<String>(
      value: '0',
      validators: [
        Validators.required,
        ReactiveValidators.amountAllowZero('Unit price')
      ],
    ),
    'date': FormControl<DateTime>(
      value: DateTime.now(),
      validators: [Validators.required],
    ),
    'remarks': FormControl<String>(),
  });

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Set default unit price to purchase price for stock in
    if (widget.transactionType == 'in') {
      _form.control('unitPrice').value = widget.item.purchasePrice;
    } else {
      _form.control('unitPrice').value = widget.item.salePrice;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isStockIn = widget.transactionType == 'in';
    final loc = AppLocalizations.of(context)!;
    final localeCode = loc.locale.languageCode;
    if (_lastLocaleCode != localeCode) {
      _form.control('quantity').setValidators([
        Validators.required,
        ReactiveValidators.quantity(loc.quantity, loc),
      ]);
      _form.control('unitPrice').setValidators([
        Validators.required,
        ReactiveValidators.amountAllowZero(loc.unitPrice, loc),
      ]);
      _form.control('quantity').updateValueAndValidity();
      _form.control('unitPrice').updateValueAndValidity();
      _lastLocaleCode = localeCode;
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          isStockIn ? loc.stockIn : loc.stockOut,
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE24B2D), Color(0xFFF0782A)],
            ),
          ),
        ),
      ),
      body: BlocConsumer<StockBloc, StockState>(
        listener: (context, state) {
          if (state is InventoryTransactionCreated) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isStockIn ? loc.stockInSuccess : loc.stockOutSuccess,
                ),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(true);
          } else if (state is StockError) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item Info Card
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${loc.currentStock}: ${widget.item.currentStock} ${widget.item.unit}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ReactiveForm(
                  formGroup: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReactiveTextField<String>(
                        formControlName: 'quantity',
                        decoration: InputDecoration(
                          labelText: loc.quantity,
                          hintText: loc.enterQuantity,
                          prefixIcon: const Icon(Icons.inventory),
                          suffixText: widget.item.unit,
                          errorText: _form.control('quantity').hasErrors
                              ? '${loc.quantity} ${loc.required}'
                              : null,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ReactiveTextField<String>(
                        formControlName: 'unitPrice',
                        decoration: InputDecoration(
                          labelText: loc.unitPrice,
                          hintText: loc.enterAmount,
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
                          helperText: isStockIn
                              ? loc.purchasePricePerUnit
                              : loc.salePricePerUnit,
                          errorText: _form.control('unitPrice').hasErrors
                              ? '${loc.unitPrice} ${loc.required}'
                              : null,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ReactiveDatePicker<DateTime>(
                        formControlName: 'date',
                        firstDate: DateTime(2020),
                        lastDate: DateTime(
                          DateTime.now().year,
                          DateTime.now().month,
                          DateTime.now().day,
                        ),
                        builder: (context, picker, child) {
                          return ReactiveTextField<DateTime>(
                            formControlName: 'date',
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: loc.date,
                              prefixIcon: const Icon(Icons.calendar_today),
                            ),
                            onTap: (field) {
                              picker.showPicker();
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      ReactiveTextField<String>(
                        formControlName: 'remarks',
                        decoration: InputDecoration(
                          labelText: loc.remarksOptional,
                          hintText: loc.additionalNotes,
                          prefixIcon: const Icon(Icons.note),
                          helperText: loc.additionalNotes,
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 32),
                      AppButton(
                        onPressed: _isLoading ? null : _handleSubmit,
                        isLoading: _isLoading,
                        label: isStockIn ? loc.addStock : loc.removeStock,
                        icon: isStockIn ? Icons.add : Icons.remove,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_form.valid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pleaseFillRequiredFields),
          backgroundColor: Colors.orange,
        ),
      );
      _form.markAllAsTouched();
      return;
    }

    // For stock out, check availability and show confirmation
    if (widget.transactionType == 'out') {
      final quantity =
          double.tryParse(_form.control('quantity').value as String) ?? 0;
      final currentStock = double.tryParse(widget.item.currentStock) ?? 0;

      if (quantity > currentStock) {
        final loc = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${loc.insufficientStock}: $currentStock ${widget.item.unit}',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final loc = AppLocalizations.of(context)!;
      final confirmed = await ConfirmationDialog.show(
        context: context,
        title: loc.confirmStockRemoval,
        message:
            '${loc.removeStock} $quantity ${widget.item.unit} ${loc.from} ${widget.item.name}?',
        confirmText: loc.remove,
        cancelText: loc.cancel,
        isDestructive: true,
      );

      if (confirmed != true) {
        return;
      }
    }

    setState(() => _isLoading = true);

    context.read<StockBloc>().add(
          CreateInventoryTransactionEvent(
            itemId: widget.item.id,
            transactionType:
                widget.transactionType == 'in' ? 'stock_in' : 'stock_out',
            quantity: _form.control('quantity').value as String,
            unitPrice: _form.control('unitPrice').value as String,
            date: _form.control('date').value as DateTime,
            remarks: _form.control('remarks').value as String?,
          ),
        );
  }
}
