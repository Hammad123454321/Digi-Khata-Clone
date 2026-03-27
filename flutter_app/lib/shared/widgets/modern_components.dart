import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'app_card.dart';

/// Modern Stat Card with Icon and Gradient Background
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.gradient,
    this.subtitle,
    this.trend,
    this.onTap,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final Gradient? gradient;
  final String? subtitle;
  final Widget? trend;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? theme.colorScheme.primary;
    final cardGradient = gradient ??
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cardColor,
            cardColor.withValues(alpha: 0.7),
          ],
        );

    return AppCard(
      onTap: onTap,
      gradient: cardGradient,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              if (trend != null) trend!,
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Gradient Card Widget
class GradientCard extends StatelessWidget {
  const GradientCard({
    super.key,
    required this.child,
    this.gradient,
    this.onTap,
    this.padding,
    this.margin,
  });

  final Widget child;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      gradient: gradient ?? AppTheme.primaryGradient,
      padding: padding ?? const EdgeInsets.all(20),
      margin: margin,
      child: child,
    );
  }
}

/// Modern List Tile with Better Spacing
class ModernListTile extends StatelessWidget {
  const ModernListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.icon,
    this.iconColor,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          if (leading != null)
            leading!
          else if (icon != null)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (iconColor ?? theme.colorScheme.primary)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor ?? theme.colorScheme.primary,
                size: 20,
              ),
            ),
          if (leading != null || icon != null) const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ] else if (onTap != null)
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
        ],
      ),
    );
  }
}

/// Balance summary card for "You will give / You will get"
class BalanceSummaryCard extends StatelessWidget {
  const BalanceSummaryCard({
    super.key,
    required this.willGive,
    required this.willGet,
    required this.hideBalances,
    required this.onToggle,
    required this.hideLabel,
    required this.showLabel,
    required this.willGiveLabel,
    required this.willGetLabel,
    this.compact = false,
  });

  final String willGive;
  final String willGet;
  final bool hideBalances;
  final VoidCallback onToggle;
  final String hideLabel;
  final String showLabel;
  final String willGiveLabel;
  final String willGetLabel;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    hideBalances ? showLabel : hideLabel,
                    style: (compact
                            ? theme.textTheme.labelSmall
                            : theme.textTheme.bodySmall)
                        ?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: compact ? 8 : 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      willGive,
                      style: (compact
                              ? theme.textTheme.titleMedium
                              : theme.textTheme.titleLarge)
                          ?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: compact ? 2 : 4),
                    Text(
                      willGiveLabel,
                      style: (compact
                              ? theme.textTheme.labelSmall
                              : theme.textTheme.bodySmall)
                          ?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: compact ? 30 : 40,
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      willGet,
                      style: (compact
                              ? theme.textTheme.titleMedium
                              : theme.textTheme.titleLarge)
                          ?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: compact ? 2 : 4),
                    Text(
                      willGetLabel,
                      style: (compact
                              ? theme.textTheme.labelSmall
                              : theme.textTheme.bodySmall)
                          ?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Quick action button used on home/khata screens
class QuickActionButton extends StatelessWidget {
  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: compact ? 78 : 90,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 12,
          vertical: compact ? 8 : 10,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: theme.colorScheme.primary,
              size: compact ? 20 : 22,
            ),
            SizedBox(height: compact ? 6 : 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: (compact
                      ? theme.textTheme.labelSmall
                      : theme.textTheme.bodySmall)
                  ?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ledger list tile for customer/supplier rows
class LedgerListTile extends StatelessWidget {
  const LedgerListTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isCredit,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String amount;
  final bool isCredit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isCredit ? AppTheme.successColor : AppTheme.errorColor;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(
              isCredit ? Icons.arrow_downward : Icons.arrow_upward,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            amount,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
