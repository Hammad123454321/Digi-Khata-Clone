import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/utils/validators.dart' show AppValidators;
import '../../../core/utils/currency_utils.dart';
import '../../../core/localization/app_localizations.dart';
import '../bloc/cash_bloc.dart';
import '../bloc/cash_event.dart';
import '../bloc/cash_state.dart';

class AddCashTransactionScreen extends StatelessWidget {
  const AddCashTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text('${loc.add} ${loc.cash} ${loc.transaction}'),
      ),
      body: const _CashTransactionForm(),
    );
  }
}

class AddCashTransactionSheet extends StatelessWidget {
  const AddCashTransactionSheet({
    super.key,
    required this.initialType,
  });

  final String initialType;

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
                    '${loc.add} ${loc.cash} ${loc.transaction}',
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
              child: _CashTransactionForm(
                initialType: initialType,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CashTransactionForm extends StatefulWidget {
  const _CashTransactionForm({
    this.initialType = 'cash_in',
    this.contentPadding = const EdgeInsets.all(24),
    this.showTypeSelector = true,
  });

  final String initialType;
  final EdgeInsets contentPadding;
  final bool showTypeSelector;

  @override
  State<_CashTransactionForm> createState() => _CashTransactionFormState();
}

class _CashTransactionFormState extends State<_CashTransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _sourceController = TextEditingController();
  final _remarksController = TextEditingController();

  late String _selectedType;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType == 'cash_out' ? 'cash_out' : 'cash_in';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _sourceController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      context.read<CashBloc>().add(
            CreateCashTransactionEvent(
              transactionType: _selectedType,
              amount: _amountController.text.trim(),
              date: _selectedDate,
              source: _sourceController.text.trim().isEmpty
                  ? null
                  : _sourceController.text.trim(),
              remarks: _remarksController.text.trim().isEmpty
                  ? null
                  : _remarksController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final dateFormatter = DateFormat.yMMMd(loc.locale.languageCode);

    return BlocListener<CashBloc, CashState>(
      listener: (context, state) {
        if (state is CashTransactionCreated) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.transactionCreatedSuccessfully),
              backgroundColor: Colors.green,
            ),
          );
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              Navigator.of(context).pop(true);
            }
          });
        } else if (state is CashError) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      },
      child: SingleChildScrollView(
        padding: widget.contentPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.showTypeSelector) ...[
                Text(
                  loc.transactionType,
                  style: theme.textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                      value: 'cash_in',
                      label: Text(loc.cashIn),
                      icon: const Icon(Icons.arrow_downward),
                    ),
                    ButtonSegment(
                      value: 'cash_out',
                      label: Text(loc.cashOut),
                      icon: const Icon(Icons.arrow_upward),
                    ),
                  ],
                  selected: {_selectedType},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() => _selectedType = newSelection.first);
                  },
                ),
                const SizedBox(height: 24),
              ],
              AppTextField(
                controller: _amountController,
                label: loc.amount,
                hint: '0.00',
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: Text(
                    CurrencyUtils.getCurrentCurrency().symbol,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
                validator: (value) => AppValidators.amount(value, loc),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: loc.date,
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                  ),
                  child: Text(
                    dateFormatter.format(_selectedDate),
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _sourceController,
                label: '${loc.source} (${loc.optional})',
                hint: loc.exampleSalesPurchase,
                prefixIcon: const Icon(Icons.source),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _remarksController,
                label: '${loc.remarks} (${loc.optional})',
                hint: loc.additionalNotes,
                prefixIcon: const Icon(Icons.note),
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 32),
              AppButton(
                onPressed: _isLoading ? null : _submit,
                label: '${loc.create} ${loc.transaction}',
                icon: Icons.check,
                isFullWidth: true,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
