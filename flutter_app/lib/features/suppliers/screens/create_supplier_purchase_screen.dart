import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/currency_utils.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../../core/di/injection.dart';
import '../../../data/repositories/supplier_repository.dart';
import '../../../data/repositories/stock_repository.dart';
import '../../../shared/models/supplier_model.dart';
import '../../../shared/models/stock_item_model.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/utils/validators.dart' show ReactiveValidators;
import '../../../core/localization/app_localizations.dart';

class CreateSupplierPurchaseScreen extends StatefulWidget {
  const CreateSupplierPurchaseScreen({
    super.key,
    required this.supplier,
  });

  final SupplierModel supplier;

  @override
  State<CreateSupplierPurchaseScreen> createState() =>
      _CreateSupplierPurchaseScreenState();
}

class _CreateSupplierPurchaseScreenState
    extends State<CreateSupplierPurchaseScreen> {
  String? _lastLocaleCode;
  final FormGroup _form = FormGroup({
    'amount': FormControl<String>(
      validators: [Validators.required, ReactiveValidators.amount()],
    ),
    'date': FormControl<DateTime>(
      value: DateTime.now(),
      validators: [Validators.required],
    ),
    'remarks': FormControl<String>(),
  });

  final List<Map<String, dynamic>> _items = [];
  bool _isLoading = false;
  final SupplierRepository _supplierRepository = getIt<SupplierRepository>();
  final StockRepository _stockRepository = getIt<StockRepository>();
  List<StockItemModel>? _availableStockItems;

  @override
  void initState() {
    super.initState();
    _loadStockItems();
  }

  Future<void> _loadStockItems() async {
    final result = await _stockRepository.getItems(isActive: true);
    if (mounted && result.isSuccess) {
      setState(() {
        _availableStockItems = result.dataOrNull;
      });
    }
  }

  void _addItem() {
    showDialog(
      context: context,
      builder: (context) => _AddItemDialog(
        stockItems: _availableStockItems,
        onAdd: (item) {
          setState(() {
            _items.add(item);
          });
        },
      ),
    );
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  Future<void> _handleSubmit() async {
    final loc = AppLocalizations.of(context)!;
    // Validate form
    if (!_form.valid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.pleaseFillRequiredFields),
          backgroundColor: Colors.orange,
        ),
      );
      _form.markAllAsTouched();
      return;
    }

    setState(() => _isLoading = true);

    final result = await _supplierRepository.recordPurchase(
      supplierId: widget.supplier.id,
      amount: _form.control('amount').value as String,
      date: _form.control('date').value as DateTime,
      items: _items.isNotEmpty ? _items : null,
      remarks: _form.control('remarks').value as String?,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.purchaseRecordedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.failureOrNull?.message ?? loc.failedToRecordPurchase,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  double _calculateTotal() {
    if (_items.isEmpty) {
      return double.tryParse(_form.control('amount').value as String? ?? '0') ??
          0;
    }
    return _items.fold<double>(
      0,
      (sum, item) {
        final quantity = double.tryParse(item['quantity'] ?? '1') ?? 1;
        final unitPrice = double.tryParse(item['unit_price'] ?? '0') ?? 0;
        return sum + (quantity * unitPrice);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final localeCode = loc.locale.languageCode;
    if (_lastLocaleCode != localeCode) {
      _form.control('amount').setValidators([
        Validators.required,
        ReactiveValidators.amount(loc.purchaseAmount, loc),
      ]);
      _form.control('amount').updateValueAndValidity();
      _lastLocaleCode = localeCode;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.recordPurchaseFor.replaceAll('{supplier}', widget.supplier.name),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ReactiveForm(
          formGroup: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Amount
              ReactiveTextField(
                formControlName: 'amount',
                decoration: InputDecoration(
                  labelText: loc.purchaseAmount,
                  hintText: '0.00',
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
                  errorText: _form.control('amount').hasErrors
                      ? loc.invalidAmount
                      : null,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              // Date
              Builder(
                builder: (context) {
                  final dateControl =
                      _form.control('date') as FormControl<DateTime>;
                  final dateValue = dateControl.value ?? DateTime.now();
                  final now = DateTime.now();
                  final today = DateTime(now.year, now.month, now.day);
                  return InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate:
                            dateValue.isAfter(today) ? today : dateValue,
                        firstDate: DateTime(2020),
                        lastDate: today,
                      );
                      if (date != null) {
                        dateControl.value = date;
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: loc.date,
                        prefixIcon: const Icon(Icons.calendar_today),
                        suffixIcon: const Icon(Icons.arrow_drop_down),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceVariant
                            .withValues(alpha: 0.3),
                      ),
                      child: Text(
                        DateFormat.yMMMd(loc.locale.languageCode)
                            .format(dateValue),
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              // Remarks
              ReactiveTextField(
                formControlName: 'remarks',
                decoration: InputDecoration(
                  labelText: loc.remarksOptional,
                  hintText: loc.additionalNotes,
                  prefixIcon: const Icon(Icons.note),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              // Items Section (Optional)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loc.itemsOptional,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppButton(
                    onPressed: _addItem,
                    label: loc.addItem,
                    icon: Icons.add,
                    variant: AppButtonVariant.outline,
                    size: AppButtonSize.small,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_items.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.outline),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      loc.noItemsAddedForPurchase,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                ..._items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(item['item_name'] ?? ''),
                      subtitle: Text(
                        '${loc.quantity}: ${item['quantity'] ?? '1'} × ${CurrencyUtils.formatCurrency(double.tryParse(item['unit_price'] ?? '0') ?? 0)}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeItem(index),
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 24),
              // Total
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      loc.total,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      CurrencyUtils.formatCurrency(_calculateTotal()),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                onPressed: _isLoading ? null : _handleSubmit,
                label: loc.recordPurchase,
                icon: Icons.check,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddItemDialog extends StatefulWidget {
  const _AddItemDialog({
    required this.stockItems,
    required this.onAdd,
  });

  final List<StockItemModel>? stockItems;
  final Function(Map<String, dynamic>) onAdd;

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  String? _lastLocaleCode;
  final FormGroup _form = FormGroup({
    'itemName': FormControl<String>(
      validators: [Validators.required],
    ),
    'quantity': FormControl<String>(
      value: '1',
      validators: [Validators.required, ReactiveValidators.quantity()],
    ),
    'unitPrice': FormControl<String>(
      validators: [
        Validators.required,
        ReactiveValidators.amount('Unit price')
      ],
    ),
    'itemId': FormControl<String>(),
  });

  StockItemModel? _selectedStockItem;

  void _onStockItemSelected(StockItemModel? item) {
    setState(() {
      _selectedStockItem = item;
      if (item != null) {
        _form.control('itemName').value = item.name;
        _form.control('unitPrice').value = item.purchasePrice;
        _form.control('itemId').value = item.id;
      } else {
        _form.control('itemName').value = null;
        _form.control('unitPrice').value = null;
        _form.control('itemId').value = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final localeCode = loc.locale.languageCode;
    if (_lastLocaleCode != localeCode) {
      _form.control('quantity').setValidators([
        Validators.required,
        ReactiveValidators.quantity(loc.quantity, loc),
      ]);
      _form.control('unitPrice').setValidators([
        Validators.required,
        ReactiveValidators.amount(loc.unitPrice, loc),
      ]);
      _form.control('quantity').updateValueAndValidity();
      _form.control('unitPrice').updateValueAndValidity();
      _lastLocaleCode = localeCode;
    }
    return AlertDialog(
      title: Text(loc.addItem),
      content: SingleChildScrollView(
        child: ReactiveForm(
          formGroup: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Stock Item Selection
              if (widget.stockItems != null &&
                  widget.stockItems!.isNotEmpty) ...[
                DropdownButtonFormField<StockItemModel>(
                  decoration: InputDecoration(
                    labelText: loc.selectFromStockOptional,
                    hintText: loc.orEnterManuallyBelow,
                    prefixIcon: const Icon(Icons.inventory_2),
                  ),
                  items: [
                    DropdownMenuItem<StockItemModel>(
                      value: null,
                      child: Text(loc.enterManually),
                    ),
                    ...widget.stockItems!.map((item) {
                      return DropdownMenuItem<StockItemModel>(
                        value: item,
                        child: Text(item.name),
                      );
                    }),
                  ],
                  onChanged: _onStockItemSelected,
                ),
                const SizedBox(height: 16),
              ],
              // Item Name
              ReactiveTextField(
                formControlName: 'itemName',
                decoration: InputDecoration(
                  labelText: loc.itemName,
                  hintText: loc.enterItemName,
                  errorText: _form.control('itemName').hasErrors
                      ? loc.itemNameRequired
                      : null,
                ),
                textCapitalization: TextCapitalization.words,
                readOnly: _selectedStockItem != null,
              ),
              const SizedBox(height: 16),
              // Quantity and Unit Price
              Row(
                children: [
                  Expanded(
                    child: ReactiveTextField(
                      formControlName: 'quantity',
                      decoration: InputDecoration(
                        labelText: loc.quantity,
                        hintText: '1',
                        errorText: _form.control('quantity').hasErrors
                            ? loc.validQuantityRequired
                            : null,
                        suffixText: _selectedStockItem?.unit,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ReactiveTextField(
                      formControlName: 'unitPrice',
                      decoration: InputDecoration(
                        labelText: loc.unitPrice,
                        hintText: '0.00',
                        errorText: _form.control('unitPrice').hasErrors
                            ? loc.validPriceRequired
                            : null,
                      ),
                      keyboardType: TextInputType.number,
                      readOnly: _selectedStockItem != null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(loc.cancel),
        ),
        AppButton(
          onPressed: () {
            if (_form.valid) {
              widget.onAdd({
                'item_name': _form.control('itemName').value as String,
                'quantity': _form.control('quantity').value as String,
                'unit_price': _form.control('unitPrice').value as String,
                if (_selectedStockItem != null)
                  'item_id': _selectedStockItem!.id,
              });
              Navigator.of(context).pop();
            } else {
              _form.markAllAsTouched();
            }
          },
          label: loc.add,
          size: AppButtonSize.small,
        ),
      ],
    );
  }
}
