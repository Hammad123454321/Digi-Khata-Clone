import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/utils/validators.dart' show ReactiveValidators;
import '../../../core/utils/currency_utils.dart';
import '../../../core/localization/app_localizations.dart';
import '../bloc/bank_bloc.dart';
import '../bloc/bank_event.dart';
import '../bloc/bank_state.dart';

class AddBankAccountScreen extends StatelessWidget {
  const AddBankAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          loc.addBankAccount,
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
        child: _BankAccountForm(),
      ),
    );
  }
}

class AddBankAccountSheet extends StatelessWidget {
  const AddBankAccountSheet({super.key});

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
                    loc.addBankAccount,
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
            const Flexible(
              child: _BankAccountForm(contentPadding: EdgeInsets.zero),
            ),
          ],
        ),
      ),
    );
  }
}

class _BankAccountForm extends StatefulWidget {
  const _BankAccountForm({
    this.contentPadding = const EdgeInsets.all(24),
  });

  final EdgeInsets contentPadding;

  @override
  State<_BankAccountForm> createState() => _BankAccountFormState();
}

class _BankAccountFormState extends State<_BankAccountForm> {
  String? _lastLocaleCode;
  final FormGroup _form = FormGroup({
    'bankName': FormControl<String>(
      validators: [Validators.required],
    ),
    'accountNumber': FormControl<String>(
      validators: [Validators.required],
    ),
    'accountHolderName': FormControl<String>(),
    'branch': FormControl<String>(),
    'ifscCode': FormControl<String>(),
    'accountType': FormControl<String>(
      value: 'savings',
    ),
    'openingBalance': FormControl<String>(
      value: '0',
      validators: [
        Validators.required,
        ReactiveValidators.amountAllowZero('Opening balance')
      ],
    ),
  });

  bool _isSubmitting = false;

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

    context.read<BankBloc>().add(
          CreateBankAccountEvent(
            bankName: _form.control('bankName').value as String,
            accountNumber: _form.control('accountNumber').value as String,
            accountHolderName:
                _form.control('accountHolderName').value as String?,
            branch: _form.control('branch').value as String?,
            ifscCode: _form.control('ifscCode').value as String?,
            accountType: _form.control('accountType').value as String?,
            openingBalance: _form.control('openingBalance').value as String,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final localeCode = loc.locale.languageCode;
    if (_lastLocaleCode != localeCode) {
      _form.control('openingBalance').setValidators([
        Validators.required,
        ReactiveValidators.amountAllowZero(loc.openingBalance, loc),
      ]);
      _form.control('openingBalance').updateValueAndValidity();
      _lastLocaleCode = localeCode;
    }

    return BlocListener<BankBloc, BankState>(
      listener: (context, state) {
        if (state is BankAccountCreated) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loc.bankAccountCreatedSuccessfully)),
          );
          Navigator.of(context).pop(true);
        } else if (state is BankError) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        } else if (state is BankLoading) {
          setState(() => _isSubmitting = true);
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
              ReactiveTextField(
                formControlName: 'bankName',
                decoration: InputDecoration(
                  labelText: loc.bankName,
                  hintText: loc.bankNameHint,
                  prefixIcon: const Icon(Icons.account_balance),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              ReactiveTextField(
                formControlName: 'accountNumber',
                decoration: InputDecoration(
                  labelText: loc.accountNumber,
                  hintText: loc.accountNumberHint,
                  prefixIcon: const Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              const SizedBox(height: 16),
              ReactiveTextField(
                formControlName: 'accountHolderName',
                decoration: InputDecoration(
                  labelText: loc.accountHolderNameOptional,
                  hintText: loc.accountHolderNameHint,
                  prefixIcon: const Icon(Icons.person),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              ReactiveTextField(
                formControlName: 'branch',
                decoration: InputDecoration(
                  labelText: loc.branchOptional,
                  hintText: loc.branchHint,
                  prefixIcon: const Icon(Icons.location_city),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              ReactiveTextField(
                formControlName: 'ifscCode',
                decoration: InputDecoration(
                  labelText: loc.ifscCodeOptional,
                  hintText: loc.ifscCodeHint,
                  prefixIcon: const Icon(Icons.qr_code),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              ReactiveDropdownField<String>(
                formControlName: 'accountType',
                decoration: InputDecoration(
                  labelText: loc.accountType,
                  prefixIcon: const Icon(Icons.account_balance_wallet),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'savings',
                    child: Text(loc.savings),
                  ),
                  DropdownMenuItem(
                    value: 'current',
                    child: Text(loc.current),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ReactiveTextField(
                formControlName: 'openingBalance',
                decoration: InputDecoration(
                  labelText: loc.openingBalance,
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
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 32),
              AppButton(
                onPressed: _isSubmitting ? null : _handleSave,
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
