import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/routes/app_router.dart';
import '../../../shared/models/staff_model.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/modern_components.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../bloc/staff_bloc.dart';
import '../bloc/staff_event.dart';
import '../bloc/staff_state.dart';
import 'add_staff_screen.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  List<StaffModel> _cachedStaff = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applyFilters);
    context.read<StaffBloc>().add(const LoadStaffEvent());
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilters);
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _applyFilters() {
    setState(() {});
  }

  List<StaffModel> _filterStaff(List<StaffModel> staff) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return staff;

    return staff.where((member) {
      final name = member.name.toLowerCase();
      final phone = member.phone?.toLowerCase() ?? '';
      final role = member.role?.toLowerCase() ?? '';
      final email = member.email?.toLowerCase() ?? '';
      return name.contains(query) ||
          phone.contains(query) ||
          role.contains(query) ||
          email.contains(query);
    }).toList();
  }

  Future<void> _openAddStaff() async {
    final staffBloc = context.read<StaffBloc>();
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: staffBloc,
        child: const AddStaffSheet(),
      ),
    );

    if (result == true && mounted) {
      context.read<StaffBloc>().add(const LoadStaffEvent(refresh: true));
    }
  }

  Future<void> _openSalarySheet({StaffModel? staff}) async {
    if (_cachedStaff.isEmpty) {
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.noStaffMembers),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final staffBloc = context.read<StaffBloc>();
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: staffBloc,
        child: _SalarySheet(
          staffList: _cachedStaff,
          initialStaff: staff,
        ),
      ),
    );

    if (result == true && mounted) {
      context.read<StaffBloc>().add(const LoadStaffEvent(refresh: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.staff,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            GestureDetector(
              onTap: () => Navigator.of(context).pushNamed(AppRouter.settings),
              child: Text(
                loc.viewSettingsHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
        ),
      ),
      body: BlocConsumer<StaffBloc, StaffState>(
        listener: (context, state) {
          final loc = AppLocalizations.of(context)!;
          if (state is SalaryRecorded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(loc.salaryRecordedSuccessfully),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is StaffError && _cachedStaff.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is StaffLoaded) {
            _cachedStaff = state.staff;
          }

          final isLoading = state is StaffLoading && _cachedStaff.isEmpty;

          if (state is StaffError && _cachedStaff.isEmpty) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () =>
                  context.read<StaffBloc>().add(const LoadStaffEvent()),
            );
          }

          return LoadingOverlay(
            isLoading: isLoading,
            child: _buildStaffContent(theme),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ElevatedButton(
            onPressed: _openAddStaff,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: Text(loc.addStaff),
          ),
        ),
      ),
    );
  }

  Widget _buildStaffContent(ThemeData theme) {
    final loc = AppLocalizations.of(context)!;
    final filteredStaff = _filterStaff(_cachedStaff);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  filteredStaff.length.toString(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  loc.staff,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                QuickActionButton(
                  icon: Icons.person_add_alt,
                  label: loc.addStaff,
                  onTap: _openAddStaff,
                ),
                const SizedBox(width: 12),
                QuickActionButton(
                  icon: Icons.payments_outlined,
                  label: loc.recordSalary,
                  onTap: () => _openSalarySheet(),
                ),
                const SizedBox(width: 12),
                QuickActionButton(
                  icon: Icons.refresh,
                  label: loc.refresh,
                  onTap: () => context
                      .read<StaffBloc>()
                      .add(const LoadStaffEvent(refresh: true)),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocus,
            decoration: InputDecoration(
              hintText: loc.search,
              prefixIcon: const Icon(Icons.search),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  loc.entries,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  loc.phone,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.successColor,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  loc.role,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.errorColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _cachedStaff.isEmpty
              ? Center(
                  child: EmptyState(
                    icon: Icons.people,
                    title: loc.noStaffMembers,
                    message: loc.addFirstStaffMember,
                  ),
                )
              : filteredStaff.isEmpty
                  ? Center(
                      child: Text(
                        loc.noResultsFound,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: filteredStaff.length,
                      itemBuilder: (context, index) {
                        final staff = filteredStaff[index];
                        final phone = staff.phone ?? '';
                        final role = staff.role ?? '';

                        return AppCard(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: EdgeInsets.zero,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              staff.name,
                                              style: theme.textTheme.titleSmall
                                                  ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          PopupMenuButton<String>(
                                            onSelected: (value) {
                                              if (value == 'salary') {
                                                _openSalarySheet(staff: staff);
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              PopupMenuItem(
                                                value: 'salary',
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.payments_outlined,
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(loc.recordSalary),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      if (staff.email != null &&
                                          staff.email!.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          staff.email!,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: theme
                                                .colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                      if (staff.address != null &&
                                          staff.address!.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          staff.address!,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: theme
                                                .colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                              _StaffInfoCell(
                                value: phone,
                                highlight: phone.isNotEmpty,
                                color: AppTheme.successColor,
                              ),
                              _StaffInfoCell(
                                value: role,
                                highlight: role.isNotEmpty,
                                color: AppTheme.errorColor,
                                isLast: true,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

class _StaffInfoCell extends StatelessWidget {
  const _StaffInfoCell({
    required this.value,
    required this.highlight,
    required this.color,
    this.isLast = false,
  });

  final String value;
  final bool highlight;
  final Color color;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: highlight ? color.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: isLast
              ? const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                )
              : null,
        ),
        child: Text(
          value,
          textAlign: TextAlign.right,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: highlight ? color : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _SalarySheet extends StatefulWidget {
  const _SalarySheet({
    required this.staffList,
    this.initialStaff,
  });

  final List<StaffModel> staffList;
  final StaffModel? initialStaff;

  @override
  State<_SalarySheet> createState() => _SalarySheetState();
}

class _SalarySheetState extends State<_SalarySheet> {
  StaffModel? _selectedStaff;
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  String _paymentMode = 'cash';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedStaff = widget.initialStaff ?? widget.staffList.first;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final loc = AppLocalizations.of(context)!;
    if (_selectedStaff == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.selectStaff),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.pleaseEnterValidAmount),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    context.read<StaffBloc>().add(
          RecordSalaryEvent(
            staffId: _selectedStaff!.id,
            amount: amountText,
            date: _selectedDate,
            paymentMode: _paymentMode,
            remarks: _remarksController.text.trim().isEmpty
                ? null
                : _remarksController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    return BlocListener<StaffBloc, StaffState>(
      listener: (context, state) {
        if (state is SalaryRecorded) {
          setState(() => _isSubmitting = false);
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
      child: SafeArea(
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
                      loc.recordSalary,
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
              const SizedBox(height: 8),
              DropdownButtonFormField<StaffModel>(
                initialValue: _selectedStaff,
                decoration: InputDecoration(
                  labelText: loc.selectStaff,
                  prefixIcon: const Icon(Icons.person),
                ),
                items: widget.staffList
                    .map(
                      (member) => DropdownMenuItem(
                        value: member,
                        child: Text(member.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedStaff = value),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: loc.amount,
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
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _selectedDate = date);
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: loc.date,
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    DateFormat.yMMMd(loc.locale.languageCode)
                        .format(_selectedDate),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  loc.paymentMode,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(loc.cash),
                    selected: _paymentMode == 'cash',
                    onSelected: (_) => setState(() => _paymentMode = 'cash'),
                  ),
                  ChoiceChip(
                    label: Text(loc.bank),
                    selected: _paymentMode == 'bank',
                    onSelected: (_) => setState(() => _paymentMode = 'bank'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _remarksController,
                decoration: InputDecoration(
                  labelText: loc.remarksOptional,
                  prefixIcon: const Icon(Icons.note),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              AppButton(
                onPressed: _isSubmitting ? null : _submit,
                label: loc.record,
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
