import 'package:flutter/material.dart';

/// Production-ready App Button with multiple variants
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.isDisabled = false,
  });

  final VoidCallback? onPressed;
  final String label;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = !isDisabled && !isLoading && onPressed != null;

    final buttonStyle = _getButtonStyle(theme, isEnabled);
    final textStyle = _getTextStyle(theme);
    final padding = _getPadding();
    final minHeight = _getMinHeight();

    Widget child = isLoading
        ? SizedBox(
            height: size == AppButtonSize.small ? 16 : 20,
            width: size == AppButtonSize.small ? 16 : 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                variant == AppButtonVariant.primary
                    ? Colors.white
                    : theme.colorScheme.primary,
              ),
            ),
          )
        : Row(
            mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: _getIconSize()),
                const SizedBox(width: 8),
              ],
              Text(label, style: textStyle),
            ],
          );

    final button = ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      style: buttonStyle.copyWith(
        minimumSize: MaterialStateProperty.all(
          Size(isFullWidth ? double.infinity : 0, minHeight),
        ),
        padding: MaterialStateProperty.all(padding),
      ),
      child: child,
    );

    return button;
  }

  ButtonStyle _getButtonStyle(ThemeData theme, bool isEnabled) {
    return switch (variant) {
      AppButtonVariant.primary => ElevatedButton.styleFrom(
          backgroundColor: isEnabled
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceVariant,
          foregroundColor: isEnabled
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurfaceVariant,
          elevation: isEnabled ? 2 : 0,
          shadowColor: theme.colorScheme.primary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      AppButtonVariant.secondary => ElevatedButton.styleFrom(
          backgroundColor: isEnabled
              ? theme.colorScheme.secondaryContainer
              : theme.colorScheme.surfaceVariant,
          foregroundColor: isEnabled
              ? theme.colorScheme.onSecondaryContainer
              : theme.colorScheme.onSurfaceVariant,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      AppButtonVariant.outline => OutlinedButton.styleFrom(
          foregroundColor: isEnabled
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
          side: BorderSide(
            color: isEnabled
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      AppButtonVariant.text => TextButton.styleFrom(
          foregroundColor: isEnabled
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
    };
  }

  TextStyle _getTextStyle(ThemeData theme) {
    return switch (size) {
      AppButtonSize.small => theme.textTheme.labelLarge ?? const TextStyle(),
      AppButtonSize.medium => theme.textTheme.titleSmall ?? const TextStyle(),
      AppButtonSize.large => theme.textTheme.titleMedium ?? const TextStyle(),
    };
  }

  EdgeInsets _getPadding() {
    return switch (size) {
      AppButtonSize.small => const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
      AppButtonSize.medium => const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
      AppButtonSize.large => const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 16,
        ),
    };
  }

  double _getMinHeight() {
    return switch (size) {
      AppButtonSize.small => 36,
      AppButtonSize.medium => 48,
      AppButtonSize.large => 56,
    };
  }

  double _getIconSize() {
    return switch (size) {
      AppButtonSize.small => 16,
      AppButtonSize.medium => 20,
      AppButtonSize.large => 24,
    };
  }
}

enum AppButtonVariant { primary, secondary, outline, text }

enum AppButtonSize { small, medium, large }
