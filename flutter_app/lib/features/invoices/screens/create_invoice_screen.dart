import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/currency_utils.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../../core/di/injection.dart';
import '../../../data/repositories/stock_repository.dart';
import '../../../data/repositories/customer_repository.dart';
import '../../../data/repositories/invoice_repository.dart';
import '../../../shared/models/stock_item_model.dart';
import '../../../shared/models/customer_model.dart';
import '../../../shared/models/invoice_model.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/confirmation_dialog.dart';
import '../../../shared/utils/validators.dart' show ReactiveValidators;
import '../../../core/localization/app_localizations.dart';
import '../bloc/invoice_bloc.dart';
import '../bloc/invoice_event.dart';
import '../bloc/invoice_state.dart';

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({
    super.key,
    this.initialCustomer,
    this.initialCustomerId,
    this.defaultInvoiceType,
    this.existingInvoice,
  });

  final CustomerModel? initialCustomer;
  final String? initialCustomerId;
  final String? defaultInvoiceType;
  final InvoiceModel? existingInvoice;

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  String? _lastLocaleCode;
  final FormGroup _form = FormGroup({
    'customerId': FormControl<String>(
      validators: [Validators.required],
    ),
    'invoiceType': FormControl<String>(
      value: 'cash',
      validators: [Validators.required],
    ),
    'date': FormControl<DateTime>(
      value: DateTime.now(),
      validators: [Validators.required],
    ),
    'taxAmount': FormControl<String>(
      value: '0',
      validators: [ReactiveValidators.amountOptional('Tax amount')],
    ),
    'discountAmount': FormControl<String>(
      value: '0',
      validators: [ReactiveValidators.amountOptional('Discount amount')],
    ),
    'manualAmount': FormControl<String>(
      value: '',
      validators: [ReactiveValidators.amountOptional('Manual amount')],
    ),
    'remarks': FormControl<String>(),
  });

  final List<Map<String, dynamic>> _items = [];
  bool _isLoading = false;
  String _entryMode = 'items';
  List<CustomerModel>? _customers;
  CustomerModel? _selectedCustomer;
  bool _isLoadingCustomers = false;
  final CustomerRepository _customerRepository = getIt<CustomerRepository>();
  final InvoiceRepository _invoiceRepository = getIt<InvoiceRepository>();

  bool get _isEditMode => widget.existingInvoice != null;

  void _ensureManualAmountControl(AppLocalizations loc) {
    if (!_form.controls.containsKey('manualAmount')) {
      _form.addAll({
        'manualAmount': FormControl<String>(
          value: '',
          validators: [
            ReactiveValidators.amountOptional(loc.manualAmount, loc)
          ],
        ),
      });
    }
  }

  @override
  void initState() {
    super.initState();
    final existing = widget.existingInvoice;
    if (existing != null) {
      _form.control('customerId').value = existing.customerId;
      _form.control('invoiceType').value = existing.invoiceType;
      _form.control('date').value = existing.date;
      _form.control('taxAmount').value = existing.taxAmount;
      _form.control('discountAmount').value = existing.discountAmount;
      _form.control('remarks').value = existing.remarks;
      _items
        ..clear()
        ..addAll(
          (existing.items ?? const <InvoiceItemModel>[])
              .map(
                (item) => {
                  if (item.itemId != null) 'item_id': item.itemId,
                  'item_name': item.itemName,
                  'quantity': item.quantity,
                  'unit_price': item.unitPrice,
                },
              )
              .toList(),
        );
      _entryMode = 'items';
    }
    if (widget.initialCustomer != null) {
      _selectedCustomer = widget.initialCustomer;
      _form.control('customerId').value = widget.initialCustomer!.id;
    }
    if (widget.defaultInvoiceType != null) {
      _form.control('invoiceType').value = widget.defaultInvoiceType;
    }
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoadingCustomers = true);
    final result = await _customerRepository.getCustomers(isActive: true);
    if (mounted) {
      setState(() {
        _isLoadingCustomers = false;
        if (result.isSuccess) {
          _customers = result.dataOrNull;
          final selectedId = _form.control('customerId').value ??
              widget.initialCustomerId ??
              widget.existingInvoice?.customerId;
          if (selectedId != null) {
            final selected =
                _customers?.where((c) => c.id == selectedId).toList();
            if (selected != null && selected.isNotEmpty) {
              _selectedCustomer = selected.first;
              _form.control('customerId').value = selected.first.id;
            }
          }
        }
      });
    }
  }

  void _addItem() async {
    final selectedItems =
        await Navigator.of(context).push<List<Map<String, dynamic>>>(
      MaterialPageRoute(
        builder: (_) => const _SelectInvoiceItemsScreen(),
      ),
    );
    if (!mounted || selectedItems == null || selectedItems.isEmpty) return;

    setState(() {
      for (final newItem in selectedItems) {
        final newItemId = newItem['item_id']?.toString();
        if (newItemId != null) {
          final existingIndex = _items.indexWhere(
            (item) => item['item_id']?.toString() == newItemId,
          );
          if (existingIndex != -1) {
            final existing = _items[existingIndex];
            final existingQty =
                double.tryParse(existing['quantity']?.toString() ?? '0') ?? 0;
            final newQty =
                double.tryParse(newItem['quantity']?.toString() ?? '0') ?? 0;
            final mergedQty = existingQty + newQty;
            _items[existingIndex] = {
              ...existing,
              'quantity': mergedQty % 1 == 0
                  ? mergedQty.toInt().toString()
                  : mergedQty.toString(),
              'unit_price': newItem['unit_price'] ?? existing['unit_price'],
              'unit': existing['unit'] ?? newItem['unit'],
            };
            continue;
          }
        }
        _items.add(newItem);
      }
    });
  }

  void _removeItem(int index) async {
    final item = _items[index];
    final loc = AppLocalizations.of(context)!;
    final itemName = item['item_name'] as String? ?? loc.item;
    final confirmed = await ConfirmationDialog.showDelete(
      context: context,
      itemName: itemName,
      additionalMessage: loc.removeItemConfirm.replaceAll('{item}', itemName),
    );
    if (confirmed == true && mounted) {
      setState(() {
        _items.removeAt(index);
      });
    }
  }

  Future<void> _handleSubmit() async {
    final loc = AppLocalizations.of(context)!;
    // Validate customer first
    if (_form.control('customerId').value == null ||
        _form.control('customerId').value.toString().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.customerRequired),
          backgroundColor: Colors.orange,
        ),
      );
      _form.control('customerId').markAsTouched();
      return;
    }

    // Validate items
    final manualAmountText =
        _form.control('manualAmount').value as String? ?? '';
    final manualAmount = double.tryParse(manualAmountText) ?? 0;
    if (_entryMode == 'manual') {
      if (manualAmount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.manualAmountRequired),
            backgroundColor: Colors.orange,
          ),
        );
        _form.control('manualAmount').markAsTouched();
        return;
      }
    } else {
      if (_items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.pleaseAddItem),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

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
    final submissionItems = _entryMode == 'manual'
        ? [
            {
              'item_name': loc.manualAmount,
              'quantity': '1',
              'unit_price': manualAmountText,
            },
          ]
        : _items
            .map(
              (item) => {
                if (item['item_id'] != null) 'item_id': item['item_id'],
                'item_name': item['item_name'],
                'quantity': item['quantity'],
                'unit_price': item['unit_price'],
              },
            )
            .toList();

    if (_isEditMode) {
      final existing = widget.existingInvoice!;
      final updateResult = await _invoiceRepository.updateInvoice(
        invoiceId: existing.id,
        date: _form.control('date').value as DateTime,
        items: submissionItems,
        taxAmount: _form.control('taxAmount').value as String? ?? '0',
        discountAmount: _form.control('discountAmount').value as String? ?? '0',
        remarks: _form.control('remarks').value as String?,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);
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
          content:
              Text(updateResult.failureOrNull?.message ?? loc.failedToLoadData),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<InvoiceBloc>().add(
          CreateInvoiceEvent(
            customerId: _form.control('customerId').value as String?,
            invoiceType: _form.control('invoiceType').value as String,
            date: _form.control('date').value as DateTime,
            items: submissionItems,
            taxAmount: _form.control('taxAmount').value as String? ?? '0',
            discountAmount:
                _form.control('discountAmount').value as String? ?? '0',
            remarks: _form.control('remarks').value as String?,
          ),
        );
  }

  double _calculateTotal() {
    double subtotal;
    if (_entryMode == 'manual') {
      subtotal = double.tryParse(
            _form.control('manualAmount').value as String? ?? '0',
          ) ??
          0;
    } else {
      subtotal = _items.fold<double>(
        0,
        (sum, item) {
          final quantity = double.tryParse(item['quantity'] ?? '1') ?? 1;
          final unitPrice = double.tryParse(item['unit_price'] ?? '0') ?? 0;
          return sum + (quantity * unitPrice);
        },
      );
    }
    final tax =
        double.tryParse(_form.control('taxAmount').value as String? ?? '0') ??
            0;
    final discount = double.tryParse(
            _form.control('discountAmount').value as String? ?? '0') ??
        0;
    return subtotal + tax - discount;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final loc = AppLocalizations.of(context)!;
    _ensureManualAmountControl(loc);
    final localeCode = loc.locale.languageCode;
    if (_lastLocaleCode != localeCode) {
      _form.control('taxAmount').setValidators(
        [ReactiveValidators.amountOptional(loc.taxAmount, loc)],
      );
      _form.control('discountAmount').setValidators(
        [ReactiveValidators.amountOptional(loc.discountAmount, loc)],
      );
      _form.control('manualAmount').setValidators(
        [ReactiveValidators.amountOptional(loc.manualAmount, loc)],
      );
      _form.control('taxAmount').updateValueAndValidity();
      _form.control('discountAmount').updateValueAndValidity();
      _form.control('manualAmount').updateValueAndValidity();
      _lastLocaleCode = localeCode;
    }
  }

  bool _isWholeUnit(String? unit) {
    final normalized = (unit ?? '').toLowerCase().trim();
    if (normalized.isEmpty) return true;
    const fractionalUnits = {
      'kg',
      'kilogram',
      'g',
      'gram',
      'grams',
      'l',
      'liter',
      'litre',
      'ltr',
      'ml',
      'meter',
      'm',
      'cm',
      'ft',
      'inch',
    };
    return !fractionalUnits.contains(normalized);
  }

  double _stepForUnit(String? unit) => _isWholeUnit(unit) ? 1.0 : 0.1;

  String _formatQuantity(double value, String? unit) {
    if (_isWholeUnit(unit)) {
      return value.round().toString();
    }
    return value
        .toStringAsFixed(2)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\\.$'), '');
  }

  void _changeItemQuantity({
    required int index,
    required double delta,
  }) {
    final item = _items[index];
    final unit = item['unit']?.toString();
    final current = double.tryParse(item['quantity']?.toString() ?? '0') ?? 0;
    final next = current + delta;
    final normalized = _isWholeUnit(unit)
        ? (next <= 1 ? 1.0 : next.roundToDouble())
        : (next <= 0.1 ? 0.1 : next);
    setState(() {
      _items[index] = {
        ...item,
        'quantity': _formatQuantity(normalized, unit),
      };
    });
  }

  void _setItemQuantity({
    required int index,
    required String value,
  }) {
    final item = _items[index];
    final unit = item['unit']?.toString();
    final parsed = double.tryParse(value.trim());
    if (parsed == null) return;
    final normalized = _isWholeUnit(unit)
        ? (parsed <= 1 ? 1.0 : parsed.roundToDouble())
        : (parsed <= 0.1 ? 0.1 : parsed);
    setState(() {
      _items[index] = {
        ...item,
        'quantity': _formatQuantity(normalized, unit),
      };
    });
  }

  void _setItemUnitPrice({
    required int index,
    required String value,
  }) {
    final item = _items[index];
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed < 0) return;
    setState(() {
      _items[index] = {
        ...item,
        'unit_price': parsed.toStringAsFixed(2),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          _isEditMode ? '${loc.edit} ${loc.invoice}' : loc.createInvoice,
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
      body: BlocConsumer<InvoiceBloc, InvoiceState>(
        listener: (context, state) {
          if (state is InvoiceCreated) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(loc.success),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(true);
          } else if (state is InvoiceError) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
          // Reset loading state for any non-loading state to prevent infinite loading
          else if (state is! InvoiceLoading && _isLoading) {
            setState(() => _isLoading = false);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(14),
            child: ReactiveForm(
              formGroup: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Customer Selection (Required)
                  _CustomerSelectorField(
                    formControl:
                        _form.control('customerId') as FormControl<String>,
                    customers: _customers,
                    isLoading: _isLoadingCustomers,
                    enabled: !_isEditMode,
                    selectedCustomer: _selectedCustomer,
                    onCustomerSelected: (customer) {
                      setState(() {
                        _selectedCustomer = customer;
                        _form.control('customerId').value = customer.id;
                      });
                    },
                    onRefresh: _loadCustomers,
                  ),
                  const SizedBox(height: 12),
                  // Invoice Type
                  _isEditMode
                      ? InputDecorator(
                          decoration: InputDecoration(
                            labelText: loc.invoiceType,
                            prefixIcon: const Icon(Icons.receipt),
                          ),
                          child: Text(
                            (_form.control('invoiceType').value as String?) ==
                                    'credit'
                                ? loc.credit
                                : loc.cash,
                            style: theme.textTheme.bodyLarge,
                          ),
                        )
                      : ReactiveDropdownField<String>(
                          formControlName: 'invoiceType',
                          decoration: InputDecoration(
                            labelText: loc.invoiceType,
                            prefixIcon: const Icon(Icons.receipt),
                          ),
                          items: [
                            DropdownMenuItem(
                                value: 'cash', child: Text(loc.cash)),
                            DropdownMenuItem(
                                value: 'credit', child: Text(loc.credit)),
                          ],
                        ),
                  const SizedBox(height: 12),
                  // Date
                  Builder(
                    builder: (context) {
                      final dateControl =
                          _form.control('date') as FormControl<DateTime>;
                      final dateValue = dateControl.value ?? DateTime.now();
                      return InkWell(
                        onTap: () async {
                          final now = DateTime.now();
                          final today = DateTime(now.year, now.month, now.day);
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
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ReactiveTextField(
                          formControlName: 'taxAmount',
                          decoration: InputDecoration(
                            labelText: loc.taxAmount,
                            hintText: '0.00',
                            prefixIcon: const Icon(Icons.receipt_long),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ReactiveTextField(
                          formControlName: 'discountAmount',
                          decoration: InputDecoration(
                            labelText: loc.discountAmount,
                            hintText: '0.00',
                            prefixIcon: const Icon(Icons.discount),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Remarks
                  ReactiveTextField(
                    formControlName: 'remarks',
                    decoration: InputDecoration(
                      labelText: loc.remarksOptional,
                      hintText: loc.additionalNotes,
                      prefixIcon: const Icon(Icons.note),
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 16),
                  // Amount entry mode
                  Text(
                    loc.amount,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<String>(
                    segments: [
                      ButtonSegment(
                        value: 'items',
                        label: Text(loc.items),
                        icon: const Icon(Icons.list_alt),
                      ),
                      ButtonSegment(
                        value: 'manual',
                        label: Text(loc.enterManually),
                        icon: const Icon(Icons.edit),
                      ),
                    ],
                    selected: {_entryMode},
                    onSelectionChanged: (value) {
                      setState(() => _entryMode = value.first);
                    },
                  ),
                  const SizedBox(height: 16),
                  if (_entryMode == 'manual') ...[
                    ReactiveTextField(
                      formControlName: 'manualAmount',
                      decoration: InputDecoration(
                        labelText: loc.manualAmount,
                        hintText: '0.00',
                        prefixIcon: const Icon(Icons.edit),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    if (_items.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant
                              .withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: theme.colorScheme.outline
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                loc.manualModeItemsIgnored,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          loc.items,
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
                            loc.noItemsAdded,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      )
                    else
                      ..._items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final unit = item['unit']?.toString();
                        final isWholeUnit = _isWholeUnit(unit);
                        final quantityValue = double.tryParse(
                                item['quantity']?.toString() ?? '1') ??
                            1;
                        final unitPriceValue = double.tryParse(
                                item['unit_price']?.toString() ?? '0') ??
                            0;
                        final quantityText =
                            _formatQuantity(quantityValue, unit);
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item['item_name'] ?? '',
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () => _removeItem(index),
                                      tooltip: loc.delete,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      loc.quantity,
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      icon: const Icon(
                                          Icons.remove_circle_outline),
                                      splashRadius: 18,
                                      onPressed: () => _changeItemQuantity(
                                        index: index,
                                        delta: -_stepForUnit(unit),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 68,
                                      child: TextFormField(
                                        key: ValueKey(
                                            'qty_${index}_$quantityText'),
                                        initialValue: quantityText,
                                        textAlign: TextAlign.center,
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                          decimal: !isWholeUnit,
                                        ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                            RegExp(isWholeUnit
                                                ? r'\\d+'
                                                : r'\\d*\\.?\\d*'),
                                          ),
                                        ],
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 8,
                                          ),
                                        ),
                                        onFieldSubmitted: (value) =>
                                            _setItemQuantity(
                                                index: index, value: value),
                                      ),
                                    ),
                                    IconButton(
                                      icon:
                                          const Icon(Icons.add_circle_outline),
                                      splashRadius: 18,
                                      onPressed: () => _changeItemQuantity(
                                        index: index,
                                        delta: _stepForUnit(unit),
                                      ),
                                    ),
                                    if (unit != null && unit.trim().isNotEmpty)
                                      Text(
                                        unit,
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  key: ValueKey(
                                      'price_${index}_${item['unit_price']}'),
                                  initialValue:
                                      unitPriceValue.toStringAsFixed(2),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'\\d*\\.?\\d*'),
                                    ),
                                  ],
                                  decoration: InputDecoration(
                                    isDense: true,
                                    labelText: loc.unitPrice,
                                    prefixText:
                                        '${CurrencyUtils.getCurrentCurrency().symbol} ',
                                  ),
                                  onFieldSubmitted: (value) =>
                                      _setItemUnitPrice(
                                          index: index, value: value),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                  ],
                  const SizedBox(height: 24),
                  // Total
                  ReactiveFormConsumer(
                    builder: (context, form, child) {
                      return Container(
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
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const SizedBox(height: 24),
                  AppButton(
                    onPressed: _isLoading ? null : _handleSubmit,
                    label: _isEditMode ? loc.save : loc.createInvoice,
                    icon: Icons.check,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CustomerSelectorField extends StatelessWidget {
  const _CustomerSelectorField({
    required this.formControl,
    required this.customers,
    required this.isLoading,
    required this.enabled,
    required this.selectedCustomer,
    required this.onCustomerSelected,
    required this.onRefresh,
  });

  final FormControl<String> formControl;
  final List<CustomerModel>? customers;
  final bool isLoading;
  final bool enabled;
  final CustomerModel? selectedCustomer;
  final ValueChanged<CustomerModel> onCustomerSelected;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final hasError = formControl.hasErrors && formControl.touched;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: enabled ? () => _showCustomerSelector(context) : null,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: loc.customer,
              hintText: loc.selectCustomer,
              prefixIcon: const Icon(Icons.person),
              suffixIcon:
                  Icon(enabled ? Icons.arrow_drop_down : Icons.lock_outline),
              filled: true,
              fillColor:
                  theme.colorScheme.surfaceVariant.withValues(alpha: 0.3),
              errorText: hasError ? loc.customerRequired : null,
              errorMaxLines: 2,
            ),
            child: Text(
              selectedCustomer?.name ?? loc.selectCustomer,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: selectedCustomer == null
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showCustomerSelector(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    String searchQuery = '';

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          final filteredCustomers = customers?.where((customer) {
                if (searchQuery.isEmpty) return true;
                return customer.name
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase()) ||
                    (customer.phone
                            ?.toLowerCase()
                            .contains(searchQuery.toLowerCase()) ??
                        false);
              }).toList() ??
              [];

          return AlertDialog(
            title: Row(
              children: [
                Expanded(
                  child: TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: loc.searchCustomer,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredCustomers.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Text(
                              searchQuery.isEmpty
                                  ? loc.noCustomersFound
                                  : loc.noResultsFound,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: filteredCustomers.length,
                          itemBuilder: (context, index) {
                            final customer = filteredCustomers[index];
                            final isSelected =
                                selectedCustomer?.id == customer.id;
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    theme.colorScheme.primaryContainer,
                                child: Icon(
                                  Icons.person,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                              title: Text(customer.name),
                              subtitle: customer.phone != null
                                  ? Text(customer.phone!)
                                  : null,
                              trailing: isSelected
                                  ? Icon(Icons.check_circle,
                                      color: theme.colorScheme.primary)
                                  : null,
                              selected: isSelected,
                              onTap: () {
                                onCustomerSelected(customer);
                                Navigator.of(context).pop();
                              },
                            );
                          },
                        ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(loc.cancel),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SelectInvoiceItemsScreen extends StatefulWidget {
  const _SelectInvoiceItemsScreen();

  @override
  State<_SelectInvoiceItemsScreen> createState() =>
      _SelectInvoiceItemsScreenState();
}

class _SelectInvoiceItemsScreenState extends State<_SelectInvoiceItemsScreen> {
  List<StockItemModel>? _stockItems;
  bool _isLoading = false;
  String _searchQuery = '';
  final Map<String, double> _selectedQuantities = {};
  final Map<String, double> _selectedUnitPrices = {};
  final Map<String, TextEditingController> _qtyControllers = {};
  final Map<String, TextEditingController> _priceControllers = {};
  final List<Map<String, dynamic>> _manualItems = [];
  final StockRepository _stockRepository = getIt<StockRepository>();

  @override
  void initState() {
    super.initState();
    _loadStockItems();
  }

  @override
  void dispose() {
    for (final controller in _qtyControllers.values) {
      controller.dispose();
    }
    for (final controller in _priceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadStockItems() async {
    setState(() => _isLoading = true);
    final result = await _stockRepository.getItems(isActive: true);
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result.isSuccess) {
          _stockItems = result.dataOrNull;
        } else {
          _stockItems = [];
        }
      });
    }
  }

  List<StockItemModel> _filteredItems() {
    final items = _stockItems ?? [];
    if (_searchQuery.trim().isEmpty) return items;
    final query = _searchQuery.toLowerCase();
    return items
        .where((item) => item.name.toLowerCase().contains(query))
        .toList();
  }

  bool _isWholeUnit(String unit) {
    final normalized = unit.trim().toLowerCase();
    return normalized == 'pcs' ||
        normalized == 'piece' ||
        normalized == 'pieces' ||
        normalized == 'box' ||
        normalized == 'pack';
  }

  double _normalizeQuantity(double qty, bool whole) {
    if (whole) {
      return qty.roundToDouble();
    }
    return double.parse(qty.toStringAsFixed(2));
  }

  String _formatQuantity(double qty, bool whole) {
    if (whole) {
      return qty.round().toString();
    }
    final text = qty.toStringAsFixed(2);
    return text
        .replaceAll(RegExp(r'\.0+$'), '')
        .replaceAll(RegExp(r'(\.\d*[1-9])0+$'), r'$1');
  }

  TextEditingController _getQtyController(String id, String initialValue) {
    return _qtyControllers.putIfAbsent(
      id,
      () => TextEditingController(text: initialValue),
    );
  }

  TextEditingController _getPriceController(String id, String initialValue) {
    return _priceControllers.putIfAbsent(
      id,
      () => TextEditingController(text: initialValue),
    );
  }

  void _toggleSelection(StockItemModel item, bool? isSelected) {
    setState(() {
      if (isSelected == true) {
        final isWhole = _isWholeUnit(item.unit);
        final stockValue = double.tryParse(item.currentStock) ?? 0;
        final defaultQty = isWhole ? 1.0 : (stockValue < 1 ? stockValue : 1.0);
        final defaultPrice = double.tryParse(item.salePrice) ?? 0;
        final initial =
            _formatQuantity(defaultQty <= 0 ? 1 : defaultQty, isWhole);
        _selectedQuantities[item.id] = defaultQty <= 0 ? 1 : defaultQty;
        _selectedUnitPrices[item.id] = defaultPrice;
        _getQtyController(item.id, initial);
        _getPriceController(item.id, defaultPrice.toStringAsFixed(2));
      } else {
        _selectedQuantities.remove(item.id);
        _selectedUnitPrices.remove(item.id);
        _qtyControllers.remove(item.id)?.dispose();
        _priceControllers.remove(item.id)?.dispose();
      }
    });
  }

  void _addManualItem() async {
    await showDialog(
      context: context,
      builder: (_) => _AddItemDialog(
        onAdd: (item) {
          setState(() {
            _manualItems.add(item);
          });
        },
      ),
    );
  }

  double _calculateSelectedTotal() {
    double total = 0;
    for (final item in _manualItems) {
      final qty = double.tryParse(item['quantity']?.toString() ?? '0') ?? 0;
      final unitPrice =
          double.tryParse(item['unit_price']?.toString() ?? '0') ?? 0;
      total += qty * unitPrice;
    }
    if (_stockItems == null) return total;
    for (final entry in _selectedQuantities.entries) {
      final id = entry.key;
      final qty = entry.value;
      final item = _stockItems!.firstWhere(
        (entry) => entry.id == id,
        orElse: () => const StockItemModel(
          id: '',
          name: '',
          purchasePrice: '0',
          salePrice: '0',
          unit: '',
          currentStock: '0',
        ),
      );
      if (item.id.isEmpty) continue;
      final unitPrice =
          _selectedUnitPrices[id] ?? (double.tryParse(item.salePrice) ?? 0);
      total += unitPrice * qty;
    }
    return total;
  }

  List<Map<String, dynamic>> _buildSelectedItems() {
    final items = <Map<String, dynamic>>[];
    for (final item in _manualItems) {
      items.add(item);
    }
    if (_stockItems != null) {
      for (final entry in _selectedQuantities.entries) {
        final id = entry.key;
        final qty = entry.value;
        final item = _stockItems!.firstWhere(
          (entry) => entry.id == id,
          orElse: () => const StockItemModel(
            id: '',
            name: '',
            purchasePrice: '0',
            salePrice: '0',
            unit: '',
            currentStock: '0',
          ),
        );
        if (item.id.isEmpty) continue;
        final isWhole = _isWholeUnit(item.unit);
        final unitPrice =
            _selectedUnitPrices[id] ?? (double.tryParse(item.salePrice) ?? 0);
        items.add({
          'item_id': item.id,
          'item_name': item.name,
          'quantity': _formatQuantity(qty, isWhole),
          'unit_price': unitPrice.toStringAsFixed(2),
          'unit': item.unit,
        });
      }
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final filteredItems = _filteredItems();
    final totalAmount = _calculateSelectedTotal();
    final hasSelection =
        _selectedQuantities.isNotEmpty || _manualItems.isNotEmpty;
    bool hasStockIssue = false;
    bool hasQuantityIssue = false;
    bool hasPriceIssue = false;
    for (final entry in _selectedQuantities.entries) {
      final item = _stockItems?.firstWhere(
        (candidate) => candidate.id == entry.key,
        orElse: () => const StockItemModel(
          id: '',
          name: '',
          purchasePrice: '0',
          salePrice: '0',
          unit: '',
          currentStock: '0',
        ),
      );
      if (item == null || item.id.isEmpty) {
        hasQuantityIssue = true;
        continue;
      }
      final qty = entry.value;
      if (qty <= 0) {
        hasQuantityIssue = true;
        continue;
      }
      final selectedPrice = _selectedUnitPrices[entry.key];
      if (selectedPrice == null || selectedPrice <= 0) {
        hasPriceIssue = true;
      }
      final isWhole = _isWholeUnit(item.unit);
      if (isWhole && qty % 1 != 0) {
        hasQuantityIssue = true;
        continue;
      }
      final stockValue = double.tryParse(item.currentStock) ?? 0;
      if (qty > stockValue) {
        hasStockIssue = true;
      }
    }
    final hasInvalidSelection =
        hasStockIssue || hasQuantityIssue || hasPriceIssue;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.addItem),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: InkWell(
              onTap: _addManualItem,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color:
                      theme.colorScheme.surfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        loc.addItem,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: loc.search,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          if (_manualItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.items,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._manualItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(item['item_name']?.toString() ?? loc.item),
                        subtitle: Text(
                          '${loc.quantity}: ${item['quantity'] ?? '1'} x ${CurrencyUtils.formatCurrency(double.tryParse(item['unit_price'] ?? '0') ?? 0)}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            setState(() => _manualItems.removeAt(index));
                          },
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredItems.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(
                            _stockItems == null || _stockItems!.isNotEmpty
                                ? loc.noResultsFound
                                : loc.noStockItems,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: filteredItems.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          color:
                              theme.colorScheme.outline.withValues(alpha: 0.2),
                        ),
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          final stockValue =
                              double.tryParse(item.currentStock) ?? 0;
                          final isWhole = _isWholeUnit(item.unit);
                          final hasStock =
                              isWhole ? stockValue >= 1 : stockValue > 0;
                          final isSelected =
                              _selectedQuantities.containsKey(item.id);
                          final stockColor = stockValue <= 0
                              ? Colors.red
                              : stockValue < 10
                                  ? Colors.orange
                                  : Colors.green;
                          final qtyController = isSelected
                              ? _getQtyController(
                                  item.id,
                                  _formatQuantity(
                                    _selectedQuantities[item.id] ?? 1,
                                    isWhole,
                                  ),
                                )
                              : null;
                          final priceController = isSelected
                              ? _getPriceController(
                                  item.id,
                                  (_selectedUnitPrices[item.id] ??
                                          (double.tryParse(item.salePrice) ??
                                              0))
                                      .toStringAsFixed(2),
                                )
                              : null;
                          final qtyValue = _selectedQuantities[item.id] ?? 0;
                          final exceedsStock = isSelected &&
                              qtyValue >
                                  (double.tryParse(item.currentStock) ?? 0);

                          return InkWell(
                            onTap: hasStock
                                ? () => _toggleSelection(item, !isSelected)
                                : null,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: isSelected,
                                  onChanged: hasStock
                                      ? (value) => _toggleSelection(item, value)
                                      : null,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Text(
                                              '${loc.stock}: ',
                                              style: theme.textTheme.bodySmall,
                                            ),
                                            Text(
                                              hasStock
                                                  ? '$stockValue ${item.unit}'
                                                  : loc.outOfStock,
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                color: stockColor,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (isSelected) ...[
                                          const SizedBox(height: 8),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: TextField(
                                                  controller: qtyController,
                                                  textAlign: TextAlign.center,
                                                  keyboardType:
                                                      const TextInputType
                                                          .numberWithOptions(
                                                    decimal: true,
                                                  ),
                                                  inputFormatters: [
                                                    isWhole
                                                        ? FilteringTextInputFormatter
                                                            .digitsOnly
                                                        : FilteringTextInputFormatter
                                                            .allow(
                                                            RegExp(
                                                                r'^\d*\.?\d{0,2}'),
                                                          ),
                                                  ],
                                                  decoration: InputDecoration(
                                                    labelText: loc.quantity,
                                                    suffixText: item.unit,
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                      horizontal: 8,
                                                      vertical: 8,
                                                    ),
                                                    isDense: true,
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                  ),
                                                  onChanged: (value) {
                                                    final parsed =
                                                        double.tryParse(value);
                                                    setState(() {
                                                      _selectedQuantities[
                                                          item.id] = parsed ==
                                                              null
                                                          ? 0
                                                          : _normalizeQuantity(
                                                              parsed,
                                                              isWhole,
                                                            );
                                                    });
                                                  },
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: TextField(
                                                  controller: priceController,
                                                  textAlign: TextAlign.center,
                                                  keyboardType:
                                                      const TextInputType
                                                          .numberWithOptions(
                                                    decimal: true,
                                                  ),
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter
                                                        .allow(
                                                      RegExp(r'^\d*\.?\d{0,2}'),
                                                    ),
                                                  ],
                                                  decoration: InputDecoration(
                                                    labelText: loc.unitPrice,
                                                    prefixText:
                                                        '${CurrencyUtils.getCurrentCurrency().symbol} ',
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                      horizontal: 8,
                                                      vertical: 8,
                                                    ),
                                                    isDense: true,
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                  ),
                                                  onChanged: (value) {
                                                    final parsed =
                                                        double.tryParse(value);
                                                    setState(() {
                                                      _selectedUnitPrices[item
                                                          .id] = parsed ?? 0;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (exceedsStock)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 4),
                                              child: Text(
                                                '${loc.insufficientStock}: ${item.currentStock} ${item.unit}',
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                  color:
                                                      theme.colorScheme.error,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ],
                                    ),
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
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasInvalidSelection)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    hasStockIssue
                        ? loc.cannotAddItemInsufficientStock
                        : hasPriceIssue
                            ? loc.validPriceRequired
                            : loc.validQuantityRequired,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ElevatedButton(
                onPressed: hasSelection && !hasInvalidSelection
                    ? () {
                        final items = _buildSelectedItems();
                        Navigator.of(context).pop(items);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const StadiumBorder(),
                ),
                child: Text(
                  CurrencyUtils.formatCurrency(totalAmount),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
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

class _AddItemDialog extends StatefulWidget {
  const _AddItemDialog({required this.onAdd});

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

  List<StockItemModel>? _stockItems;
  StockItemModel? _selectedStockItem;
  bool _isLoadingStock = false;
  final StockRepository _stockRepository = getIt<StockRepository>();

  @override
  void initState() {
    super.initState();
    _loadStockItems();
  }

  Future<void> _loadStockItems() async {
    setState(() => _isLoadingStock = true);
    final result = await _stockRepository.getItems(isActive: true);
    if (mounted) {
      setState(() {
        _isLoadingStock = false;
        if (result.isSuccess) {
          _stockItems = result.dataOrNull;
        }
      });
    }
  }

  void _onStockItemSelected(StockItemModel? item) {
    setState(() {
      _selectedStockItem = item;
      if (item != null) {
        _form.control('itemName').value = item.name;
        _form.control('unitPrice').value = item.salePrice;
        _form.control('itemId').value = item.id;
      } else {
        _form.control('itemName').value = null;
        _form.control('unitPrice').value = null;
        _form.control('itemId').value = null;
      }
    });
  }

  bool _checkStockAvailability(String quantityStr) {
    if (_selectedStockItem == null) return true; // Manual entry, skip check
    final quantity = double.tryParse(quantityStr) ?? 0;
    final availableStock =
        double.tryParse(_selectedStockItem!.currentStock) ?? 0;
    return quantity <= availableStock;
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
              // Stock Item Selection (Primary Method)
              if (_isLoadingStock)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                )
              else if (_stockItems != null && _stockItems!.isNotEmpty) ...[
                Text(
                  loc.selectFromStock,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<StockItemModel>(
                  decoration: InputDecoration(
                    labelText: loc.selectStockItem,
                    hintText: loc.selectStockItem,
                    prefixIcon: const Icon(Icons.inventory_2),
                    filled: true,
                    fillColor:
                        theme.colorScheme.surfaceVariant.withValues(alpha: 0.3),
                  ),
                  isExpanded: true,
                  items: _stockItems!.map((item) {
                    final stock = double.tryParse(item.currentStock) ?? 0;
                    return DropdownMenuItem<StockItemModel>(
                      value: item,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '${loc.stock}: ',
                                style: theme.textTheme.bodySmall,
                              ),
                              Text(
                                '$stock ${item.unit}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: stock <= 0
                                      ? Colors.red
                                      : stock < 10
                                          ? Colors.orange
                                          : Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${loc.price}: ${CurrencyUtils.formatCurrency(double.tryParse(item.salePrice) ?? 0)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: _onStockItemSelected,
                ),
                const SizedBox(height: 16),
                // Divider with "OR" text
                Row(
                  children: [
                    Expanded(child: Divider(color: theme.colorScheme.outline)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        loc.or,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: theme.colorScheme.outline)),
                  ],
                ),
                const SizedBox(height: 16),
                // Manual Entry Section
                Text(
                  loc.enterManually,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
              ] else ...[
                // No stock items available - show manual entry only
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        theme.colorScheme.surfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color:
                            theme.colorScheme.outline.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          loc.noStockItemsAvailable,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              // Item Name
              ReactiveTextField(
                formControlName: 'itemName',
                decoration: InputDecoration(
                  labelText: loc.itemName,
                  hintText: loc.enterItemName,
                  prefixIcon: const Icon(Icons.label),
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
                      onChanged: (control) {
                        if (_selectedStockItem != null) {
                          final quantityStr = control.value as String? ?? '';
                          if (quantityStr.isNotEmpty) {
                            final isAvailable =
                                _checkStockAvailability(quantityStr);
                            if (!isAvailable) {
                              final available = double.tryParse(
                                    _selectedStockItem!.currentStock,
                                  ) ??
                                  0;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${loc.insufficientStock}: $available ${_selectedStockItem!.unit}',
                                  ),
                                  backgroundColor: Colors.orange,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          }
                        }
                      },
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
              // Stock availability warning
              if (_selectedStockItem != null) ...[
                const SizedBox(height: 8),
                Builder(
                  builder: (context) {
                    final quantityStr =
                        _form.control('quantity').value as String? ?? '';
                    final quantity = double.tryParse(quantityStr) ?? 0;
                    final available =
                        double.tryParse(_selectedStockItem!.currentStock) ?? 0;
                    if (quantity > available) {
                      return Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning,
                                color: Colors.red, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${loc.insufficientStock}: $available ${_selectedStockItem!.unit}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
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
              final quantityStr = _form.control('quantity').value as String;
              // Check stock availability if stock item is selected
              if (_selectedStockItem != null &&
                  !_checkStockAvailability(quantityStr)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(loc.cannotAddItemInsufficientStock),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              widget.onAdd({
                'item_name': _form.control('itemName').value as String,
                'quantity': quantityStr,
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
