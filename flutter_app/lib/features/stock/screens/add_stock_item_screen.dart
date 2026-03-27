import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/utils/validators.dart' show ReactiveValidators;
import '../../../core/utils/currency_utils.dart';
import '../../../core/localization/app_localizations.dart';
import '../bloc/stock_bloc.dart';
import '../bloc/stock_event.dart';
import '../bloc/stock_state.dart';

class AddStockItemScreen extends StatefulWidget {
  const AddStockItemScreen({super.key});

  @override
  State<AddStockItemScreen> createState() => _AddStockItemScreenState();
}

class _AddStockItemScreenState extends State<AddStockItemScreen> {
  String? _lastLocaleCode;
  final FormGroup _form = FormGroup({
    'name': FormControl<String>(
      validators: [Validators.required],
    ),
    'purchasePrice': FormControl<String>(
      validators: [
        Validators.required,
        ReactiveValidators.amount('Purchase price')
      ],
    ),
    'salePrice': FormControl<String>(
      validators: [
        Validators.required,
        ReactiveValidators.amount('Sale price')
      ],
    ),
    'unit': FormControl<String>(
      value: 'pcs',
      validators: [Validators.required],
    ),
    'openingStock': FormControl<String>(
      value: '0',
      validators: [
        Validators.required,
        ReactiveValidators.amountAllowZero('Opening stock')
      ],
    ),
    'description': FormControl<String>(),
  });

  bool _isLoading = false;

  void _handleSubmit() {
    if (_form.valid) {
      setState(() => _isLoading = true);
      context.read<StockBloc>().add(
            CreateStockItemEvent(
              name: _form.control('name').value as String,
              purchasePrice: _form.control('purchasePrice').value as String,
              salePrice: _form.control('salePrice').value as String,
              unit: _form.control('unit').value as String,
              openingStock: _form.control('openingStock').value as String,
              description: _form.control('description').value as String?,
            ),
          );
    } else {
      _form.markAllAsTouched();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final localeCode = loc.locale.languageCode;
    if (_lastLocaleCode != localeCode) {
      _form.control('purchasePrice').setValidators([
        Validators.required,
        ReactiveValidators.amount(loc.purchasePrice, loc),
      ]);
      _form.control('salePrice').setValidators([
        Validators.required,
        ReactiveValidators.amount(loc.salePrice, loc),
      ]);
      _form.control('openingStock').setValidators([
        Validators.required,
        ReactiveValidators.amountAllowZero(loc.openingStock, loc),
      ]);
      _form.control('purchasePrice').updateValueAndValidity();
      _form.control('salePrice').updateValueAndValidity();
      _form.control('openingStock').updateValueAndValidity();
      _lastLocaleCode = localeCode;
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          loc.addStockItem,
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
          if (state is StockItemCreated) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(loc.stockItemCreatedSuccessfully),
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
          if (state is StockLoading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() => _isLoading = true);
              }
            });
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ReactiveForm(
              formGroup: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ReactiveTextField(
                    formControlName: 'name',
                    decoration: InputDecoration(
                      labelText: loc.itemName,
                      hintText: loc.enterItemName,
                      prefixIcon: const Icon(Icons.inventory),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ReactiveTextField(
                          formControlName: 'purchasePrice',
                          decoration: InputDecoration(
                            labelText: loc.purchasePrice,
                            hintText: '0.00',
                            prefixIcon: const Icon(Icons.shopping_cart),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ReactiveTextField(
                          formControlName: 'salePrice',
                          decoration: InputDecoration(
                            labelText: loc.salePrice,
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
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ReactiveDropdownField<String>(
                          formControlName: 'unit',
                          decoration: InputDecoration(
                            labelText: loc.unit,
                            prefixIcon: const Icon(Icons.scale),
                          ),
                          items: [
                            DropdownMenuItem(
                                value: 'pcs', child: Text(loc.pieces)),
                            DropdownMenuItem(
                                value: 'kg', child: Text(loc.kilogram)),
                            DropdownMenuItem(
                                value: 'liter', child: Text(loc.liter)),
                            DropdownMenuItem(
                                value: 'meter', child: Text(loc.meter)),
                            DropdownMenuItem(
                                value: 'box', child: Text(loc.box)),
                            DropdownMenuItem(
                                value: 'pack', child: Text(loc.pack)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ReactiveTextField(
                          formControlName: 'openingStock',
                          decoration: InputDecoration(
                            labelText: loc.openingStock,
                            hintText: '0',
                            prefixIcon: const Icon(Icons.inventory_2),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ReactiveTextField(
                    formControlName: 'description',
                    decoration: InputDecoration(
                      labelText: loc.descriptionOptional,
                      hintText: loc.itemDescription,
                      prefixIcon: const Icon(Icons.description),
                    ),
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    onPressed: _isLoading ? null : _handleSubmit,
                    label: loc.createItem,
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
