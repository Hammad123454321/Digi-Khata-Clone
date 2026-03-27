import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/utils/validators.dart' show AppValidators;
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../bloc/supplier_bloc.dart';
import '../bloc/supplier_event.dart';
import '../bloc/supplier_state.dart';

class AddSupplierScreen extends StatelessWidget {
  const AddSupplierScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          loc.addSupplier,
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
        ),
      ),
      body: const SafeArea(
        child: _SupplierForm(),
      ),
    );
  }
}

class AddSupplierSheet extends StatelessWidget {
  const AddSupplierSheet({super.key});

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
                    loc.addSupplier,
                    style: theme.textTheme.titleMedium?.copyWith(
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
              child: _SupplierForm(contentPadding: EdgeInsets.zero),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupplierForm extends StatefulWidget {
  const _SupplierForm({
    this.contentPadding = const EdgeInsets.all(24),
  });

  final EdgeInsets contentPadding;

  @override
  State<_SupplierForm> createState() => _SupplierFormState();
}

class _SupplierFormState extends State<_SupplierForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    context.read<SupplierBloc>().add(
          CreateSupplierEvent(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
            email: _emailController.text.trim().isEmpty
                ? null
                : _emailController.text.trim(),
            address: _addressController.text.trim().isEmpty
                ? null
                : _addressController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return BlocListener<SupplierBloc, SupplierState>(
      listener: (context, state) {
        if (state is SupplierCreated) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loc.supplierCreatedSuccessfully)),
          );
          Navigator.of(context).pop(true);
        } else if (state is SupplierError) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        } else if (state is SupplierLoading) {
          setState(() => _isSubmitting = true);
        }
      },
      child: SingleChildScrollView(
        padding: widget.contentPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              AppTextField(
                controller: _nameController,
                label: loc.supplierName,
                hint: loc.supplierNameHint,
                prefixIcon: const Icon(Icons.person),
                textInputAction: TextInputAction.next,
                validator: (value) => AppValidators.required(
                  value,
                  loc.supplierName,
                  loc,
                ),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _phoneController,
                label: loc.phoneOptional,
                hint: loc.phoneHint,
                prefixIcon: const Icon(Icons.phone),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  return AppValidators.phone(value, loc);
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _emailController,
                label: loc.emailOptional,
                hint: loc.emailHint,
                prefixIcon: const Icon(Icons.email),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  return AppValidators.email(value, loc);
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _addressController,
                label: loc.addressOptional,
                hint: loc.addressHint,
                prefixIcon: const Icon(Icons.location_on),
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 32),
              AppButton(
                onPressed: _isSubmitting ? null : _handleSave,
                label: loc.saveSupplier,
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
