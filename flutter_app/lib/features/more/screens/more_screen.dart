import 'package:flutter/material.dart';

import '../../../core/routes/app_router.dart';
import '../../../core/localization/app_localizations.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key, this.isSheet = false});

  final bool isSheet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: isSheet
          ? null
          : AppBar(
              title: Text(loc.more),
            ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _MoreItem(
            icon: Icons.inventory_2_outlined,
            label: loc.stock,
            onTap: () => Navigator.of(context).pushNamed(AppRouter.stock),
          ),
          _MoreItem(
            icon: Icons.groups_outlined,
            label: loc.staff,
            onTap: () => Navigator.of(context).pushNamed(AppRouter.staff),
          ),
          _MoreItem(
            icon: Icons.receipt_long_outlined,
            label: loc.expenses,
            onTap: () => Navigator.of(context).pushNamed(AppRouter.expenses),
          ),
          _MoreItem(
            icon: Icons.account_balance_outlined,
            label: loc.banks,
            onTap: () => Navigator.of(context).pushNamed(AppRouter.banks),
          ),
          _MoreItem(
            icon: Icons.smartphone_outlined,
            label: loc.devices,
            onTap: () => Navigator.of(context).pushNamed(AppRouter.devices),
          ),
          _MoreItem(
            icon: Icons.notifications_outlined,
            label: loc.reminders,
            onTap: () => Navigator.of(context).pushNamed(AppRouter.reminders),
          ),
          _MoreItem(
            icon: Icons.settings_outlined,
            label: loc.settings,
            onTap: () => Navigator.of(context).pushNamed(AppRouter.settings),
          ),
          _MoreItem(
            icon: Icons.money_outlined,
            label: loc.cash,
            onTap: () => Navigator.of(context).pushNamed(AppRouter.cash),
          ),
          _MoreItem(
            icon: Icons.receipt_outlined,
            label: loc.invoices,
            onTap: () => Navigator.of(context).pushNamed(AppRouter.invoices),
          ),
        ],
      ),
    );
  }
}

class _MoreItem extends StatelessWidget {
  const _MoreItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
