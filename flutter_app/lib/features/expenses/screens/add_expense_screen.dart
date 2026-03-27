import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../../shared/models/expense_model.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/utils/validators.dart' show ReactiveValidators;
import '../../../core/utils/currency_utils.dart';
import '../../../core/localization/app_localizations.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';
import '../bloc/expense_state.dart';
import '../widgets/create_category_dialog.dart';

class AddExpenseScreen extends StatelessWidget {
  const AddExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          loc.addExpense,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
      body: const SafeArea(
        child: _ExpenseForm(),
      ),
    );
  }
}

class AddExpenseSheet extends StatelessWidget {
  const AddExpenseSheet({
    super.key,
    required this.initialPaymentMode,
  });

  final String initialPaymentMode;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return SafeArea(
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
                    loc.addExpense,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
            Flexible(
              child: _ExpenseForm(
                initialPaymentMode: initialPaymentMode,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseForm extends StatefulWidget {
  const _ExpenseForm({
    this.initialPaymentMode = 'cash',
    this.contentPadding = const EdgeInsets.all(24),
  });

  final String initialPaymentMode;
  final EdgeInsets contentPadding;

  @override
  State<_ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<_ExpenseForm> {
  String? _lastLocaleCode;
  late final FormGroup _form;
  bool _isSubmitting = false;

  List<ExpenseCategoryModel> _categories = [];
  bool _isLoadingCategories = false;

  @override
  void initState() {
    super.initState();
    _form = FormGroup({
      'categoryId': FormControl<String>(
        validators: [Validators.required],
      ),
      'amount': FormControl<String>(
        validators: [Validators.required, ReactiveValidators.amount()],
      ),
      'date': FormControl<DateTime>(
        value: DateTime.now(),
        validators: [Validators.required],
      ),
      'paymentMode': FormControl<String>(
        value: widget.initialPaymentMode == 'bank' ? 'bank' : 'cash',
        validators: [Validators.required],
      ),
      'description': FormControl<String>(),
    });

    context.read<ExpenseBloc>().add(const LoadExpenseCategoriesEvent());
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_form.valid) {
      _form.markAllAsTouched();
      return;
    }

    setState(() => _isSubmitting = true);

    context.read<ExpenseBloc>().add(
          CreateExpenseEvent(
            categoryId: _form.control('categoryId').value as String,
            amount: _form.control('amount').value as String,
            date: _form.control('date').value as DateTime,
            paymentMode: _form.control('paymentMode').value as String,
            description: _form.control('description').value as String?,
          ),
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
        ReactiveValidators.amount(loc.amount, loc),
      ]);
      _form.control('amount').updateValueAndValidity();
      _lastLocaleCode = localeCode;
    }

    return BlocListener<ExpenseBloc, ExpenseState>(
      listener: (context, state) {
        if (state is ExpenseCreated) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.expenseCreatedSuccessfully),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        } else if (state is ExpenseError) {
          if (_isSubmitting) {
            setState(() => _isSubmitting = false);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        } else if (state is ExpenseCategoriesLoaded) {
          setState(() {
            _categories = state.categories;
            _isLoadingCategories = false;
          });
        } else if (state is ExpenseLoading) {
          if (state.preserveCategories) {
            setState(() {
              _categories = state.categories;
              _isLoadingCategories = false;
            });
          } else {
            setState(() => _isLoadingCategories = true);
          }
        }
      },
      child: SingleChildScrollView(
        padding: widget.contentPadding,
        child: ReactiveForm(
          formGroup: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              if (_isLoadingCategories && _categories.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_categories.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        loc.noCategoriesAvailable,
                        style: const TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final created =
                              await CreateCategoryDialog.show(context);
                          if (created == true && mounted) {
                            context
                                .read<ExpenseBloc>()
                                .add(const LoadExpenseCategoriesEvent());
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: Text(loc.createCategory),
                      ),
                    ],
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: ReactiveDropdownField<String>(
                        formControlName: 'categoryId',
                        decoration: InputDecoration(
                          labelText: loc.expenseCategory,
                          prefixIcon: _isLoadingCategories
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.category),
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category.id,
                            child: Text(category.name),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.add),
                      tooltip: loc.createCategory,
                      onPressed: () async {
                        final created =
                            await CreateCategoryDialog.show(context);
                        if (created == true && mounted) {
                          context
                              .read<ExpenseBloc>()
                              .add(const LoadExpenseCategoriesEvent());
                        }
                      },
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              ReactiveTextField(
                formControlName: 'amount',
                decoration: InputDecoration(
                  labelText: loc.amount,
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
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              Builder(
                builder: (context) {
                  final dateControl =
                      _form.control('date') as FormControl<DateTime>;
                  final dateValue = dateControl.value ?? DateTime.now();
                  return InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: dateValue,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
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
              ReactiveDropdownField<String>(
                formControlName: 'paymentMode',
                decoration: InputDecoration(
                  labelText: loc.paymentMode,
                  prefixIcon: const Icon(Icons.payment),
                ),
                items: [
                  DropdownMenuItem(value: 'cash', child: Text(loc.cash)),
                  DropdownMenuItem(value: 'bank', child: Text(loc.bank)),
                ],
              ),
              const SizedBox(height: 16),
              ReactiveTextField(
                formControlName: 'description',
                decoration: InputDecoration(
                  labelText: loc.descriptionOptional,
                  hintText: loc.additionalNotes,
                  prefixIcon: const Icon(Icons.note),
                ),
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 32),
              AppButton(
                onPressed:
                    _isSubmitting || _categories.isEmpty || _isLoadingCategories
                        ? null
                        : _handleSave,
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
