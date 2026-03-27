import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

import '../../../core/di/injection.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/localization/locale_bloc.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/validators.dart';
import '../../../shared/widgets/gradient_pill_button.dart';
import '../bloc/business_bloc.dart';
import '../bloc/business_event.dart';
import '../bloc/business_state.dart';

class CreateBusinessScreen extends StatefulWidget {
  const CreateBusinessScreen({super.key});

  @override
  State<CreateBusinessScreen> createState() => _CreateBusinessScreenState();
}

class _CreateBusinessScreenState extends State<CreateBusinessScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ownerController = TextEditingController();
  final _businessController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _areaController = TextEditingController();
  final _cityController = TextEditingController();
  final _customCategoryController = TextEditingController();
  final _customTypeController = TextEditingController();

  int _stepIndex = 0;
  bool _isSubmitting = false;
  bool _showSuccess = false;
  bool _hasNavigated = false;

  String _selectedLanguage = 'en';
  String? _selectedCategory;
  String? _selectedType = 'retail_shop';

  final List<_OptionItem> _categories = const [
    _OptionItem(
        value: 'Kirana/Grocery',
        label: 'Kirana/Grocery',
        icon: Icons.storefront),
    _OptionItem(
        value: 'Textile/Fashion',
        label: 'Textile/Fashion',
        icon: Icons.checkroom),
    _OptionItem(
        value: 'Medical', label: 'Medical', icon: Icons.medical_services),
    _OptionItem(
        value: 'Electronics',
        label: 'Electronics',
        icon: Icons.electrical_services),
    _OptionItem(value: 'Mobile', label: 'Mobile', icon: Icons.phone_iphone),
    _OptionItem(
        value: 'Automobile', label: 'Automobile', icon: Icons.directions_car),
    _OptionItem(value: 'Sports', label: 'Sports', icon: Icons.sports_soccer),
    _OptionItem(value: 'Kids/Toys', label: 'Kids/Toys', icon: Icons.toys),
    _OptionItem(
        value: 'Hardware/Tools', label: 'Hardware/Tools', icon: Icons.build),
    _OptionItem(value: 'Other', label: 'Others', icon: Icons.widgets),
  ];

  final List<_OptionItem> _businessTypes = const [
    _OptionItem(
        value: 'retail_shop', label: 'Retailer/ Shop', icon: Icons.store),
    _OptionItem(value: 'wholesale', label: 'Wholesaler', icon: Icons.warehouse),
    _OptionItem(
        value: 'distributor', label: 'Distributor', icon: Icons.local_shipping),
    _OptionItem(
        value: 'manufacturing',
        label: 'Manufacturer',
        icon: Icons.precision_manufacturing),
    _OptionItem(value: 'services', label: 'Services', icon: Icons.handyman),
    _OptionItem(value: 'other', label: 'Others', icon: Icons.more_horiz),
  ];

  @override
  void initState() {
    super.initState();
    final storage = getIt<LocalStorageService>();
    final phone = storage.getUserPhone();
    if (phone != null) {
      _phoneController.text = phone;
    }
    final langPref = storage.getLanguagePreference();
    if (langPref != null) {
      _selectedLanguage = langPref;
    }
  }

  @override
  void dispose() {
    _ownerController.dispose();
    _businessController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _areaController.dispose();
    _cityController.dispose();
    _customCategoryController.dispose();
    _customTypeController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_showSuccess) return;
    final loc = AppLocalizations.of(context)!;
    if (_stepIndex == 2) {
      if (_selectedCategory == null) {
        _showSnack(loc.selectBusinessCategory);
        return;
      }
      if (_selectedCategory == 'Other' &&
          _customCategoryController.text.trim().isEmpty) {
        _showSnack(loc.enterBusinessCategory);
        return;
      }
    }
    if (_stepIndex == 3 && _selectedType == 'other') {
      if (_customTypeController.text.trim().isEmpty) {
        _showSnack(loc.enterBusinessType);
        return;
      }
    }
    if (_formKey.currentState?.validate() == false) return;
    setState(() {
      if (_stepIndex < 4) {
        _stepIndex += 1;
      } else {
        _submit();
      }
    });
  }

  void _previousStep() {
    if (_stepIndex == 0) return;
    setState(() => _stepIndex -= 1);
  }

  void _submit() {
    if (_isSubmitting) return;
    final bloc = context.read<BusinessBloc>();
    final customType =
        _selectedType == 'other' ? _customTypeController.text.trim() : null;
    final category = _selectedCategory == 'Other'
        ? _customCategoryController.text.trim()
        : _selectedCategory;

    bloc.add(
      CreateBusiness(
        name: _businessController.text.trim(),
        phone: _phoneController.text.trim(),
        ownerName: _ownerController.text.trim(),
        address: _addressController.text.trim(),
        area: _areaController.text.trim(),
        city: _cityController.text.trim(),
        businessCategory: category,
        businessType: _selectedType ?? 'retail_shop',
        customBusinessType: customType,
        languagePreference: _selectedLanguage,
        maxDevices: 3,
      ),
    );
    setState(() => _isSubmitting = true);
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return BlocListener<BusinessBloc, BusinessState>(
      listener: (context, state) {
        if (!_isSubmitting || _hasNavigated || !mounted) return;

        if (state is BusinessLoaded) {
          if (state.businesses.isNotEmpty && state.currentBusinessId != null) {
            setState(() {
              _isSubmitting = false;
              _showSuccess = true;
            });
          }
        } else if (state is BusinessError) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(loc.setUpDigiKhata),
          leading: _stepIndex > 0 && !_showSuccess
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _previousStep,
                )
              : null,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              _BusinessPreviewCard(
                owner: _ownerController.text.trim(),
                phone: _phoneController.text.trim(),
                name: _businessController.text.trim(),
                category: _selectedCategory == 'Other'
                    ? _customCategoryController.text.trim()
                    : _selectedCategory,
                typeLabel: _typeLabel(),
                city: _cityController.text.trim(),
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Form(
                    key: _formKey,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, animation) {
                        final tween = Tween<Offset>(
                          begin: const Offset(0.1, 0),
                          end: Offset.zero,
                        ).animate(animation);
                        return SlideTransition(position: tween, child: child);
                      },
                      child: _showSuccess
                          ? _SuccessStep(name: _businessController.text.trim())
                          : _buildStep(loc),
                    ),
                  ),
                ),
              ),
              if (!_showSuccess)
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: GradientPillButton(
                      label: _stepIndex == 4 ? loc.finish : loc.next,
                      trailingIcon: Icons.arrow_forward,
                      onPressed: _isSubmitting ? null : _nextStep,
                      isLoading: _isSubmitting,
                    ),
                  ),
                ),
              if (_showSuccess)
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: GradientPillButton(
                      label: loc.start,
                      trailingIcon: Icons.arrow_forward,
                      onPressed: () {
                        if (_hasNavigated) return;
                        _hasNavigated = true;
                        Navigator.of(context).pop(true);
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(AppLocalizations loc) {
    switch (_stepIndex) {
      case 0:
        return _OwnerStep(controller: _ownerController);
      case 1:
        return _BusinessNameStep(controller: _businessController);
      case 2:
        return _CategoryStep(
          categories: _categories,
          selected: _selectedCategory,
          onSelected: (value) => setState(() => _selectedCategory = value),
          customController: _customCategoryController,
        );
      case 3:
        return _TypeStep(
          types: _businessTypes,
          selected: _selectedType,
          onSelected: (value) => setState(() => _selectedType = value),
          customController: _customTypeController,
        );
      case 4:
      default:
        return _AddressStep(
          addressController: _addressController,
          areaController: _areaController,
          cityController: _cityController,
          phoneController: _phoneController,
        );
    }
  }

  String? _typeLabel() {
    final type = _selectedType;
    if (type == null) return null;
    final option = _businessTypes.firstWhere(
      (item) => item.value == type,
      orElse: () => const _OptionItem(value: '', label: '', icon: Icons.store),
    );
    if (type == 'other' && _customTypeController.text.trim().isNotEmpty) {
      return _customTypeController.text.trim();
    }
    return option.label.isEmpty ? null : option.label;
  }
}

class _OwnerStep extends StatelessWidget {
  const _OwnerStep({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    return Column(
      key: const ValueKey('owner_step'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.ownerName,
          style:
              theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          validator: (value) =>
              AppValidators.required(value, loc.ownerName, loc),
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: loc.ownerNameHint,
            prefixIcon: const Icon(Icons.person_outline),
          ),
        ),
      ],
    );
  }
}

class _BusinessNameStep extends StatelessWidget {
  const _BusinessNameStep({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    return Column(
      key: const ValueKey('business_step'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.businessName,
          style:
              theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          validator: (value) =>
              AppValidators.required(value, loc.businessName, loc),
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: loc.businessNameHint,
            prefixIcon: const Icon(Icons.storefront),
          ),
        ),
      ],
    );
  }
}

class _CategoryStep extends StatelessWidget {
  const _CategoryStep({
    required this.categories,
    required this.selected,
    required this.onSelected,
    required this.customController,
  });

  final List<_OptionItem> categories;
  final String? selected;
  final ValueChanged<String> onSelected;
  final TextEditingController customController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    return Column(
      key: const ValueKey('category_step'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.businessCategoryQuestion,
          style:
              theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: categories.map((item) {
                    final isSelected = item.value == selected;
                    return _OptionCard(
                      item: item,
                      selected: isSelected,
                      onTap: () => onSelected(item.value),
                    );
                  }).toList(),
                ),
                if (selected == 'Other') ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: customController,
                    decoration: InputDecoration(
                      hintText: loc.enterBusinessCategory,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TypeStep extends StatelessWidget {
  const _TypeStep({
    required this.types,
    required this.selected,
    required this.onSelected,
    required this.customController,
  });

  final List<_OptionItem> types;
  final String? selected;
  final ValueChanged<String> onSelected;
  final TextEditingController customController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    return Column(
      key: const ValueKey('type_step'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.businessTypeQuestion,
          style:
              theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: types.map((item) {
                    final isSelected = item.value == selected;
                    return _OptionCard(
                      item: item,
                      selected: isSelected,
                      onTap: () => onSelected(item.value),
                    );
                  }).toList(),
                ),
                if (selected == 'other') ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: customController,
                    decoration: InputDecoration(
                      hintText: loc.enterBusinessType,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AddressStep extends StatelessWidget {
  const _AddressStep({
    required this.addressController,
    required this.areaController,
    required this.cityController,
    required this.phoneController,
  });

  final TextEditingController addressController;
  final TextEditingController areaController;
  final TextEditingController cityController;
  final TextEditingController phoneController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    return Column(
      key: const ValueKey('address_step'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              loc.businessAddress,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(loc.locationNotAvailable)),
                );
              },
              icon: const Icon(Icons.location_on_outlined),
              label: Text(loc.googleLocation),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: addressController,
          validator: (value) =>
              AppValidators.required(value, loc.businessAddress, loc),
          decoration: InputDecoration(
            hintText: loc.addressLineHint,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: areaController,
          decoration: InputDecoration(
            hintText: loc.areaHint,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: cityController,
          decoration: InputDecoration(
            hintText: loc.cityHint,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: loc.phoneHint,
            prefixIcon: const Icon(Icons.phone_outlined),
          ),
        ),
      ],
    );
  }
}

class _SuccessStep extends StatelessWidget {
  const _SuccessStep({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    return Center(
      key: const ValueKey('success_step'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.celebration, size: 72, color: Color(0xFFF6A623)),
          const SizedBox(height: 16),
          Text(
            loc.congratulations,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            loc.businessReady
                .replaceAll('{business}', name.isEmpty ? 'business' : name),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _BusinessPreviewCard extends StatelessWidget {
  const _BusinessPreviewCard({
    required this.owner,
    required this.phone,
    required this.name,
    required this.category,
    required this.typeLabel,
    required this.city,
  });

  final String owner;
  final String phone;
  final String name;
  final String? category;
  final String? typeLabel;
  final String city;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              // Decorative mandala border at top
              Container(
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1E88E5), // Blue
                      const Color(0xFFF57C00), // Orange
                      const Color(0xFFE91E63), // Pink
                      const Color(0xFF4CAF50), // Green
                      const Color(0xFFFFC107), // Yellow
                    ],
                    stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                  ),
                ),
                child: CustomPaint(
                  painter: _MandalaBorderPainter(),
                  child: Container(),
                ),
              ),
              // Card content
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? theme.colorScheme.surface
                      : const Color(0xFFF7E2C8),
                  image: const DecorationImage(
                    image: AssetImage('app-logo.jpeg'),
                    fit: BoxFit.cover,
                    opacity: 0.03,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      name.isEmpty ? 'Business name' : name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.brightness == Brightness.dark
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category == null || category!.isEmpty
                          ? 'type/category'
                          : category!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.brightness == Brightness.dark
                            ? theme.colorScheme.onSurfaceVariant
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (typeLabel != null && typeLabel!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        typeLabel!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.brightness == Brightness.dark
                              ? theme.colorScheme.onSurfaceVariant
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              owner.isEmpty ? 'Owner' : owner,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.brightness == Brightness.dark
                                    ? theme.colorScheme.onSurface
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              phone.isEmpty ? 'Number' : phone,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.brightness == Brightness.dark
                                    ? theme.colorScheme.onSurface
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          city.isEmpty ? 'City' : city,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.brightness == Brightness.dark
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom painter for mandala-style decorative border
class _MandalaBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    // Draw decorative patterns
    final centerY = size.height / 2;
    final spacing = size.width / 8;

    for (int i = 0; i < 8; i++) {
      final x = i * spacing + spacing / 2;
      paint.color = [
        const Color(0xFF1E88E5),
        const Color(0xFFF57C00),
        const Color(0xFFE91E63),
        const Color(0xFF4CAF50),
        const Color(0xFFFFC107),
        const Color(0xFF9C27B0),
        const Color(0xFF00BCD4),
        const Color(0xFFFF5722),
      ][i % 8];

      // Draw circular patterns
      canvas.drawCircle(Offset(x, centerY), 6, paint);
      canvas.drawCircle(Offset(x, centerY), 3, paint..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _OptionItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: (MediaQuery.of(context).size.width - 64) / 2,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? (isDark
                  ? AppTheme.primaryGradient.colors.first.withValues(alpha: 0.2)
                  : const Color(0xFFFCEDE7))
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppTheme.primaryGradient.colors.first
                : theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: selected
                  ? AppTheme.primaryGradient.colors.first
                      .withValues(alpha: 0.15)
                  : theme.colorScheme.surfaceVariant,
              child: Icon(
                item.icon,
                size: 18,
                color: selected
                    ? AppTheme.primaryGradient.colors.first
                    : theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? AppTheme.primaryGradient.colors.first
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionItem {
  const _OptionItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;
}
