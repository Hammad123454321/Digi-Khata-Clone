import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/utils/validators.dart' show AppValidators;
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../core/localization/app_localizations.dart';
import '../bloc/staff_bloc.dart';
import '../bloc/staff_event.dart';
import '../bloc/staff_state.dart';

class AddStaffScreen extends StatelessWidget {
  const AddStaffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          loc.addStaff,
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
        child: _StaffForm(),
      ),
    );
  }
}

class AddStaffSheet extends StatelessWidget {
  const AddStaffSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    return SafeArea(
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: mediaQuery.viewInsets.bottom + 16,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: mediaQuery.size.height * 0.88,
          ),
          child: Column(
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
                      loc.addStaff,
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
              const SizedBox(height: 8),
              const Expanded(
                child: _StaffForm(contentPadding: EdgeInsets.zero),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StaffForm extends StatefulWidget {
  const _StaffForm({
    this.contentPadding = const EdgeInsets.all(24),
  });

  final EdgeInsets contentPadding;

  @override
  State<_StaffForm> createState() => _StaffFormState();
}

class _StaffFormState extends State<_StaffForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _roleController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _roleController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_isSubmitting || !_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    context.read<StaffBloc>().add(
          CreateStaffEvent(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
            email: _emailController.text.trim().isEmpty
                ? null
                : _emailController.text.trim(),
            role: _roleController.text.trim().isEmpty
                ? null
                : _roleController.text.trim(),
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

    return BlocListener<StaffBloc, StaffState>(
      listenWhen: (previous, current) =>
          current is StaffCreated || current is StaffError,
      listener: (context, state) {
        if (!mounted) return;
        if (state is StaffCreated) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loc.staffMemberCreatedSuccessfully)),
          );
          Navigator.of(context).pop(true);
        } else if (state is StaffError) {
          setState(() => _isSubmitting = false);
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
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              AppTextField(
                controller: _nameController,
                label: loc.staffName,
                hint: loc.nameHint,
                prefixIcon: const Icon(Icons.person),
                textInputAction: TextInputAction.next,
                maxLength: 255,
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  final requiredError =
                      AppValidators.required(trimmed, loc.staffName, loc);
                  if (requiredError != null) return requiredError;
                  return AppValidators.maxLength(
                    trimmed,
                    255,
                    loc.staffName,
                    loc,
                  );
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _roleController,
                label: loc.roleOptional,
                hint: loc.roleHint,
                prefixIcon: const Icon(Icons.work),
                textInputAction: TextInputAction.next,
                maxLength: 100,
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) return null;
                  return AppValidators.maxLength(
                    trimmed,
                    100,
                    loc.role,
                    loc,
                  );
                },
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
                  LengthLimitingTextInputFormatter(20),
                ],
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) return null;
                  final maxLengthError = AppValidators.maxLength(
                    trimmed,
                    20,
                    loc.phone,
                    loc,
                  );
                  if (maxLengthError != null) return maxLengthError;
                  return AppValidators.phone(trimmed, loc);
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
                maxLength: 255,
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) return null;
                  final maxLengthError = AppValidators.maxLength(
                    trimmed,
                    255,
                    loc.emailOptional,
                    loc,
                  );
                  if (maxLengthError != null) return maxLengthError;
                  return AppValidators.email(trimmed, loc);
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _addressController,
                label: loc.addressOptional,
                hint: loc.addressHint,
                prefixIcon: const Icon(Icons.location_on),
                maxLines: 3,
                maxLength: 500,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) return null;
                  return AppValidators.maxLength(
                    trimmed,
                    500,
                    loc.addressOptional,
                    loc,
                  );
                },
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
