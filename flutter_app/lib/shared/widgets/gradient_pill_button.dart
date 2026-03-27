import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Pill-shaped gradient button used across DigiKhata screens.
class GradientPillButton extends StatelessWidget {
  const GradientPillButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.trailingIcon,
    this.height = 56,
    this.fullWidth = true,
    this.colors,
    this.textStyle,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? trailingIcon;
  final double height;
  final bool fullWidth;
  final List<Color>? colors;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = onPressed != null && !isLoading;
    final gradientColors =
        colors ?? const [Color(0xFFE24B2D), Color(0xFFF0782A)];

    Widget buttonContent = Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: AppTheme.successColor.withValues(alpha: 0.0),
            blurRadius: 0,
          ),
          BoxShadow(
            color: gradientColors.last.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: textStyle ??
                          theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                    ),
                    if (trailingIcon != null) ...[
                      const SizedBox(width: 12),
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          trailingIcon,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );

    Widget button = Opacity(
      opacity: isEnabled ? 1 : 0.6,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(40),
          child: buttonContent,
        ),
      ),
    );

    if (fullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}
