import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../../core/localization/app_localizations.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';
import '../bloc/expense_state.dart';

class CreateCategoryDialog extends StatefulWidget {
  const CreateCategoryDialog({super.key});

  @override
  State<CreateCategoryDialog> createState() => _CreateCategoryDialogState();

  static Future<bool?> show(BuildContext context) {
    // Read the bloc from the original context before showing the dialog
    final expenseBloc = context.read<ExpenseBloc>();
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: expenseBloc,
        child: const CreateCategoryDialog(),
      ),
    );
  }
}

class _CreateCategoryDialogState extends State<CreateCategoryDialog> {
  final FormGroup _form = FormGroup({
    'name': FormControl<String>(
      validators: [
        Validators.required,
        Validators.minLength(2),
        Validators.maxLength(100),
      ],
    ),
    'description': FormControl<String>(
      validators: [Validators.maxLength(500)],
    ),
  });

  bool _isSubmitting = false;

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_form.valid) {
      _form.markAllAsTouched();
      return;
    }

    setState(() => _isSubmitting = true);

    context.read<ExpenseBloc>().add(
          CreateExpenseCategoryEvent(
            name: _form.control('name').value as String,
            description: _form.control('description').value as String?,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return BlocListener<ExpenseBloc, ExpenseState>(
      listener: (context, state) {
        if (state is ExpenseCategoryCreated) {
          setState(() => _isSubmitting = false);
          Navigator.of(context).pop(true); // Return true to indicate success
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.categoryCreatedSuccessfully),
              backgroundColor: Colors.green,
            ),
          );
          // Reload categories after creating
          context.read<ExpenseBloc>().add(const LoadExpenseCategoriesEvent());
        } else if (state is ExpenseError) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      },
      child: AlertDialog(
        title: Text(loc.createExpenseCategory),
        content: SizedBox(
          width: double.maxFinite,
          child: ReactiveForm(
            formGroup: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ReactiveTextField(
                  formControlName: 'name',
                  decoration: InputDecoration(
                    labelText: loc.categoryName,
                    hintText: loc.categoryNameHint,
                    prefixIcon: const Icon(Icons.category),
                  ),
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                ReactiveTextField(
                  formControlName: 'description',
                  decoration: InputDecoration(
                    labelText: loc.descriptionOptional,
                    hintText: loc.categoryDescriptionHint,
                    prefixIcon: const Icon(Icons.description),
                  ),
                  maxLines: 3,
                  textInputAction: TextInputAction.done,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed:
                _isSubmitting ? null : () => Navigator.of(context).pop(false),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _handleSubmit,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(loc.create),
          ),
        ],
      ),
    );
  }
}
